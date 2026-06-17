#!/bin/bash


set -e
set -o history

run() {
    history -s "$*"
    eval "$*"
}


run "apt-get install -y moodle moodle-apache2 moodle-local-mysql"

run "systemctl enable --now mysqld"
run "mysqladmin -u root password 'P@ssw0rd'"


run "mysql -u root -p'P@ssw0rd' -e \"CREATE DATABASE moodledb DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;\""
run "mysql -u root -p'P@ssw0rd' -e \"CREATE USER 'moodle'@'localhost' IDENTIFIED BY 'P@ssw0rd';\""
run "mysql -u root -p'P@ssw0rd' -e \"GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,CREATE TEMPORARY TABLES,DROP,INDEX,ALTER ON moodledb.* TO 'moodle'@'localhost';\""
run "mysql -u root -p'P@ssw0rd' -e \"FLUSH PRIVILEGES;\""


run "cd /var/www/moodle && sudo -u apache /usr/bin/php admin/cli/install.php --non-interactive --agreelicense --lang=ru --wwwroot='http://192.168.6.2' --dataroot='/var/lib/moodle' --dbtype='mariadb' --dbhost='localhost' --dbname='moodledb' --dbuser='moodle' --dbpass='P@ssw0rd' --adminpass='P@ssw0rd' --fullname='$NUM' --shortname='$NUM'"


run "chown -R apache:apache /var/www/moodle /var/lib/moodle"
run "chmod 2777 /var/lib/moodle"
run "systemctl enable --now httpd2"

history -w
