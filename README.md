# sgremyachikh_infra
sgremyachikh Infra repository

<<<<<<< HEAD
# HW: GCP Знакомство с облачной инфраструктурой и облачными сервисами
=======
## GCP
>>>>>>> d2636f5da2326074c42fc0c9495819c8c9ba6866

Созданы 2 инстанса микро в GCP, поднят впн сервер, настроен профиль пользователя для подклюении, сделан форвардинг ключей ssh для авторизации на машинах за бастионом, 
 
Бастион с 2 интерфейсами(внешний белый статичный и внутренний во внутренней сети) и машина в серой сети.

Подключение к бастиону возможно при наличии ssh ключей:

```
ssh decapapreta@35.228.154.228
```
Работа с остальными виртуалками с бастиона возможна при реализации форвардинга ключей локальной машины.
Проверка существующего форвардинга:
```
ssh-add -L
The agent has no identities
```
Добавить ssh ключ в агент авторизации:
```
ssh-add ~/.ssh/appuser
```
Подключение с форвардингом:
```
ssh -A decapapreta@35.228.154.228
```

## Подключение к машине в серой сети:
1. Просто, используя форвардинг ключей:
```
ssh -A -t decapapreta@35.228.154.228 ssh 10.166.0.5
```
2. Интересно:
```
ssh someinternalhost
```
для этого создать/изменить ~.ssh/config. Добавить: 
```
Host bastion
Hostname $bastion_external_ip
User $username
Host someinternalhost
Hostname $someinternalhost_ip
User $username
ProxyCommand ssh -W %h:%p bastion
```

##Развертывание vpn-сервера происходит скриптом setupvpn.sh
Листинг setupvpn.sh

## Реализован https для веб-интерфейса vpn-сервера с использованием возможностей sslip.io и Let’s Encrypt.:

Как реализуется: при настройке сервера указать в поле Lets Encrypt Domain в виде <ip>.sslip.io

Подключение в web-интерфейсу: https://35.228.154.228.sslip.io/login


### Информация для тестов VPN

```
bastion_IP = 35.228.154.228
someinternalhost_IP = 10.166.0.5
```
<<<<<<< HEAD
# HW : GCP Основные сервисы Google Cloud Platform (GCP)

## Команда для развертывания окружения приложения и последующего деплоя:

```
curl https://raw.githubusercontent.com/Otus-DevOps-2019-08/sgremyachikh_infra/cloud-testapp/startupscript.sh | bash
```

## Создание инстанса через gcloud с передачей параметра скрипта запуска:

В результате выполнения такого скрипта мы получим инстанс с заданными параметрами, который после создания выполнит скрипт startupscript.sh, который развернет окружение и приложение.

```
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags=puma-server,default-puma-server\
  --restart-on-failure \
  --metadata startup-script-url=https://raw.githubusercontent.com/Otus-DevOps-2019-08/sgremyachikh_infra/cloud-testapp/startupscript.sh

```
## Создание правила фаервола с тегом default-puma-server для доступа к приложению на порту 9292 средствами gcloud будет выглядеть вот так:
```
gcloud compute firewall-rules create default-puma-server\
  --allow=TCP:9292\
  --target-tags=default-puma-server
```

### Информация для тестов testapp
```
testapp_IP = 35.228.154.228
testapp_port = 9292
```
=======
>>>>>>> d2636f5da2326074c42fc0c9495819c8c9ba6866

