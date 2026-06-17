#!/bin/bash

set -e
set -o history

run() {
    history -s "$*"
    eval "$*"
}

run "apt-get install -y frr"

history -s "nano /etc/frr/daemons"
sed -i 's/^ospfd=.*/ospfd=yes/' /etc/frr/daemons

run "systemctl enable --now frr"

run "vtysh -c 'configure terminal' -c 'router ospf' -c 'router-id 2.2.2.2' -c 'network 192.168.7.0/27 area 0' -c 'network 10.0.1.0/30 area 0' -c 'exit' -c 'interface gre1' -c 'ip ospf network point-to-point' -c 'ip ospf authentication message-digest' -c 'ip ospf message-digest-key 1 md5 P@ssw0rd' -c 'end' -c 'write memory'"

history -w
