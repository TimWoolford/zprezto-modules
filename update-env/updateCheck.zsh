#!/usr/bin/env zsh

function timeSinceLastUpdate {
    local last_update

    if [ -f ~/.environment_lastupdate ]; then
        last_update=$(cat ~/.environment_lastupdate)
    else
        last_update=0
    fi
    echo $(($(date +%s) - last_update))
}

function checkForEnvUpdates {
    local url remoteVersion localVersion
    url="$(git -C "${ZDOTDIR}" config --get remote.origin.url)"
    remoteVersion="$(git ls-remote "${url}" HEAD | awk '{print $1}')"
    localVersion="$(git -C "${ZDOTDIR}" rev-parse HEAD)"

    if [ "${remoteVersion}" != "${localVersion}" ]; then
        echo "${FX[bold]}${FG[yellow]}Your ${ZDOTDIR} is out of sync${FX[none]}${FG[none]}"
    fi
}

function startUpdateProcess {
  local updateThresholdDays=${1:-6}
  local day_seconds=$((24 * 60 * 60))
  local update_frequency=$((day_seconds * updateThresholdDays))
  local time_since_update line

  time_since_update=$(timeSinceLastUpdate)
  if [[ time_since_update -gt update_frequency ]]; then
    echo "${FX[bold]}${FG[red]}Environment not updated for $((time_since_update / day_seconds)) days.${FX[none]}${FG[none]}"
    vared -p "Would you like to check for updates? [Y/n]: " -c line
    if [[ "${line}" =~ ^(Y|y)$ ]]; then
      updateEnvironment
    else
      printf "\n${FG[red]}%s${FG[none]}\n\n" "You have annoyed the monkey!"
    fi
  elif [[ time_since_update -gt day_seconds ]]; then
    echo "It has been ${FX[bold]}$((time_since_update / day_seconds))${FX[none]} days since your environment was updated"
    checkForEnvUpdates
  fi
}

{
  typeset -g UPDATE_ENV_DIR=${0:h}
  startUpdateProcess 6
} always {
  unfunction timeSinceLastUpdate
  unfunction checkForEnvUpdates
  unfunction startUpdateProcess
}
