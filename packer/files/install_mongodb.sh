#!/bin/bash
set -e

#installing mongodb by our method
bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | apt-key add -
apt update
apt install -y mongodb-org
systemctl start mongod
systemctl enable mongod

