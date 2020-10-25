typeset -gA REPOS

zstyle -a ':prezto:module:git-plus' repos 'REPOS'
zstyle -s ':prezto:module:git-plus' checkout-dir '_checkout_dir'
zstyle -s ':prezto:module:git-plus' default-repo '_default_repo'

typeset -g CHECKOUT_DIR=${_checkout_dir:-${HOME}}
typeset -g DEFAULT_REPO=${_default_repo:-'github.com'}

for repo linedata in ${(@kv)REPOS}; do
  IFS="|" read conn spath <<< ${linedata}
  for i in ${(@s/ /)spath:="*"}; do
    local repoPath=${_checkout_dir}/${repo}/${i}
    if [[ -n `echo ${~repoPath}(NY1)` ]]; then
      cdpath+=(${~repoPath})
    fi
  done
done
