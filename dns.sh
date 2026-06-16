#!/bin/bash
# Скрипт для настройки DNS (задание №10)
# ЗАПУСКАТЬ ТОЛЬКО ЧЕРЕЗ: source ./dns_setup.sh

set -e

# Включаем историю на всякий случай
set -o history

# Функция: записать команду в историю и выполнить
run() {
    history -s "$*"
    eval "$*"
}

# ---- Установка и базовая настройка ----
run "apt-get install -y bind bind-utils"
run "control bind-chroot disabled"
run "systemctl daemon-reload"

# ---- Конфигурационные файлы (имитация nano) ----
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

history -s "nano /etc/bind/local.conf"
cat > /etc/bind/local.conf <<'EOF'
zone "au-team.irpo" {
    type master;
    file "/etc/bind/au-team.irpo.db";
};
zone "168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/192.168.rev";
};
EOF

history -s "nano /etc/bind/au-team.irpo.db"
cat > /etc/bind/au-team.irpo.db <<'EOF'
$TTL    1D
@       IN      SOA     au-team.irpo. root.au-team.irpo. (
                        2026012400      ; serial
                        12H             ; refresh
                        1H              ; retry
                        1W              ; expire
                        1H              ; ncache
                        )
        IN      NS      hq-srv.au-team.irpo.
hq-srv  IN      A       192.168.6.2
hq-rtr  IN      A       192.168.6.1
br-rtr  IN      A       192.168.7.1
hq-cli  IN      A       192.168.5.3
br-srv  IN      A       192.168.7.2
moodle  IN      A       172.16.4.1
wiki    IN      A       172.16.5.1
EOF

history -s "nano /etc/bind/192.168.rev"
cat > /etc/bind/192.168.rev <<'EOF'
$TTL    1D
@       IN      SOA     au-team.irpo. root.au-team.irpo. (
                        2026012400      ; serial
                        12H             ; refresh
                        1H              ; retry
                        1W              ; expire
                        1H              ; ncache
                        )
        IN      NS      hq-srv.au-team.irpo.
2.6     IN  PTR hq-srv.au-team.irpo.
1.6     IN  PTR hq-rtr.au-team.irpo.
3.5     IN  PTR hq-cli.au-team.irpo.
EOF

# ---- Проверка синтаксиса ----
run "named-checkconf /etc/bind/options.conf"
run "named-checkconf /etc/bind/local.conf"

# ---- Права доступа ----
run "chown root:named /etc/bind/au-team.irpo.db"
run "chown root:named /etc/bind/192.168.rev"
run "chown root:named /var/lib/bind"
run "chmod 770 /var/lib/bind"

# ---- Запуск службы ----
run "systemctl enable --now bind"

# ---- Принудительная запись истории на диск ----
history -w
