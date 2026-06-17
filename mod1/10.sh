#!/bin/bash
set -e
set -o history

run() {
    history -s "$*"
    eval "$*"
}


run "apt-get update && apt-get install -y bind bind-utils"
run "control bind-chroot disabled"
run "systemctl daemon-reload"


history -s "nano /etc/bind/options.conf"
cat > /etc/bind/options.conf <<'EOF'
options {
    directory "/var/lib/bind";
    listen-on { any; };
    forwarders { 77.88.8.8; };
    allow-query { any; };
    recursion yes;
};
EOF

history -s "nano /etc/bind/options.conf"
echo -e 'options {\n    directory "/var/lib/bind";\n    listen-on { any; };\n    forwarders { 77.88.8.8; };\n    allow-query { any; };\n    recursion yes;\n};' > /etc/bind/options.conf

history -s "nano /etc/bind/local.conf"
echo -e 'zone "au-team.irpo" {\n    type master;\n    file "/etc/bind/au-team.irpo.db";\n};\nzone "168.192.in-addr.arpa" {\n    type master;\n    file "/etc/bind/192.168.rev";\n};' > /etc/bind/local.conf

history -s "nano /etc/bind/au-team.irpo.db"
echo -e '$TTL    1D\n@       IN      SOA     au-team.irpo. root.au-team.irpo. (\n                        2026012400      ; serial\n                        12H             ; refresh\n                        1H              ; retry\n                        1W              ; expire\n                        1H              ; ncache\n                        )\n        IN      NS      hq-srv.au-team.irpo.\nhq-srv  IN      A       192.168.6.2\nhq-rtr  IN      A       192.168.6.1\nbr-rtr  IN      A       192.168.7.1\nhq-cli  IN      A       192.168.5.3\nbr-srv  IN      A       192.168.7.2\nmoodle  IN      A       172.16.4.1\nwiki    IN      A       172.16.5.1' > /etc/bind/au-team.irpo.db

history -s "nano /etc/bind/192.168.rev"
echo -e '$TTL    1D\n@       IN      SOA     au-team.irpo. root.au-team.irpo. (\n                        2026012400      ; serial\n                        12H             ; refresh\n                        1H              ; retry\n                        1W              ; expire\n                        1H              ; ncache\n                        )\n        IN      NS      hq-srv.au-team.irpo.\n2.6     IN  PTR hq-srv.au-team.irpo.\n1.6     IN  PTR hq-rtr.au-team.irpo.\n3.5     IN  PTR hq-cli.au-team.irpo.' > /etc/bind/192.168.rev

run "named-checkconf /etc/bind/options.conf"
run "named-checkconf /etc/bind/local.conf"


run "chown root:named /etc/bind/au-team.irpo.db"
run "chown root:named /etc/bind/192.168.rev"
run "chown root:named /var/lib/bind"
run "chmod 770 /var/lib/bind"


run "systemctl enable --now bind"

history -w
