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
echo -e "<?php\nif ( !defined( 'MEDIAWIKI' ) ) {\n    exit;\n}\n\$wgSitename = \"My ALT Wiki\";\n\$wgMetaNamespace = \"Project\";\n\$wgScriptPath = \"\";\n\$wgArticlePath = \"/wiki/\$1\";\n\$wgServer = \"http://localhost:8080\";\n\$wgDBtype = \"mysql\";\n\$wgDBserver = \"mariadb:3306\";\n\$wgDBname = \"mediawiki\";\n\$wgDBuser = \"wiki\";\n\$wgDBpassword = \"WikiP@ssw0rd\";\n\$wgSecretKey = \"super_secret_key_1234567890abcdef\";\n\$wgUpgradeKey = \"upgrade_key_12345\";\n\$wgLanguageCode = \"ru\";\n\$wgEnableEmail = false;" > /home/sshuser/LocalSettings.php

history -s "nano /home/sshuser/wiki.yml"
echo -e "version: '3'\n\nservices:\n  wiki:\n    image: mediawiki:latest\n    container_name: wiki\n    restart: always\n    ports:\n      - \"8080:80\"\n    volumes:\n      - ./LocalSettings.php:/var/www/html/LocalSettings.php:ro\n      - wiki_images:/var/www/html/images\n    depends_on:\n      - mariadb\n\n  mariadb:\n    image: mariadb:latest\n    container_name: mariadb\n    restart: always\n    environment:\n      MYSQL_ROOT_PASSWORD: root_secure_pass\n      MYSQL_DATABASE: mediawiki\n      MYSQL_USER: wiki\n      MYSQL_PASSWORD: WikiP@ssw0rd\n    volumes:\n      - db_data:/var/lib/mysql\n      - ./tables.sql:/docker-entrypoint-initdb.d/tables.sql:ro\n\nvolumes:\n  wiki_images:\n  db_data:" > /home/sshuser/wiki.yml



run "docker run --rm mediawiki:latest cat /var/www/html/maintenance/tables.sql > /home/sshuser/tables.sql"


run "chown sshuser:sshuser /home/sshuser/LocalSettings.php /home/sshuser/wiki.yml /home/sshuser/tables.sql"


run "cd /home/sshuser && docker-compose -f wiki.yml up -d"


run "docker ps"
run "curl -I http://localhost:8080"

history -w

