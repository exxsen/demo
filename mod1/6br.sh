#!/bin/bash

set -e
set -o history

run() {
    history -s "$*"
    eval "$*"
}

run "mkdir -p /etc/net/ifaces/gre1"

history -s "nano /etc/net/ifaces/gre1/options"
cat > /etc/net/ifaces/gre1/options <<'EOF'
TYPE=iptun
TUNTYPE=gre
TUNLOCAL=172.16.5.2
TUNREMOTE=172.16.4.2
TUNOPTIONS='ttl 64'
DISABLED=no
EOF

history -s "nano /etc/net/ifaces/gre1/ipv4address"
echo "10.0.1.2/30 peer 10.0.1.1" > /etc/net/ifaces/gre1/ipv4address

run "ifup gre1"

history -w
