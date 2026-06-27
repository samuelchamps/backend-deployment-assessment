#!/bin/bash
yum update -y

# Install Docker
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group (run docker without sudo)
usermod -a -G docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Git (needed to clone the MuchTodo repo)
yum install -y git