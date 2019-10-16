#!/bin/bash
set -eux
# перепилим параметр прослушиваемого интерфейса монги и рестартанем ее
sudo sed -i.bak 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
sudo systemctl restart mongod.service
