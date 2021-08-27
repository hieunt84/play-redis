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
# SECTION 2: INSTALL 

# install docker
curl -fsSL https://get.docker.com/ | sh
systemctl start docker
systemctl enable docker

# Deploy Portainer
# Create volume cho portainer
docker volume create portainer_data

# Create portainer container
docker run -d -p 9000:9000 --name=portainer --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer

#########################################################################################
# SECTION 3: DEPLOY NEXTCLOUD
docker run -d -p 6379:6379 --name=myredis --restart=always \
  -v redis_data:/data \
  redis   

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