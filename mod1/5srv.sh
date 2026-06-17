#!/bin/bash

set -e
set -o history

run() {
    history -s "$*"
    eval "$*"
}


history -s "nano /etc/openssh/sshd_config"
cat > /etc/openssh/sshd_config <<'EOF'
Port 2024
MaxAuthTries 2
PasswordAuthentication yes
Banner /etc/openssh/bannermotd
AllowUsers  sshuser
EOF

history -s "nano /etc/openssh/bannermotd"
cat > /etc/openssh/bannermotd <<'EOF'
----------------------
Authorized access only
----------------------
EOF

run "systemctl restart sshd"

history -w
