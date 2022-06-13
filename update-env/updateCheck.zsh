#!/usr/bin/env zsh
typeset -g _UPDATE_ENV_STATUS=0
# 0 - no update
# 1 - over 1 day without check
# 2 - upstream changes detected
# 3 - over 7 days without check

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
  local UPSTREAM remoteVersion localVersion
  UPSTREAM=$(git -C "${ZDOTDIR}" rev-parse '@{u}')
  localVersion=$(git -C "${ZDOTDIR}" rev-parse HEAD)
  remoteVersion=$(git -C "${ZDOTDIR}" rev-parse "$UPSTREAM")

  if [ "${remoteVersion}" != "${localVersion}" ]; then
    _UPDATE_ENV_STATUS=2
    [[ ${__p9k_instant_prompt_active} ]] || echo "${FX[bold]}${FG[yellow]}Your ${ZDOTDIR} is out of sync${FX[none]}${FG[none]}"
  fi
}

function startUpdateProcess {
  local updateThresholdDays=${1:-6}
  local day_seconds=$((24 * 60 * 60))
  local update_frequency=$((day_seconds * updateThresholdDays))
  local time_since_update line

  time_since_update=$(timeSinceLastUpdate)
  if [[ time_since_update -gt update_frequency ]]; then
    _UPDATE_ENV_STATUS=3
    if [[ ! ${__p9k_instant_prompt_active} ]]; then
      echo "${FX[bold]}${FG[red]}Environment not updated for $((time_since_update / day_seconds)) days.${FX[none]}${FG[none]}"
      vared -p "Would you like to check for updates? [Y/n]: " -c line
      if [[ "${line}" =~ ^(Y|y)$ ]]; then
        updateEnvironment
      else
        printf "\n${FG[red]}%s${FG[none]}\n\n" "You have annoyed the monkey!"
      fi
    fi
  elif [[ time_since_update -gt day_seconds ]]; then
    _UPDATE_ENV_STATUS=1
    [[ ${__p9k_instant_prompt_active} ]] || echo "It has been ${FX[bold]}$((time_since_update / day_seconds))${FX[none]} days since your environment was updated"
    checkForEnvUpdates
  fi
}

{
  typeset -g _UPDATE_ENV_DIR=${0:h}
  startUpdateProcess 6
} always {
  unfunction timeSinceLastUpdate
  unfunction checkForEnvUpdates
  unfunction startUpdateProcess
}
