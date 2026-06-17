#!/bin/bash
set -e
set -o history

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
