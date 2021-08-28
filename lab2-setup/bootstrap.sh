#!/bin/bash
# Script deploy nextcloud with docker

##########################################################################################
# SECTION 1: PREPARE

# change root
sudo -i
sleep 2

# update system
# yum clean all
# yum -y update
# sleep 1

# config timezone
timedatectl set-timezone Asia/Ho_Chi_Minh

# disable SELINUX
setenforce 0 
sed -i 's/enforcing/disabled/g' /etc/selinux/config

# disable firewall
systemctl stop firewalld
systemctl disable firewalld

# config hostname
hostnamectl set-hostname docker1

# config file host
cat >> "/etc/hosts" <<END
127.0.0.1 docker1 docker1.hit.local
172.20.10.100 docker1 docker1.hit.local
END

##########################################################################################
# SECTION 2: INSTALL Dcoker, Docker-compse, Portainer

# Install docker
curl -fsSL https://get.docker.com/ | sh
systemctl start docker
systemctl enable docker

# Install Portainer
# Create volume cho portainer
docker volume create portainer_data

# download image portainer
docker pull portainer/portainer

# Run portainer container
docker run -d -p 9000:9000 --name=portainer --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer

# Install docker-compose
sudo curl -sL "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

#########################################################################################
# SECTION 3: DEPLOY NEXTCLOUD

# install git
yum -y install git

# clone repo from github
cd ~
git clone https://github.com/hieunt84/play-redis.git

# change working directory
cd ./play-redis/lab2-setup

# Make folder store data redis
mkdir -p ./data/redis

# Make folder store data config redis
mkdir -p ./config/redis

# copy redis.conf
cp ./redis.conf ./config/redis/redis.conf

# deploy redis
docker-compose pull
docker-compose up -d

#########################################################################################
# SECTION 4: FINISHED

# config firwall
systemctl start firewalld
firewall-cmd --zone=public --permanent --add-port=6379/tcp
firewall-cmd --zone=public --permanent --add-port=9000/tcp
firewall-cmd --reload
systemctl restart firewalld
systemctl enable firewalld

# notification
echo " DEPLOY COMPLETELY"