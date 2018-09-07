if [ ! $commands[helm] ]; then
  return 1
fi

source <(helm completion zsh)
