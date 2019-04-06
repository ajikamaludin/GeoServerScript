#!/bin/bash
#script for ubuntu 16.04
#maintance by aji19kamaludin@gmail.com
#geoserver

#update system
apt-get update

#set hostname
hostnamectl set-hostname gdp-geonode

#install docker
apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt-get install docker-ce docker-ce-cli containerd.io -y

#install docker-compose
curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

#build geonode from docker-compose orchestra
cd /root 
git clone https://github.com/ajikamaludin/geonode.git
cd geonode
export IP_PUBLIC=$(curl ifconfig.me);docker-compose up -d --build

#make it automation in reboot : exit rc.local
sed -i -e '$i \export IP_PUBLIC=$(curl ifconfig.me);cd /root/geonode;docker-compose -f docker-compose.yml up -d --build &\n' /etc/rc.local
sed -i -e '$i \docker container start portainer &\n' /etc/rc.local

#install portainer for console 
docker volume create portainer_data
docker run --name "portainer" -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer

#after all reboot and reservice
reboot