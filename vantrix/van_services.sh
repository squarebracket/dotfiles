ps -C puppet,puppetmasterless,puppetmasterful > /dev/null || ps -ef | grep -i agent_postinstall | grep -v grep > /dev/null
PUPPET_ACTIVE=$?
if [ $PUPPET_ACTIVE -eq 0 ]; then
    #echo -e "\005{G}[\005{-} \005{bw}Applying Puppet\005{-} \005{G}]\005{-}"
    echo -e "\005{bw} Applying Puppet\005{kb} \005{kd}\005{-}"
fi

#grep Error < ~/agent-post.log > /dev/null
#ERROR_IN_PROVISION=$?
#if [ $ERROR_IN_PROVISION -eq 0 ]; then
    #echo -e "\005{RW}PUPPET ERROR\005{kR}\005{kd}"
#fi

# TODO: Make a case for when a service is active but not enabled
LTRX_STATUS=`service ltrx status | grep -i pid | awk '{print $6;}'`
services="ltrx rmss esg mpc mpcms hms vta oamgui vrm ingm rabbitmq-server"
SERVICES_OUTPUT=""
for i in $services; do
	ENABLED_OUTPUT=`systemctl is-enabled $i`
	ENABLED=$?
	systemctl is-active $i > /dev/null
	ACTIVE=$?
	systemctl is-failed $i > /dev/null
	FAILED=$?
	#export LOADED=`systemctl status $i | grep -i loaded | awk '{print $2}'`
	#export ACTIVE=`systemctl status $i | grep -i active | awk '{print $2}'`
	if [ $ACTIVE = 0 ]; then
		# Service is operational
		SERVICES_OUTPUT="$SERVICES_OUTPUT \005{g}$i\005{-}"
	elif [ $ENABLED = 1 ]; then
		# Service is not enabled on this machine
		SERVICES_OUTPUT="$SERVICES_OUTPUT"
	elif [ $ENABLED = 0 -a $FAILED = 0 ]; then
		# Service is in failed state!!
		SERVICES_OUTPUT="$SERVICES_OUTPUT \005{b r}$i\005{-}"
    #elif [ $ENABLED = 0 -a $ENABLED_OUTPUT = 'static' ]; then
        ## Service is set to 'static'
        ##SERVICES_OUTPUT="$SERVICES_OUTPUT \005{G}$i\005{-}"
        #SERVICES_OUTPUT="$SERVICES_OUTPUT"
	else
		# Service is in weird / unknown state
		SERVICES_OUTPUT="$SERVICES_OUTPUT \005{y}$i\005{-}"
	fi
done


GLUSTER_OUTPUT=""
GLUSTER_MOUNTS=`systemctl list-units | grep mnt-gv | awk '{print $5}'| sed s/^.mnt.//`
GLUSTER_VOLS=`gluster volume list`
for i in $GLUSTER_MOUNTS; do
    FREE=`df -h | grep $i | awk '{print $5}' | sed s/.$//`
    if [ $FREE -lt 90 ]; then
        GLUSTER_OUTPUT="$GLUSTER_OUTPUT \005{g}$i ($FREE%)\005{-}"
    elif [ $FREE -gt 98 ]; then
        GLUSTER_OUTPUT="$GLUSTER_OUTPUT \005{b R}$i ($FREE%)\005{-}"
    else
        GLUSTER_OUTPUT="$GLUSTER_OUTPUT \005{y}$i ($FREE%)\005{-}"
    fi
done


MONGO_OUTPUT=""
systemctl is-enabled mongod > /dev/null
ENABLED=$?
systemctl is-active mongod > /dev/null
ACTIVE=$?
systemctl is-failed mongod > /dev/null
FAILED=$?
if [ $ENABLED = 0 ]; then
    if [ $ACTIVE = 0 ]; then
        STATUS=`mongo --quiet --eval 'printjson(db.isMaster()["ismaster"])'`
        if [ $STATUS = 'true' ]; then
            MONGO_OUTPUT="\005{kg}MONGO: \005{g}PRI\005{-}"
        else
            MONGO_OUTPUT="\005{kg}MONGO: \005{y}SEC\005{-}"
        fi
    elif [ $FAILED = 0 ]; then
        MONGO_OUTPUT="\005{b r}MONGO\005}{-}"
    else
        MONGO_OUTPUT="\005{G}MONGO\005{-}"
    fi
fi

JMETER_OUTPUT=""
# /opt/slingshot is created only if this is a requester, so see if we have it
if [ -d /opt/slingshot ]; then
    # Is slingshot running?
    ps -ef | grep slingshot -v grep
    SLINGSHOT_ACTIVE=$?
    if [ $SLINGSHOT_ACTIVE -eq 0 ]; then
        JMETER_OUTPUT="\005{G}[ \005{g}slingshot\005{-} \005{G}]"
    else
        JMETER_OUTPUT="\005{G}[ \005{b r}slingshot\005{-} \005{G}]"
    fi
fi

OUTPUT=''

HOSTNAME=`hostname`
if [ $HOSTNAME = "chuck.local" ]; then
    colors="k K r R g G y Y b B m M c C w W"
    for i in $colors; do
        OUTPUT="$OUTPUT\005{$i}$i"
    done
    OUTPUT="$OUTPUT\005{-}"
fi


#if [ ! -z "$SERVICES_OUTPUT" ]; then
    #OUTPUT="$OUTPUT\005{G}[\005{-}$SERVICES_OUTPUT \005{G}]\005{-}"
#fi

#if [ ! -z "$GLUSTER_OUTPUT" ]; then
    #OUTPUT="$OUTPUT\005{G}[\005{-} $GLUSTER_OUTPUT \005{G}]\005{-}"
#fi

#if [ ! -z "$MONGO_OUTPUT" ]; then
    #OUTPUT="$OUTPUT\005{G}[\005{-} $MONGO_OUTPUT \005{G}]\005{-}"
#fi

#if [ ! -z "$JMETER_OUTPUT" ]; then
    #OUTPUT="$OUTPUT$JMETER_OUTPUT"
#fi


if [ ! -z "$SERVICES_OUTPUT" ]; then
    OUTPUT="$OUTPUT$SERVICES_OUTPUT \005{G}\005{-} "
fi

if [ ! -z "$GLUSTER_OUTPUT" ]; then
    OUTPUT="$OUTPUT$GLUSTER_OUTPUT \005{G}\005{-} "
fi

if [ ! -z "$MONGO_OUTPUT" ]; then
    OUTPUT="$OUTPUT$MONGO_OUTPUT \005{G}\005{-} "
fi

if [ ! -z "$JMETER_OUTPUT" ]; then
    OUTPUT="$OUTPUT$JMETER_OUTPUT"
fi

echo -e "$OUTPUT"
