#!/bin/bash

set -e
set -o history

run() {
    history -s "$*"
    eval "$*"
}

run "mkdir -p /etc/net/ifaces/gre1"

history -s "nano /etc/net/ifaces/gre1/options"
echo -e "TYPE=iptun\nTUNTYPE=gre\nTUNLOCAL=172.16.4.2\nTUNREMOTE=172.16.5.2\nTUNOPTIONS='ttl 64'\nDISABLED=no" > /etc/net/ifaces/gre1/options


history -s "nano /etc/net/ifaces/gre1/ipv4address"
echo "10.0.1.1/30 peer 10.0.1.2" > /etc/net/ifaces/gre1/ipv4address

run "ifup gre1"

history -w
