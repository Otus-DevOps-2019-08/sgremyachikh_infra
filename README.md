# sgremyachikh_infra
sgremyachikh Infra repository

# HW: GCP Знакомство с облачной инфраструктурой и облачными сервисами

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

# HW : Модели управления инфраструктурой

В директории packer создан файл ubuntu16.json, описывающий создание образа с задаными параметрами. Параметры хранятся в соседнем variables.json

## Использование файла конфигурации образа packer:
Валидация с указанием файла с переменными:
```
packer validate -var-file variables.json ubuntu16.json
```
Сборка-запекание образа:
```
packer build -var-file variables.json ubuntu16.json
```

## .gitignore

variables.json не содежится в репозитории на github

## Запекание образа со всеми зависимостями и приложением:

В директории packer лежит файл конфигурации образа packer immutable.json, описывающий данную конфигурацию с зависимостями и приложением. Он так же параметризирован как и ubuntu16.json

Запекание:
```
packer build -var-file immutable.json ubuntu16.json
```
image_family у получившегося reddit-full, дополнительные файлы лежат в packer/files
Для запуска приложения при старте инстанса не используется systemd unit - не понял как это сделать с этим типом приложения.

## Для ускорения работы можно запускать виртуальную машину с помощью командной строки и утилиты gcloud:

create-redditvm.sh в директории config-scripts запустит виртуальную машину из образа подготовленного в рамках этого ДЗ, из семейства reddit-full, запустит приложение в ВМ и создаст правило на фаерволе, если вдруг его нет.

# HW : Практика Infrastructure as a Code (IaC)

## В директории terraform созданы:

files - директория с deploy.sh  puma.service, файлами для деплоя приложения и запуска через systemd
main.tf  - основной файл конфигурации проекта
outputs.tf  - файл параметров вывода 
terraform.tfstate  - файл, описывающий состояние
terraform.tfstate.backup  - файл бэкапа файла выше
terraform.tfvars  - файл c реальным переменными проекта
terraform.tfvars.example  - файл с вымешленными переменными проекта
variables.tf - файл, описывающий input переменные

## в .gitignore включены:

/packer/variables.json
*.tfstate
*.tfstate.*.backup
*.tfstate.backup
*.tfvars
.terraform/

## Читшит команд:

Линт кода:
```
terraform validate
```
Планирование изменений:
```
terraform plan
```
Применение изменений
```
terraform apply
```
## Задание со *

В коде после указания провайдера до создания инстансов вы указали ресурс google_compute_project_metadata_item
в нем указали аргумент и значения для добавления ключей пользователей для доступа к проекту

Если в веб интерфейсе добавить еще какого-то пользователя, не описанного кодом, то его ssh ключ пропадет при следующем выполнении terraform apply

Код добавления ключей юзеров в проект:
```
resource "google_compute_project_metadata_item" "ssh-keys" {
  key   = "ssh-keys"
  value = "decapapreta:${file(var.public_key_path)} appuser1:${file(var.public_key_path)} appuser2:${file(var.public_key_path)}"
}
```

