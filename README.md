# sgremyachikh_infra
sgremyachikh Infra repository

## GCP

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
### Информация для тестов testapp
```
testapp_IP = 35.228.154.228
testapp_port = 9292
```

