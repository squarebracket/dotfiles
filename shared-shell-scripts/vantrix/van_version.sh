export VANOS_VERSION=`awk '{print $4}' < /etc/vantrix-release`
echo -e " \005{kc}VanOS $VANOS_VERSION\005{= kd}"
