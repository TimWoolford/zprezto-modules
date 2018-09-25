#!/usr/bin/env zsh

function _start_docker_app {
    local app_name=$1
    docker start $app_name > /dev/null

    if [[ $? -eq 0 ]]; then
        echo "$app_name started"
        return 0
    else
        echo "$app_name failed to start"
        return 1
    fi
}

function _stop_docker_app {
    local app_name=$1
    output=$(docker stop --time=10 $app_name 2> /dev/null)

    if [[ $? -eq 0 ]]; then
        echo "$app_name stopped"
        return 0
    else
        echo "$app_name failed to stop"
        return 1
    fi
}

function _clean_docker_app {
    local app_name=$1
    local app_dir=$2

    removeOutput=$(rm -rf $app_dir)
    output=$(docker rm -f $app_name 2> /dev/null)

    if [ $? -eq 0 ]; then
        echo "Cleaned ${app_name}"
        return 0
    else
        echo "No ${app_name} found"
        return 1
    fi
}

function _status_docker_app {
    local app_name=$1
    output=$(docker inspect --format='{{ .State.Status }}' $app_name 2> /dev/null)

    if [[ $? -eq 1 ]]; then
        echo "$app_name does not exist"
    else
        echo "$app_name is $output"
    fi

    return 0
}

function _is_docker_image {
    local app_name=$1
    local size
    local -a imageArray
    IFS=$'\n'
    imageArray=($(docker images | grep ${app}))
    size=${#imageArray[@]}

    echo ${app}
    if [[ ${non_docker_overrides[(r)${app}]} == ${app} ]] ; then
        return 1
    else
        if [ $size -gt 0 ]; then
            return 0
        else
            return 1
        fi
    fi
}