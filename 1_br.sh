#!/bin/bash


set -e
set -o history

run() {
    history -s "$*"
    eval "$*"
}


run "apt-get install -y samba-dc samba-client"


run "rm -f /etc/samba/smb.conf"


run "samba-tool domain provision --use-rfc2307 --realm=AU-TEAM.IRPO --domain=AU-TEAM --server-role=dc --dns-backend=SAMBA_INTERNAL --adminpass='P@ssw0rd123'"


run "systemctl enable --now samba.service"


run "samba-tool group add hq"


for i in {1..5}; do
    run "samba-tool user create user$i.hq 'P@ssw0rd'"
    run "samba-tool group addmembers hq user$i.hq"
done


if [ -f /opt/users.csv ]; then
    history -s "while IFS=, read -r name pass; do samba-tool user create \"\$name\" \"\$pass\"; samba-tool group addmembers hq \"\$name\"; done < /opt/users.csv"
    while IFS=, read -r name pass; do
        samba-tool user create "$name" "$pass"
        samba-tool group addmembers hq "$name"
    done < /opt/users.csv
else
    echo "Файл /opt/users.csv не найден, пропускаем импорт."
fi

history -w
