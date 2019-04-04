#!/bin/bash
#script for ubuntu 16.04
#geoserver

#update system
apt-get update

#set hostname
hostnamectl set-hostname qmack-geoserver

#install docker
apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io -y

#build geoserver from docker
docker volume create aji-geoserver_datadir
docker run --name="geoserver-aji" -p 8080:8080 -v aji-geoserver_datadir:/mnt/geoserver_datadir -d ajikamaludin/geoserver:v1

#make it automation in reboot : exit rc.local
sed -i -e '$i \docker container start geoserver-aji &\n' /etc/rc.local
sed -i -e '$i \docker container start portainer &\n' /etc/rc.local

#install portainer for console 
docker volume create portainer_data
docker run --name "portainer" -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer

#install apache2, php5, enable mod_rewrite, changes php.ini
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C
add-apt-repository "deb http://ppa.launchpad.net/ondrej/php/ubuntu $(lsb_release -cs) main "
apt-get update
apt-get install apache2 php5.6 php5.6-cli php5.6-common php5.6-curl php5.6-dev php5.6-gd php5.6-imap php5.6-intl php5.6-json php5.6-mbstring php5.6-mcrypt php5.6-mysql php5.6-pgsql php5.6-phpdbg php5.6-sqlite3 php5.6-sybase php5.6-xml php5.6-xmlrpc php5.6-xsl php5.6-zip libapache2-mod-php5.6 -y

a2enmod rewrite
sed -i -e '16i \<Directory /var/www/html> \nOptions Indexes FollowSymlinks MultiViews \nAllowOverride All \nRequire all granted\n </Directory>\n' /etc/apache2/sites-available/000-default.conf
cp /usr/lib/php/5.6/php.ini-development /etc/php/5.6/apache2/php.ini
rm /var/www/html/index.html
echo "<?php phpinfo(); ?>" > /var/www/html/index.php
service apache2 restart

#install postgresql, postgis, phppgadmin
echo "deb http://apt.postgresql.org/pub/repos/apt xenial-pgdg main" >> /etc/apt/sources.list
wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
apt-get update
apt-get install postgresql-9.6 postgresql-9.6-postgis-2.4  postgresql-9.6-postgis-scripts postgis postgresql-9.6-pgrouting zip unzip wget -y

su -c "psql -c 'CREATE EXTENSION adminpack;'" postgres
su -c "psql -c 'CREATE EXTENSION postgis;'" postgres
su -c "psql -c \"CREATE USER gisadmin SUPERUSER PASSWORD 'gisadmin';\"" postgres

sed -i "/\#listen/a listen_addresses='*'" /etc/postgresql/11/main/postgresql.conf
sed -i '$i \host all all 0.0.0.0/0 md5 \n' /etc/postgresql/11/main/pg_hba.conf

cd /tmp;wget https://github.com/phppgadmin/phppgadmin/archive/REL_5-6-0.zip;
wget https://gist.githubusercontent.com/ajikamaludin/2d1ae989402decad064f4d7d7ce424be/raw/60277bb5064b12e6c42993c4ecf08fd22ff5f969/phppgadmin-config.inc.php;
unzip REL_5-6-0.zip -d /var/www/html
mv /var/www/html/phppgadmin-REL_5-6-0 /var/www/html/phppgadmin
cp /tmp/phppgadmin-config.inc.php /var/www/html/phppgadmin/conf/config.inc.php

#after all reboot and reservice
reboot