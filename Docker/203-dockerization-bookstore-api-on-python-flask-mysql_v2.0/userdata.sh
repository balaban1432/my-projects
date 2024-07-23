#!/bin/bash
hostnamectl set-hostname docker_instance
dnf update -y
dnf install git -y
dnf install docker -y
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user
newgrp docker
curl -SL https://github.com/docker/compose/releases/download/v2.28.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
cd /home/ec2-user
TOKEN=${userdata-git-token}
USER=${userdata-git-name}
git clone https://$TOKEN@github.com/$USER/bookstore-api.git
cd /home/ec2-user/bookstore-api
docker-compose up -d
