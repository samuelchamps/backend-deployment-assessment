#!/bin/bash
yum update -y

# Add MongoDB 7.0 repository
cat > /etc/yum.repos.d/mongodb-org-7.0.repo << 'EOF'
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-7.0.asc
EOF

# Install MongoDB
yum install -y mongodb-org

# Configure MongoDB to listen on all interfaces (so Backend can connect)
sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf

# Start and enable MongoDB
systemctl start mongod
systemctl enable mongod

