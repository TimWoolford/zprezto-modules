#!/usr/bin/env zsh

alias resetCompletions='rm -f ${ZDOTDIR}/.zcompdump*; compinit'
alias resetBrew='brew bundle cleanup --file=${ZDOTDIR}/Brewfile --force'