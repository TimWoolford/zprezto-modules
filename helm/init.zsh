#!/usr/bin/env zsh

if [[ ! ${commands[helm]} ]]; then
  return 1
fi

if ! (whence _helm > /dev/null); then
  source <(helm completion zsh)
fi
