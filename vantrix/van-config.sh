#!/bin/bash

van-config() {
    local conffile=`_find_conf $1`
    if [ -z $2 ]; then
      # just open it
      vim $conffile
    elif [ -z $3 ]; then
     # get the value
     grep $2 < $conffile | sed 's/.*= \?\(.*\)/\1/'
    else
      # edit the value
      sed -i".bak" "s|$2 \?= \?\(.*\)|$2 = $3|" $conffile
      # .$(date +%Y-%m-%d.%H:%M:%S)
      #echo "not yet implemented"
    fi
}

_get_confs() {
    local confs=""
    if [ -d /etc/opt/spotxde ]; then
        for conf in /etc/opt/spotxde/*.conf
        do
            local temp1=${conf#/etc/opt/spotxde/*}
            local app=${temp1%*.conf}
            local confs="$confs $app"
            unset temp1
            echo $confs
        done
    fi
    
    if [ -d /var/opt/spotxde ]; then
        for conf in /var/opt/spotxde/*/conf/*/conf/*.conf
        do
            local temp1=${conf#/var/opt/spotxde/*}
            local app=${temp1%*/conf/*/conf/*.conf}

            local temp2=${temp1#*/conf/*}
            local instance=${temp2%*/conf/*.conf}

            local conf_file=${temp2#*/conf/*}
            if [ "$conf_file" = "$app.conf" ]; then
                confs="$confs $app/$instance"
            fi
        done
    fi

    if [ ! "$confs" = "" ]; then
        echo $confs
        return 0
    fi
    return 1
}

_find_conf() {
    if [ -z "$1" ]; then
        return 1
    fi
    local app=${1%*/*}
    local instance=${1#*/*}
    if [ "$app" = "$instance" ]; then
        # there is no instance; should be in /etc/opt/spotxde
        local confstring="/etc/opt/spotxde/$app.conf"
    else
        # it has a particular instance
        local confstring="/var/opt/spotxde/$app/conf/$instance/conf/$app.conf"
    fi
    stat $confstring &> /dev/null
    if [ $? -eq 0 ]; then
        # conf was found
        echo $confstring
        return 0
    else
        return 1
    fi
}

_get_config_keys() {
    if [ -z "$1" -o ! -f "$1" ]; then
        return 1
    fi
    grep "^[^#].* \?= \?.*" < $1 | sed 's/\(.*\) \?= \?\(.*\)/\1/'
    return 0
}

_complete_van-config() {
    COMPREPLY=()
    local cur="${COMP_WORDS[COMP_CWORD]}"
    if [ "$COMP_CWORD" = 1 ]; then
        local confs=`_get_confs`
        COMPREPLY=( $( compgen -W "${confs}" -- ${cur} ) )
    elif [ "$COMP_CWORD" -eq 2 ]; then
        conf="${COMP_WORDS[1]}"
        conffile=`_find_conf $conf`
        keys=`_get_config_keys $conffile`
        COMPREPLY=( $( compgen -W "${keys}" -- ${cur} ) )
    fi

    return 0
}

complete -F _complete_van-config van-config
