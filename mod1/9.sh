#!/bin/bash


set -e
set -o history

run() {
    history -s "$*"
    eval "$*"
}

run "apt-get install -y dhcp-server"

history -s "nano /etc/sysconfig/dhcpd"
echo "DHCPDARGS=ens37" > /etc/sysconfig/dhcpd

run "cp /etc/dhcp/dhcpd.conf.sample /etc/dhcp/dhcpd.conf"


history -s "nano /etc/dhcp/dhcpd.conf"
cat > /etc/dhcp/dhcpd.conf <<'EOF'
default-lease-time 600;
max-lease-time 7200;
ddns-update-style none;
authoritative;

subnet 192.168.5.0 netmask 255.255.255.240 {
  range 192.168.5.3 192.168.5.6;
  option domain-name-servers 192.168.6.2;
  option domain-name "au-team.irpo";
  option routers 192.168.5.1;
}
EOF

run "systemctl enable --now dhcpd"

history -w
