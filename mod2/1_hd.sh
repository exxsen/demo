#!/bin/bash


set -e
set -o history

run() {
    history -s "$*"
    eval "$*"
}


run "apt-get install -y realmd sssd adcli"


history -s "nano /etc/resolv.conf"
cat > /etc/resolv.conf <<'EOF'
nameserver 192.168.7.2
search au-team.irpo
EOF


run "realm join --user=Administrator au-team.irpo"


history -s "nano /etc/sudoers.d/hq_users"
cat > /etc/sudoers.d/hq_users <<'EOF'
%hq ALL=(ALL) NOPASSWD: /usr/bin/cat, /usr/bin/grep, /usr/bin/id
EOF

run "chmod 440 /etc/sudoers.d/hq_users"
run "chmod 4755 /usr/bin/sudo"


history -s "nano /etc/pam.d/system-auth"

grep -q "pam_mkhomedir.so" /etc/pam.d/system-auth || echo "session optional pam_mkhomedir.so skel=/etc/skel umask=0022" >> /etc/pam.d/system-auth

history -w
