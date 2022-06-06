
function stageTitle {
  printf "${FX[bold]}${FG[blue]}=> %s${FG[none]}${FX[none]}\n" "${1}"
}

function subTitle {
  printf "${FG[blue]}==> %s${FG[none]}\n" "${1}"
}

function updateEnvironment_gitUpdate {
  (
    stageTitle "Updating environment"
    subTitle "Update git env dir"

    function cannot-fast-forward {
      local STATUS="$1"
      [[ -n "${STATUS}" ]] && printf "%s\n" "${STATUS}"
      printf "Unable to fast-forward the changes. You can fix this by "
      printf "running\ncd '%s' and then\n'git pull' " "${ZDOTDIR}"
      printf "to manually pull and possibly merge in changes\n"
    }

    cd -q -- "${ZDOTDIR}" || return 7
    local orig_branch="$(git symbolic-ref HEAD 2> /dev/null | cut -d '/' -f 3)"
    git fetch || return "$?"

    local UPSTREAM=$(git rev-parse '@{u}')
    local LOCAL=$(git rev-parse HEAD)
    local REMOTE=$(git rev-parse "$UPSTREAM")
    local BASE=$(git merge-base HEAD "$UPSTREAM")

    if [[ $LOCAL == $REMOTE ]]; then
      printf "${FG[green]}There are no updates.${FG[none]}\n"
      return 0
    elif [[ $LOCAL == $BASE ]]; then
      subTitle "There is an update available. Trying to pull."
      if git pull --ff-only; then
        subTitle "Syncing submodules"
        git submodule sync --recursive
        git submodule update --init --recursive
        return $?
      else
        cannot-fast-forward
        return 1
      fi
    elif [[ $REMOTE == $BASE ]]; then
      cannot-fast-forward "Commits in master that aren't in upstream."
      return 1
    else
      cannot-fast-forward "Upstream and local have diverged."
      return 1
    fi
    return 1
  )
}

function updateEnvironment_setSshKeys {
  stageTitle "Updating SSH keys"
  local -a privateKeyFiles=("${ZDOTDIR}"/ssh/*_rsa(N))
  if [[ ${#privateKeyFiles[@]} -gt 0 ]]; then
    subTitle "Adding SSH keys"
    for identityFile in "${privateKeyFiles[@]}"; do
      chmod 600 "${identityFile}"
      ssh-add --apple-use-keychain "${identityFile}"
    done
  fi

  local -a publicKeyFiles=("${ZDOTDIR}"/ssh/*_rsa.pub(N))
  if [[ ${#publicKeyFiles[@]} -gt 0 ]]; then
    subTitle "Adding Authorized Keys"
    for identityFile in "${publicKeyFiles[@]}"; do
      echo "Adding ${identityFile}"
      local pubKey=$(cat "$identityFile")
      grep -q -F "${pubKey}" ~/.ssh/authorized_keys 2>/dev/null || echo "${pubKey}" >> ~/.ssh/authorized_keys
    done
  fi
}

function updateEnvironment_updateModules {
  local modules user_module_dirs
  zstyle -a ':prezto:load' pmodule-dirs 'user_module_dirs'
  zstyle -a ':prezto:load' pmodule 'modules'

  for module in "${modules[@]}"; do
    locations=(${user_module_dirs:+${^user_module_dirs}/$module(-/FN)})
    if (( ${#locations} != 1 )); then
      continue
    fi

    local module_location=${locations[-1]}

    if [[ -s "${module_location}/upgrade.zsh" ]]; then
      stageTitle "Updating module ${module}"
      source "${module_location}/upgrade.zsh"
    fi
  done
}

function updateEnvironment_setLinks {

  function setLinks_link {
    local linkName=$1
    local target=$2

    if [ -e "${target}" ]; then
      mkdir -p "${linkName:h}"

      if [ -e "${linkName}" ]; then
        rm -rf "${linkName}"
      fi
      ln -sfnv "${target}" "${linkName}"
    fi
  }

  function setLinks_nolink {
    local target=$1
    local source=$2

    mkdir -p "${target}"

    setLinks_doLinking "${source}" "${target}" ""
  }

  function setLinks_doLinking {
    local target=$2
    local dot=$3

    for linkPath in "${1}"/*
    do
      local linkName=${linkPath:t}

      if [[ "${linkName}" =~ "_nolink$" ]]; then
        setLinks_nolink "${target}/${dot}${linkName%_nolink}" "${linkPath}"
      else
        setLinks_link "${target}/${dot}${linkName}" "${linkPath}"
      fi
    done
  }

  function setLinks_clearBrokenLinks {
      for link in $(find ${HOME} -maxdepth 1 -type l); do
        if [ ! -e "${link}" ]; then
          echo "${FG[red]}Removing broken link [${link}].${FG[none]}"
          unlink "${link}"
        fi
      done
  }

  {
    stageTitle "Linking dotfiles"
    setLinks_doLinking "${ZDOTDIR}/dotfiles" ~ "."
    setLinks_link ~/.m2/repository ~/repository
    setLinks_clearBrokenLinks

  } always {
    unfunction setLinks_link
    unfunction setLinks_nolink
    unfunction setLinks_doLinking
    unfunction setLinks_clearBrokenLinks
  }
}

function updateEnvironment_installFonts {
  if [[ -d "${ZDOTDIR}/fonts" ]]; then
    stageTitle "Installing fonts"
    mkdir -p ~/Library/Fonts
    for font in ${ZDOTDIR}/fonts/*.ttf(N); do
      echo "Installing ${font:t}"
      cp "${font}" ~/Library/Fonts/.
    done
  fi
}

function updateEnvironment_addGpgKeys {
  local -a gpgKeyFiles=("${ZDOTDIR}"/keys/*.gpg(N))
   if [[ ${#gpgKeyFiles[@]} -gt 0 ]]; then
      subTitle "Adding GPG Keys"
      for gpgKeyFile in "${gpgKeyFiles[@]}"; do
        echo "Importing ${gpgKeyFile}"
        gpg -q --import "${gpgKeyFile}"
      done

   fi
}

{
  updateEnvironment_gitUpdate

  stageTitle "Updating homebrew"
  subTitle "Update brew"
  brew update && brew upgrade
  brew tap homebrew/bundle
  subTitle "Update brewfile bundle"
  brew bundle --verbose --file="${ZDOTDIR}/Brewfile"

  updateEnvironment_setSshKeys
  updateEnvironment_setLinks
  updateEnvironment_updateModules
  updateEnvironment_installFonts
  updateEnvironment_addGpgKeys

  stageTitle "Reloading Completions"
  rm -rf ${ZDOTDIR:-$HOME}/.zcompdump{,.zwc} ${XDG_CACHE_HOME:-$HOME/.cache}/prezto/zcomp{cache,dump}
  autoload -Uz compinit && compinit

  zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/prezto/zcompdump"
  compinit -C -d "$zcompdump"
  zcompile "$zcompdump"

  date +%s >| ~/.environment_lastupdate
  printf "\n\n${FX[bold]}${FG[yellow]}%s${FG[none]}${FX[none]}\n" "You will need to reopen a terminal session to benefit from any updates"

} always {
  unfunction updateEnvironment_gitUpdate
  unfunction updateEnvironment_setSshKeys
  unfunction updateEnvironment_updateModules
  unfunction updateEnvironment_setLinks
  unfunction updateEnvironment_installFonts
  unfunction updateEnvironment_addGpgKeys
  unfunction stageTitle
  unfunction subTitle
}

