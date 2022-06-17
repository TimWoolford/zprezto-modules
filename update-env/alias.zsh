#!/usr/bin/env zsh

alias updateBundle='brew tap homebrew/bundle && brew bundle --file=${ZDOTDIR}/Brewfile'
alias resetBrew='brew bundle cleanup --file=${ZDOTDIR}/Brewfile --force'
