
if [[ ! ${commands[docker-buildx]} ]]; then
  return 1
fi

conf_file="${HOME}/.docker/config.json"

if [[ -e "${conf_file}" ]]; then
  cat "${conf_file}" | jq '.cliPluginsExtraDirs |= (.+ [ "'"$(brew --prefix)"'/lib/docker/cli-plugins" ] | unique)' >| "${conf_file}"
fi