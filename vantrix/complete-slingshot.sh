#!/bin/bash

_complete_slingshot()
{
    local cur

    opts="--help --jmeter --test-plans-folder --properties-folder --log-folder --memory-allocation --log-level --test-id-filter --context"
    folder_opts="--test-plans-folder --properties-folder --log-folder"
    file_opts="--jmeter --context"
    log_levels="CRITICAL ERROR WARNING INFO DEBUG"
    tests=`ls var/*.jmx 2> /dev/null | sed 's_var/\(.*\)\.jmx_\1_' || ''`

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ $opts =~ $prev ]]; then
        # completion for specific options
        if [ "$prev" == "--log-level" ]; then
            COMPREPLY=( $(compgen -W "${log_levels}" -- ${cur}) )
            return 0
        elif [ "$prev" == "--test-id-filter" ]; then
            COMPREPLY=( $(compgen -W "${tests}" -- ${cur}) )
            return 0
        elif [[ $folder_opts =~ $prev ]]; then
            compopt -o nospace
            COMPREPLY=( $(compgen -A directory ${cur}) )
            return 0
        elif [[ $file_opts =~ $prev ]]; then
            COMPREPLY=( $(compgen -f ${cur}) )
            return 0
        fi
    elif [[ $cur == -* ]]; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
}

complete -F _complete_slingshot slingshot
