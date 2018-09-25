#!/usr/bin/env zsh

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


source "${0:h}/completion_helpers.zsh"
#source "${0:h}/alias.zsh"

