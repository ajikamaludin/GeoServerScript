#!/bin/bash
#script for ubuntu 16.04
#mapserver

#update system
apt update && apt dist-upgrade -y

#set hostname
hostnamectl set-hostname qmack-mapserver

#install mapserver
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160
apt-key fingerprint 314DF160
add-apt-repository "deb http://ppa.launchpad.net/ubuntugis/ppa/ubuntu $(lsb_release -cs) main"
apt-get update
apt-get install cgi-mapserver mapserver-bin mapserver-doc python-mapscript -y

#install apache2, php5, enable mod_rewrite, changes php.ini
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C
add-apt-repository "deb http://ppa.launchpad.net/ondrej/php/ubuntu $(lsb_release -cs) main "
apt-get update
apt-get install apache2 php5.6 php5.6-cli php5.6-common php5.6-curl php5.6-dev php5.6-gd php5.6-imap php5.6-intl php5.6-json php5.6-mbstring php5.6-mcrypt php5.6-mysql php5.6-pgsql php5.6-phpdbg php5.6-sqlite3 php5.6-sybase php5.6-xml php5.6-xmlrpc php5.6-xsl php5.6-zip php5.6-fpm libapache2-mod-fastcgi libapache2-mod-php5.6 zip unzip -y
a2enmod actions cgi fastcgi alias rewrite
sed -i -e '16i \<Directory /var/www/html> \nOptions Indexes FollowSymlinks MultiViews \nAllowOverride All \nRequire all granted\n </Directory>\n' /etc/apache2/sites-available/000-default.conf
sed -i -e '16i \<Directory />\nOptions FollowSymLinks \nAllowOverride All \n</Directory> \nScriptAlias /cgi-bin/ /usr/lib/cgi-bin/ \n<Directory /usr/lib/cgi-bin> \nAllowOverride None \nOptions +ExecCGI -MultiViews +SymLinksIfOwnerMatch \nOrder allow,deny \nAllow from all \n</Directory>' /etc/apache2/sites-available/000-default.conf

cp /usr/lib/php/5.6/php.ini-development /etc/php/5.6/apache2/php.ini
rm /var/www/html/index.html
echo "<?php phpinfo(); ?>" > /var/www/html/index.php
chmod o+x /usr/lib/cgi-bin/mapserv
service apache2 restart

#mapserver demo
cd /tmp;wget http://maps.dnr.state.mn.us/mapserver_demos/workshop-5.4.zip;
unzip workshop-5.4.zip -d /var/www/html
mv /var/www/html/workshop-5.4 /var/www/html/demo
cd /var/www/html/demo;rm index.html;
wget https://gist.githubusercontent.com/ajikamaludin/a45643772aa47d9279de879eaa5252c1/raw/3f1f740129b6ae3ddbcd7caf061de1e06007f5fe/index.html

#install postgresql, postgis, phppgadmin
echo "deb http://apt.postgresql.org/pub/repos/apt xenial-pgdg main" >> /etc/apt/sources.list
wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
apt-get update
apt-get install postgresql-9.6 postgresql-9.6-postgis-2.4  postgresql-9.6-postgis-scripts postgis postgresql-9.6-pgrouting zip unzip wget -y

su -c "psql -c 'CREATE EXTENSION adminpack;'" postgres
su -c "psql -c 'CREATE EXTENSION postgis;'" postgres
su -c "psql -c \"CREATE USER gisadmin SUPERUSER PASSWORD 'gisadmin';\"" postgres

cd /tmp;wget https://github.com/phppgadmin/phppgadmin/archive/REL_5-6-0.zip;
wget https://gist.githubusercontent.com/ajikamaludin/2d1ae989402decad064f4d7d7ce424be/raw/60277bb5064b12e6c42993c4ecf08fd22ff5f969/phppgadmin-config.inc.php;
unzip REL_5-6-0.zip -d /var/www/html
mv /var/www/html/phppgadmin-REL_5-6-0 /var/www/html/phppgadmin
cp /tmp/phppgadmin-config.inc.php /var/www/html/phppgadmin/conf/config.inc.php

#after all reboot and reservice
reboot