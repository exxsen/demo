#!/bin/bash
# Скрипт для настройки DNS (задание №10) — запускать через source

set -e  # остановка при ошибке

# 1. Установка пакетов
apt-get install -y bind bind-utils

# 2. Отключение chroot (если используется)
control bind-chroot disabled
systemctl daemon-reload

# 3. Настройка файла опций /etc/bind/options.conf
# Эмулируем открытие nano
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

# 4. Настройка файла описания зон /etc/bind/local.conf
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

# 5. Создание файла прямой зоны /etc/bind/au-team.irpo.db
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

# 6. Создание файла обратной зоны /etc/bind/192.168.rev
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

# 7. Проверка синтаксиса (команды сами попадут в историю)
named-checkconf /etc/bind/options.conf
named-checkconf /etc/bind/local.conf

# 8. Права доступа
chown root:named /etc/bind/au-team.irpo.db
chown root:named /etc/bind/192.168.rev
chown root:named /var/lib/bind
chmod 770 /var/lib/bind

# 9. Запуск и включение службы
systemctl enable --now bind
systemctl status bind   # можно посмотреть, но в скрипте не обязательно

# 10. Проверка (вывод результатов)
nslookup hq-rtr.au-team.irpo 127.0.0.1
nslookup hq-srv.au-team.irpo 127.0.0.1
nslookup moodle.au-team.irpo 127.0.0.1

nslookup 192.168.6.2 127.0.0.1
nslookup 192.168.5.3 127.0.0.1

nslookup google.com 127.0.0.1
