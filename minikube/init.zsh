
if (( ! $+commands[minikube] )); then
    return 1
fi


if zstyle -t ':prezto:module:minikube' use-minikube-docker ; then
    function _get_minikube_status {
        ret=$( minikube status --format "{{ .MinikubeStatus }}" )
        print $ret
    }
    function _minikube_callback {
        if [[ $3 == "Running" ]]; then
            source <(minikube docker-env)
        fi
    }

    async_init

    async_start_worker minikube_worker -n

    async_register_callback minikube_worker _minikube_callback
    async_job minikube_worker _get_minikube_status
fi
