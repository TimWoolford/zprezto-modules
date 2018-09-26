function _print_if_no_pipe {
    if [ -t 1 ]; then
        echo $@
    fi
}

function _run_shoehorn {
    zstyle -s ':prezto:module:shoehorn' version '_shoehorn_version'
    local shoehorn_filename="shoehorn-${_shoehorn_version}-jar-with-dependencies.jar"
    local shoehorn_jar_path="${TMPDIR}/${shoehorn_filename}"
    echo $shoehorn_jar_path
    _print_if_no_pipe "$FX[bold]$FG[yellow]Using Shoehorn version ${_shoehorn_version}$FG[white]$FX[no-bold]"

    if [ ! -f ${shoehorn_jar_path} ]; then
        _print_if_no_pipe "$FX[bold]$FG[yellow]Downloading Shoehorn...$FG[white]$FX[no-bold]"
        curl -s "${_ARTIFACTORY}/${_ARTIFACTORY_REPOSITORY}/sonique/shoehorn/shoehorn/${_shoehorn_version}/${shoehorn_filename}" -o ${shoehorn_jar_path}
        _print_if_no_pipe "$FX[bold]$FG[yellow]Done$FG[white]$FX[no-bold]"
    fi

    java -cp ${shoehorn_jar_path} $@
}

function _is_in_docker_repo {
    local app="$1"

    echo ${app}
    if [[ ${non_docker_overrides[(r)${app}]} == ${app} ]] ; then
        return 1
    else
        local response=$(curl --write-out %{http_code} --silent --output /dev/null "${_ARTIFACTORY}/docker-local/sns-is-dev/${app}")
        if [[ ${response} -eq '404' ]]; then
            return 1
        else
            return 0
        fi
    fi
}

function _shoehorn_local {
    local goal="$1"
    local app="$2"
    local version="${3#*-}"
    local env="${3%%-*}"

    shoehorn ${goal} ${app} ${version} ${env}
}


function encrypt {
    _run_shoehorn shoehorn.Encrypt $@
}

function decrypt {
    _run_shoehorn shoehorn.Decrypt $@
}
