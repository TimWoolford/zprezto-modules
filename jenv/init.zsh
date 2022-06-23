#!/usr/bin/env zsh

if (( ${path[(Ie).]} )); then
 path=(. "${HOME}/.jenv/shims" "${path[@]}")
else
  path=("${HOME}/.jenv/shims" "${path[@]}")
fi

export JENV_SHELL=zsh
export JENV_LOADED=1
unset JAVA_HOME
