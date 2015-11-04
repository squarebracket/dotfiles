if [ -z "$1" ]; then
    echo "Need to supply system. Valid systems are: soak, ui"
    exit 1
fi
if [ "$1" = "ui" ]; then
    subnet="103"
    mount_point="ui"
elif [ "$1" = "soak" ]; then
    subnet="109"
    mount_point="soak"
fi
sudo sshfs -o allow_other -o IdentityFile=~/.ssh/id_rsa.pub root@10.104.$subnet.2:/ /media/$mount_point
