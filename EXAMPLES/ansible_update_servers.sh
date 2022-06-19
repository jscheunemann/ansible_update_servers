#!/usr/bin/env bash

if [ ${EUID} -eq "0" ]; then
    echo "This script must be ran as a non-root user"
    exit 0
fi

SCRIPT_FULL_PATH=$(realpath ${0})
SCRIPT_FILENAME=$(basename ${0})
SCRIPT_FRIENDLY_NAME=${SCRIPT_FILENAME%.*}

if [ $(command -v tmux | wc -l) -gt 0 ]; then
    if [ -z ${TMUX} ]; then
        if [ $(tmux ls 2> /dev/null | grep -wc ${SCRIPT_FRIENDLY_NAME}) -eq 0 ]; then
            tmux new -s ${SCRIPT_FRIENDLY_NAME} ${SCRIPT_FULL_PATH} ${@}
	    exit 0
        else
            tmux attach -t ${SCRIPT_FRIENDLY_NAME}
	    exit 0
        fi
    fi
else
    echo "Consider installing tmux for better session control, continuing..."
fi

mkdir -p ${HOME}/${SCRIPT_FRIENDLY_NAME}_logs

exec &> >(tee "${HOME}/${SCRIPT_FRIENDLY_NAME}_logs/${SCRIPT_FRIENDLY_NAME}_$(date +%Y_%m_%d).log")

echo "Executed $(date)"

ansible-playbook -i ${HOME}/ansible/hosts ${HOME}/ansible_update_servers/os-updates.yml --become

if [ $(tmux list-clients | wc -l) -gt 0 ]; then
    read -p "Operation complete, press [enter] to continue "
fi
