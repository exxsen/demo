#!/bin/bash
set -e


LAST_CMD_NUM=$(history 1 | awk '{print $1}')


set -o history


if [ ! -z "$LAST_CMD_NUM" ]; then
    PREV_CMD_NUM=$((LAST_CMD_NUM - 1))
    

    set +o history
    history -d $LAST_CMD_NUM  
    history -d $PREV_CMD_NUM  
    set -o history
fi
# ============================================

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
