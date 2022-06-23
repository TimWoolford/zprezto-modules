#!/usr/bin/env zsh
# 0 - no update
# 1 - over 1 day without check
# 2 - upstream changes detected
# 3 - local changes detected
# 4 - over 7 days without check

function daysSinceLastUpdate {
  typeset -i lastUpdate=0 daySeconds=$((24 * 60 * 60))

  [ -f ~/.environment_lastupdate ] && lastUpdate=$(cat ~/.environment_lastupdate)

  echo $(( ($(date +%s) - lastUpdate) / daySeconds))
}

function startUpdateProcess {
  typeset -i errorThresholdDays=${1:-6} \
             warnThresholdDays=${2:-1}

    _UPDATE_DAYS=$(daysSinceLastUpdate)

  if [[ _UPDATE_DAYS -ge errorThresholdDays ]]; then
    if [[ ! ${__p9k_instant_prompt_active} ]]; then
      echo "${FX[bold]}${FG[red]}Environment not updated for ${_UPDATE_DAYS} days.${FX[none]}${FG[none]}"
      typeset line
      vared -p "Would you like to check for updates? [Y/n]: " -c line
      if [[ "${line}" =~ ^(Y|y)$ ]]; then
        updateEnvironment
      else
        printf "\n${FG[red]}%s${FG[none]}\n\n" "You have annoyed the monkey!"
      fi
    else
      _UPDATE_ENV_STATUS=$(checkForEnvUpdates)
      [[ ${__p9k_instant_prompt_active} && $_UPDATE_ENV_STATUS == 0 ]] || echo "${FX[bold]}${FG[yellow]}Your ${ZDOTDIR} is out of sync${FX[none]}${FG[none]}"
    fi
  elif [[ _UPDATE_DAYS -ge warnThresholdDays ]]; then
    _UPDATE_ENV_STATUS=$(checkForEnvUpdates)
    [[ ${__p9k_instant_prompt_active} ]] || echo "It has been ${FX[bold]}${_UPDATE_DAYS}${FX[none]} days since your environment was updated"
  fi
}

{
  startUpdateProcess 6
} always {
  unfunction daysSinceLastUpdate
  unfunction startUpdateProcess
}
