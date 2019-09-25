#!/bin/bash
#Создаю правило на фаерволе
gcloud compute firewall-rules create default-puma-server\
  --allow=TCP:9292\
  --target-tags=default-puma-server
#Создаю саму виртуалку 
gcloud compute instances create reddit-full\
  --tags=puma-server,default-puma-server\
  --restart-on-failure \
  --image=reddit-full-1569451031 \
  --metadata startup-script='cd /home/decapapreta/reddit && puma -d'
