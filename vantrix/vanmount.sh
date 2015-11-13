if [ -z "$1" ]; then
    echo "Need to supply system. Valid systems are: soak, ui, char"
    exit 1
fi
if [ "$1" = "ui" ]; then
    subnet="103"
elif [ "$1" = "soak" ]; then
    subnet="109"
elif [ "$1" = "char" ]; then
    subnet="107"
else
    echo "Invalid system supplied. Valid systems are: soak, ui, char"
fi
mount_point="$1"
sudo sshfs -o allow_other -o IdentityFile=~/.ssh/id_rsa.pub root@10.104.$subnet.2:/ /media/$mount_point
