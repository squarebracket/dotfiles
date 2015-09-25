_get_virtualenvs()
{
    local cur
    
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    VENVS=()

    count=0
    for file in ${HOME}/venvs/*/bin/activate
    do
	SOME_VAR=${file#${HOME}/venvs/*}
	APP=${SOME_VAR%*/bin/activate}
	VENVS[$count]=$APP
	count=$(( $count + 1))
    done

    envs="${VENVS[@]}"

    COMPREPLY=( $( compgen -W "${envs}" -- ${cur} ) )

    return 0
}

complete -F _get_virtualenvs vactivate
