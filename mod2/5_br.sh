#!/bin/bash

set -e
set -o history

run() {
    history -s "$*"
    eval "$*"
}


run "apt-get install -y docker-engine docker-compose"


run "systemctl enable --now docker"


run "gpasswd -a sshuser docker"

run "systemctl restart docker"


history -s "nano /home/sshuser/LocalSettings.php"
cat > /home/sshuser/LocalSettings.php <<'EOF'
<?php
if ( !defined( 'MEDIAWIKI' ) ) {
    exit;
}
$wgSitename = "My ALT Wiki";
$wgMetaNamespace = "Project";
$wgScriptPath = "";
$wgArticlePath = "/wiki/$1";
$wgServer = "http://localhost:8080";
$wgDBtype = "mysql";
$wgDBserver = "mariadb:3306";
$wgDBname = "mediawiki";
$wgDBuser = "wiki";
$wgDBpassword = "WikiP@ssw0rd";
$wgSecretKey = "super_secret_key_1234567890abcdef";
$wgUpgradeKey = "upgrade_key_12345";
$wgLanguageCode = "ru";
$wgEnableEmail = false;
EOF


history -s "nano /home/sshuser/wiki.yml"
cat > /home/sshuser/wiki.yml <<'EOF'
version: '3'

services:
  wiki:
    image: mediawiki:latest
    container_name: wiki
    restart: always
    ports:
      - "8080:80"
    volumes:
      - ./LocalSettings.php:/var/www/html/LocalSettings.php:ro
      - wiki_images:/var/www/html/images
    depends_on:
      - mariadb

  mariadb:
    image: mariadb:latest
    container_name: mariadb
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: root_secure_pass
      MYSQL_DATABASE: mediawiki
      MYSQL_USER: wiki
      MYSQL_PASSWORD: WikiP@ssw0rd
    volumes:
      - db_data:/var/lib/mysql
      - ./tables.sql:/docker-entrypoint-initdb.d/tables.sql:ro

volumes:
  wiki_images:
  db_data:
EOF


run "docker run --rm mediawiki:latest cat /var/www/html/maintenance/tables.sql > /home/sshuser/tables.sql"


run "chown sshuser:sshuser /home/sshuser/LocalSettings.php /home/sshuser/wiki.yml /home/sshuser/tables.sql"


run "cd /home/sshuser && docker-compose -f wiki.yml up -d"


run "docker ps"
run "curl -I http://localhost:8080"

history -w

