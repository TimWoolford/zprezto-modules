if [[ ! ${commands[kubectl]} ]]; then
  return 1;
fi

source "${0:h}/aliases.zsh"
if ! (whence _kubectl > /dev/null); then
  source <(kubectl completion zsh)
fi
