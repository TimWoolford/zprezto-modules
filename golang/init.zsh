export GOPATH=${HOME}/go:${HOME}/projects

function go {
  local go_exec=`whence -p go`
  if [ "$1" = "get" ]; then
		GOPATH=$HOME/projects ${go_exec} "$@"
	else
		${go_exec} "$@"
	fi
}