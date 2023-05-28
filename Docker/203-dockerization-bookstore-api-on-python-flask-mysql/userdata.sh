#!/bin/bash
hostnamectl set-hostname docker_instance
yum update -y
yum install docker -y
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user
# install docker-compose
curl -SL https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
yum install git -y
cd /home/ec2-user && mkdir bookstore && cd bookstore
TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
FOLDER="https://$TOKEN@raw.githubusercontent.com/balaban1432/bookstore/main/"
# mkdir bookstore && cd bookstore
# wget ${FOLDER}bookstore-api.py
# wget ${FOLDER}docker-compose.yml
# wget ${FOLDER}Dockerfile
# wget ${FOLDER}requirements.txt
curl -s --create-dirs -o "/home/ec2-user/bookstore/bookstore-api.py" -L "$FOLDER"bookstore-api.py
curl -s --create-dirs -o "/home/ec2-user/bookstore/requirements.txt" -L "$FOLDER"requirements.txt
curl -s --create-dirs -o "/home/ec2-user/bookstore/Dockerfile" -L "$FOLDER"Dockerfile
curl -s --create-dirs -o "/home/ec2-user/bookstore/docker-compose.yml" -L "$FOLDER"docker-compose.yml
docker-compose up -d