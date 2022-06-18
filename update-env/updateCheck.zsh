#!/usr/bin/env zsh
typeset -g _UPDATE_ENV_STATUS=0
# 0 - no update
# 1 - over 1 day without check
# 2 - upstream changes detected
# 3 - local changes detected
# 4 - over 7 days without check

function timeSinceLastUpdate {
  typeset -i last_update=0

  [ -f ~/.environment_lastupdate ] && last_update=$(cat ~/.environment_lastupdate)

  echo $(($(date +%s) - last_update))
}

function checkForEnvUpdates {
  local BASE UPSTREAM REMOTE LOCAL
  UPSTREAM=$(git -C "${ZDOTDIR}" rev-parse '@{u}')
  LOCAL=$(git -C "${ZDOTDIR}" rev-parse HEAD)
  REMOTE=$(git -C "${ZDOTDIR}" rev-parse "$UPSTREAM")
  BASE=$(git -C "${ZDOTDIR}" merge-base HEAD "$UPSTREAM")

  if [[ ${REMOTE} == ${LOCAL} ]]; then
    _UPDATE_ENV_STATUS=1
  else
    if [[ ${LOCAL} == ${BASE} ]]; then
      _UPDATE_ENV_STATUS=2
    elif [[ ${REMOTE} == ${BASE} ]]; then
      _UPDATE_ENV_STATUS=3
    else
      _UPDATE_ENV_STATUS=4
    fi

    [[ ${__p9k_instant_prompt_active} ]] || echo "${FX[bold]}${FG[yellow]}Your ${ZDOTDIR} is out of sync${FX[none]}${FG[none]}"
  fi
}

function startUpdateProcess {
  typeset -i updateThresholdDays=${1:-6} \
             day_seconds=$((24 * 60 * 60))
             time_since_update=$(timeSinceLastUpdate)
  typeset -i update_frequency=$((day_seconds * updateThresholdDays))

  if [[ time_since_update -gt update_frequency ]]; then
    _UPDATE_ENV_STATUS=4
    if [[ ! ${__p9k_instant_prompt_active} ]]; then
      echo "${FX[bold]}${FG[red]}Environment not updated for $((time_since_update / day_seconds)) days.${FX[none]}${FG[none]}"
      typeset line
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
