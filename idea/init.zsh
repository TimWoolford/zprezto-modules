#!/usr/bin/env zsh

if [[ ! ${commands[idea]} ]]; then
  autoload -Uz "${0:h}/fn/idea"
fi