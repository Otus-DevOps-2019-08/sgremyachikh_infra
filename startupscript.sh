#!/bin/bash
wget https://raw.githubusercontent.com/Otus-DevOps-2019-08/sgremyachikh_infra/cloud-testapp/install_ruby.sh
wget https://raw.githubusercontent.com/Otus-DevOps-2019-08/sgremyachikh_infra/cloud-testapp/install_mongodb.sh
wget https://raw.githubusercontent.com/Otus-DevOps-2019-08/sgremyachikh_infra/cloud-testapp/deploy.sh
sudo chmod 777 ./*.sh
./install_ruby.sh
./install_mongo.sh
./deploy.sh

