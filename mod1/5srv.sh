#!/bin/bash

set -e
set -o history

run() {
    history -s "$*"
    eval "$*"
}


history -s "nano /etc/openssh/sshd_config"
echo -e "Port 2024\nMaxAuthTries 2\nPasswordAuthentication yes\nBanner /etc/openssh/bannermotd\nAllowUsers  sshuser" > /etc/openssh/sshd_config

history -s "nano /etc/openssh/bannermotd"
echo -e "----------------------\nAuthorized access only\n----------------------" > /etc/openssh/bannermotd

run "systemctl restart sshd"


history -w
