#!/bin/bash

PASSFILE=~/.credentials/.vantrix-password
PUBKEY=`cat ~/.ssh/id_rsa.pub`
HOSTS="10.104.103.2 10.104.103.11 10.104.103.12 10.104.103.13 10.104.103.14 10.104.103.15 10.104.109.2 10.104.109.19 10.104.109.20 10.104.109.21 10.104.109.22 10.104.109.23 10.104.109.24 10.104.109.25 10.104.109.26 10.104.109.27 10.104.109.28 10.104.109.29 10.104.107.2 10.104.107.9 10.104.107.12 10.104.107.13 10.104.107.14"

for host in $HOSTS; do
    echo $host
    ssh-keygen -R $host
    sshpass -f $PASSFILE ssh -o StrictHostKeyChecking=no root@$host -t "echo '$PUBKEY' >> ~/.ssh/authorized_keys"
    scp ~/dotfiles/vantrix/van_version.sh root@$host:/root/.van_version.sh
    scp ~/dotfiles/vantrix/van_services.sh root@$host:/root/.van_services.sh
    scp ~/dotfiles/vantrix/.screenrc-chuck root@$host:/root/.screenrc-chuck
done
