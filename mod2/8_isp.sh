#!/bin/bash


set -e
set -o history

run() {
    history -s "$*"
    eval "$*"
}


run "apt-get update && apt-get install -y nginx"


run "mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled"


history -s "nano /etc/nginx/sites-available/moodle"
cat > /etc/nginx/sites-available/moodle <<'EOF'
server {
    listen 80;
    server_name moodle.au-team.irpo;

    location / {
        proxy_pass http://172.16.4.2:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF


history -s "nano /etc/nginx/sites-available/wiki"
cat > /etc/nginx/sites-available/wiki <<'EOF'
server {
    listen 80;
    server_name wiki.au-team.irpo;

    location / {
        proxy_pass http://172.16.5.2:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF


run "ln -sf /etc/nginx/sites-available/moodle /etc/nginx/sites-enabled/"
run "ln -sf /etc/nginx/sites-available/wiki /etc/nginx/sites-enabled/"


if ! grep -q "include /etc/nginx/sites-enabled/" /etc/nginx/nginx.conf; then
    sed -i '/http {/a \    include /etc/nginx/sites-enabled/*;' /etc/nginx/nginx.conf
fi


run "nginx -t"


run "systemctl enable --now nginx"

history -w
