#!/usr/bin/env zsh
typeset -A _repos
typeset _checkout_dir _default_repo

zstyle -a ':prezto:module:git-plus' repos '_repos'
zstyle -s ':prezto:module:git-plus' checkout-dir '_checkout_dir'
zstyle -s ':prezto:module:git-plus' default-repo '_default_repo'

typeset -g CHECKOUT_DIR=${${_checkout_dir:-${HOME}}%/}
typeset -g DEFAULT_REPO=${_default_repo:-'github.com'}

for repo linedata in ${(@kv)_repos}; do
  IFS="|" read conn spath <<< ${linedata}
  for i in ${(@s/ /)spath:="*"}; do
    typeset repoPath=${CHECKOUT_DIR}/${repo}/${i}
    cdpath+=(${~repoPath}(N))
  done
done
