#!/usr/bin/env zsh

typeset -g  _UPDATE_ENV_DIR=${0:h}
typeset -gi _UPDATE_ENV_STATUS=0
typeset -gi _SESSION_UPDATE_TIME=$(date +%s)
typeset -gi _UPDATE_DAYS

source "${0:h}/alias.zsh"
source "${0:h}/updateCheck.zsh"
