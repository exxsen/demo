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
echo -e "default-lease-time 600;\nmax-lease-time 7200;\nddns-update-style none;\nauthoritative;\n\nsubnet 192.168.5.0 netmask 255.255.255.240 {\n  range 192.168.5.3 192.168.5.6;\n  option domain-name-servers 192.168.6.2;\n  option domain-name \"au-team.irpo\";\n  option routers 192.168.5.1;\n}" > /etc/dhcp/dhcpd.conf


run "systemctl enable --now dhcpd"

history -w
