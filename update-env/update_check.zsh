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
    local url="$(git -C "${ZDOTDIR}" config --get remote.origin.url)"
    local remote_version="$(git ls-remote "${url}" HEAD | awk '{print $1}')"
    local local_version="$(git -C "${ZDOTDIR}" rev-parse HEAD)"

    local bold=$(tput bold)
    local text_yellow=$(tput setaf 3)
    local reset_formatting=$(tput sgr0)

    if [ "${remote_version}" != "${local_version}" ]; then
        echo "${FX[bold]}${FG[yellow]}Your ${ZDOTDIR} is out of sync${reset_formatting}"
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
    echo "Would you like to check for updates? [Y/n]: \c"
    read line
    if [ "${line}" = "Y" ] || [ "${line}" = "y" ]; then
        updateEnvironment
    fi
  elif [[ time_since_update -gt day_seconds ]]; then
   echo "It has been ${FX[bold]}$((time_since_update / day_seconds))${FX[none]} days since your environment was updated"
   checkForEnvUpdates
  fi
}

{
  startUpdateProcess 6
} always {
  unfunction timeSinceLastUpdate
  unfunction checkForEnvUpdates
  unfunction startUpdateProcess
}
