#!/usr/bin/env zsh
typeset -a plugins
zstyle -a ":prezto:module:jenv" plugins "plugins"

mkdir -p ${HOME}/.jenv/{plugins,shims,versions}

for link in "${HOME}/.jenv/versions"/*(N) ; do
  if [[ -L ${link} ]]; then
    [[ -e ${link} ]] || rm "${link}"
  fi
done

for jh in /Library/Java/JavaVirtualMachines/*/Contents/Home ; do
  jenv add "${jh}"
done

for installed in "${HOME}/.jenv/plugins"/*(N); do
  if (( ! ${plugins[(Ie)${installed:t}]} )); then
    jenv disable-plugin "${installed:t}"
  fi
done

for plugin in "${plugins[@]}"; do
  [[ -e "${HOME}/.jenv/plugins/${plugin}" ]] || jenv enable-plugin "${plugin}"
done

unset plugins

jenv rehash 2>/dev/null
jenv refresh-plugins
