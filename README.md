# sgremyachikh_infra
sgremyachikh Infra repository
-----------------------------
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

### Подключение к машине в серой сети:
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

### Развертывание vpn-сервера происходит скриптом setupvpn.sh
Листинг setupvpn.sh

### Реализован https для веб-интерфейса vpn-сервера с использованием возможностей sslip.io и Let’s Encrypt.:

Как реализуется: при настройке сервера указать в поле Lets Encrypt Domain в виде <ip>.sslip.io

Подключение в web-интерфейсу: https://35.228.154.228.sslip.io/login


### Информация для тестов VPN

```
bastion_IP = 35.228.154.228
someinternalhost_IP = 10.166.0.5
```
-----------------------------------------------
# HW : GCP Основные сервисы Google Cloud Platform (GCP)

### Команда для развертывания окружения приложения и последующего деплоя:

```
curl https://raw.githubusercontent.com/Otus-DevOps-2019-08/sgremyachikh_infra/cloud-testapp/startupscript.sh | bash
```

### Создание инстанса через gcloud с передачей параметра скрипта запуска:

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
### Создание правила фаервола с тегом default-puma-server для доступа к приложению на порту 9292 средствами gcloud будет выглядеть вот так:
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

----------------------------------------------------
# HW : Модели управления инфраструктурой

В директории packer создан файл ubuntu16.json, описывающий создание образа с задаными параметрами. Параметры хранятся в соседнем variables.json

### Использование файла конфигурации образа packer:
Валидация с указанием файла с переменными:
```
packer validate -var-file variables.json ubuntu16.json
```
Сборка-запекание образа:
```
packer build -var-file variables.json ubuntu16.json
```

### .gitignore

variables.json не содежится в репозитории на github

### Запекание образа со всеми зависимостями и приложением:

В директории packer лежит файл конфигурации образа packer immutable.json, описывающий данную конфигурацию с зависимостями и приложением. Он так же параметризирован как и ubuntu16.json

Запекание:
```
packer build -var-file immutable.json ubuntu16.json
```
image_family у получившегося reddit-full, дополнительные файлы лежат в packer/files
Для запуска приложения при старте инстанса не используется systemd unit - не понял как это сделать с этим типом приложения.

### Для ускорения работы можно запускать виртуальную машину с помощью командной строки и утилиты gcloud:

create-redditvm.sh в директории config-scripts запустит виртуальную машину из образа подготовленного в рамках этого ДЗ, из семейства reddit-full, запустит приложение в ВМ и создаст правило на фаерволе, если вдруг его нет.


------------------------------------------------
# HW : Практика Infrastructure as a Code (IaC)

### Дисклеймер: чтоб терраформ мог использовать данные авторизации gcloud, на до выполнить обязательно 
```
gcloud auth application-default login
```
Подробнее в https://cloud.google.com/sdk/gcloud/reference/auth/application-default/login

### В директории terraform созданы:

files - директория с deploy.sh  puma.service, файлами для деплоя приложения и запуска через systemd
main.tf  - основной файл конфигурации проекта
outputs.tf  - файл параметров вывода 
terraform.tfstate  - файл, описывающий состояние
terraform.tfstate.backup  - файл бэкапа файла выше
terraform.tfvars  - файл c реальным переменными проекта
terraform.tfvars.example  - файл с вымешленными переменными проекта
variables.tf - файл, описывающий input переменные

### в .gitignore включены:

/packer/variables.json
*.tfstate
*.tfstate.*.backup
*.tfstate.backup
*.tfvars
.terraform/

### Читшит команд:

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
### Задание со *

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

### - Задание со **
Изменена конфигурация для развертывания серверов приложений. Создан lb.tf с конфигруацией LoadBalancer для проксирования на несколько серверов приложений. Проведена проверка, что при отключении приложения на одной VM, не происходит отказа в обслуживании - трафик балансируется на "живой" сервер за счет healthcheck.

----------------------------------------------------
# HW : Принципы организации инфраструктурного кода и работа над инфраструктурой в команде на примере Terraform

До изменений мы переместили лб в terraform/files, убрали count, проверили работоспособность

Удостоверились, что когда в стейт файле нет сведений о существующей структуре, то стоит выполнить ее импорт, в противном случае могут быть ошибки. Так произошло с правилом фаервола.

### Неявные зависимости. Выяслили, что если ссылаемся на атрибуты другого ресурса, то это влияет на последовательность создания при аплае:

т.е. если в ВМ указать ссылку на получаемый IP:
```
network_interface {
network = "default"
access_config {
nat_ip = google_compute_address.app_ip.address
}
}
```
то ресурс ниже создастся ранее:
```
resource "google_compute_address" "app_ip" {
name = "reddit-app-ip"
}
```
### Так же есть явные зависимости. При необходимости можно использовать depends_on

Инфа по сабжу: https://www.terraform.io/docs/configuration/resources.html
в коде это может выглядеть как:
```
  depends_on = [
    aws_iam_role_policy.example,
  ]
```
### Далее были созданы 2 baked-образа.

Для монги пакером из db.json был создан образ reddit-base-db
Для руби пакером из app.json был создан образ reddit-app-base

Важно! в образах пренебрежем провижинерами!

### Созданы 3 модуля: app, db, vpc

модули переиспользованы при создании дев и прод окружений.

### Изучено как использовать модули из репозитория hashicorp

https://registry.terraform.io/modules/SweetOps/storage-bucket/google

## Задание со * 
Создание хранилища-бакета в GCS
Суть в создании отдельного файла backend.tf в отдельной директории от основной кодовой базы проекта для.
мы указываем тип бэкенда gsc, а в этом случе указываем бакет и префикс. Создаем через terraform apply

```
terraform {
  required_version = "~>0.12.8"
  backend "gcs" {
    bucket  = "storage-bucket-test-sgremyachikh"
    prefix  = "terraform/state"
}
}
```
После создания бакета перехожу в директорию нужного окружения и работаю с ними. Файлы состояния в директориях окружений не создаются, т.к. они создаются в бакете.

Попытка одновременного выполнения изменения инфраструктуры оказалось невозможным. 
Попробовал. В одной из 2 консолей увидел "Error: Error locking state: Error acquiring the state lock..." Что указывает на блокировку файлов стейта в бакете.

### Дисклеймер! Создать бакет надо заранее из отдельной от директории, где нет иных файлов терраформа, отвечающих за создание инфраструктуры. 
### К примеру из корневой ./terraform , где присутствует storage-bucket.tf и более ничего серьезного.
### До выполнения инита, плана и эплая нет необходимости делать импорт состояния клауда. При дестрое бакет остается и не уничтожается.
### Не менее важно понимать, что до любого ихменения backend.tf надо делать дестрой, т.к. стейт может быть утерян и надо будет руками удалять все из гугла.

## Задание со **
Провижн образов.
Тут был конечно квест. Что-то не взлетело. Провижинер пытался подключиться снова и снова, но не получалось. Закомментировал потуги.

# HW : Управление конфигурацией. Знакомство с Ansible.

### Создана ветка ansible-1

## Было сделано в основной части:

Установка Ansible (ну тут все просто без подробностей)

Развертывание инфраструктуры терраформом, подготовленной заранее.

Знакомство с базовыми функциями и инвентори (ansible.cfg , inventory.yml)

Выполнение различных модулей на подготовленной в прошлых ДЗ инфраструктуре ( -m module_name -a argument_name)

Пишем простой плейбук (clone.yml)

## Задание со зведочкой не выполнено.

--------------------------
# HW : #11 Практика Расширенные возможности Ansible или Продолжение знакомства с Ansible: templates, handlers, dynamic inventory, vault, tags.

### Создана ветка ansible-2

## Было сделано в основной части:

Добавили в .gitignore *.retry чтоб случайно лишнее не поехало в гит
Были использованы 3 подхода для реализации провижина и деплоя:
 - все в одном плейбуке с одним большим плеем (теги у тасок)
 - все в одном плейбуке с множеством плеев (теги у плеев)
 - вариант с главным плейбуком  и подчиненными

Для озакомления использовались tags, handlers, templates.

### Для преминения каждого подхода нужно использовать свои приемы.

Для плейбука с одним плеем и множеством tags, чтоб применить изменения с нужными тегами, нужно выполнить следующее:
```
ansible-playbook reddit_app.yml --limit <host_group> --tags <tag>
```
Для плейбука с множеством плеев и множеством tags, чтоб применить изменения c нужными тегами, нужно выполнить следующее:
```
ansible-playbook reddit_app2.yml --tags <tag>
```
Для плейбука с импортом других плейбуков все еще проще:
```
ansible-playbook site.yml
```
## Задание со звездочкой: возможности использования dynamic inventory для GCP

я использовал вариант с оригинальным плагином для инвентори в GCP: https://docs.ansible.com/ansible/latest/plugins/inventory/gcp_compute.html

Условия:
 - Должен быть создан сервисный акк в GCP
 - Cоздан файла инвентори формата, описанного в доке
 - Установлены компоненты для авторизации ansible в GCP для python, от которого работает и был установлен ansible:
 ```
sudo pip3 install requests
sudo pip3 install google-auth
```
Далее нашпиговываю файл inventory.compute.gcp.yml тем, что нужно мне для генерации инвентори, групп и преферанса.
```
plugin: gcp_compute
projects: # имя проекта в GCP
  - balmy-elevator-253219 
regions: # регионы моих виртуалок
  - europe-west1
keyed_groups: # на основе чего хочу группировать
    - key: name
groups: # хочу свои группы с блэкджеком и пилить их буду на основании присутствия частичек нужных в именах
  app: "'app' in name"
  db: "'db' in name"
hostnames: #хостнейм приятнее айпишника, НО без compose не взлетало
  # List host by name instead of the default public ip
  - name
compose: #
  # Тутустанвливается параметр сопоставления публичного IP и хоста
  # Для ip из LAN использовать "networkInterfaces[0].networkIP"
  ansible_host: networkInterfaces[0].accessConfigs[0].natIP
filters: []
auth_kind: serviceaccount # тип авторизации
service_account_file: ~/.gcp/balmy-elevator-253219.json # мой секретный ключ от сервисного акка

```

Сам инвентори могу закинуть потом в конфиг моего ансибла чтоб всегда не париться далее:)
Проверяю работу инвентори:
```
ansible-inventory -i inventory.compute.gcp.yml --graph
```
Возникла проблема - нужно было передать приложению параметр IP монги, чтоб не писать его в плейбук руками всякий раз.
В этой задаче на помощь пришли https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#accessing-information-about-other-hosts-with-magic-variables
В файл db_config.j2 вписал для получения адреса: 
```
DATABASE_URL={{ hostvars[groups['db'][0]]['ansible_default_ipv4']['address'] }} 
```
это позволило получить LAN ip машины из группы db.

## Задание с packer

созданы 2 плейбука для провижиненга образов пакера:
информация о них добавлена в файлы образов пакера, собраны новыеобразы в GCP
```
packer build -var-file variables.json app.json
packer build -var-file variables.json db.json
```
артефакты:
reddit-app-base
reddit-base-db
На базе этих образов развернута инфраструктура, прокатанная ансиблом и проверенная на работоспособность.

-------------------------------------
# HW : Принципы организации кода для управления конфигурацией. Ansible: работа с ролями и окружениями.

## Суть задания со звездочкой пришла на ум сразу же. Выполнял его параллельно с основной домашкой:

При создании роли app в db_config.j2 вернул стандартное DATABASE_URL={{ db_host }}, чтоб не бралось значение ip из magic viriables - роль должна быть переиспользуема. Использовал мэджик переменные в переменной группы хостов app:
```
db_host: "{{ hostvars[groups['db'][0]]['ansible_default_ipv4']['address'] }}"

```
как видно - конструкцию извлечения из фактов нужного ip надо брать в кавычки чтоб пройти успешно --check нашего плейбука.

## Касаясь стейджинга - захотелось красивее имена хостов и специфичнее динамик инвентори файл:

В модулях terraform app и db были изменены названия виртуалок и прочих создаваемых ресурсов по аналогии с:
```
resource "google_compute_instance" "app" {
  name         = "reddit-app-${var.environment}"
```
и
```
resource "google_compute_instance" "db" {
  name         = "reddit-db-${var.environment}"
```
в переменные модулей variables.tf
добавлено:
```
variable "environment" {
  description = "environment type"  
}
```
в основной файл инфраструктуры main.tf добавлено в параметры модулей:
```
environment = var.environment
```
В файл с переменными terraform.tfvars так же внесены значения энвайронментов каждого из окружений. 

Эти изменения в инфраструктуре были необходимы для дальшейшего более комфортного использования динамк инвентори. В самом инвентори теперь формирование групп для stage окружения выглядит вот как:
```
plugin: gcp_compute
projects: # имя проекта в GCP
  - balmy-elevator-253219 
regions: # регионы моих виртуалок
  - europe-west1
keyed_groups: # на основе чего хочу группировать
    - key: name
groups: 
  app: "'app-stage' in name" # <- вот тут видно. что для создания групп данного окружения я отсекаю машины с содержанием в именах названия энвайронмента 
  db: "'db-stage' in name" # тут, соответственно, так же
hostnames:
  - name
compose: #
  ansible_host: networkInterfaces[0].accessConfigs[0].natIP
filters: []
auth_kind: serviceaccount
service_account_file: ~/.gcp/balmy-elevator-253219.json
```
В результате я могу создавать одновременно 2 вида окружения и терраформом и прокатывать ансиблом.

## Основная часть домашки:

Создал ветку ansible-3

Создал директорию ролей и в ней шаблоны роли через
```
ansible-galaxy init app
ansible-galaxy init db
```
Перенес код в разные части шаблонов ролей

Файлы j2 были перемещены в templates ролей

Переделали плейбуки app.yml и db.yml в вызывающие роли

Создал директории окружений со своими инвентори

Прописал в ansible.cfg по умолчанию инвентори stage

Создал в директориях окружений директории group_vars с переменными групп хостов

Добавил переменные к группе all у обоих окружений:
```
env: stage
```
у прода, соответственно prod значение.

Определил переменную оружения по умолчанию в используемых ролях в mail.yml
```
env: local
```
Добавил вывод информации об окружении в каждой из ролей путем добавления в таски первой:
```
- name: Show info about the env this host belongs to
  debug:
    msg: "This host is in {{ env }} environment!!!"
```
Реорганизовал репозиторий:
```
.
├── ansible.cfg
├── environments
│   ├── prod
│   │   ├── credentials.yml
│   │   ├── group_vars
│   │   │   ├── all
│   │   │   ├── app
│   │   │   └── db
│   │   ├── inventory.compute.gcp.yml
│   │   └── requirements.yml
│   └── stage
│       ├── credentials.yml
│       ├── group_vars
│       │   ├── all
│       │   ├── app
│       │   └── db
│       ├── inventory.compute.gcp.yml
│       └── requirements.yml
├── old
│   ├── files
│   │   └── puma.service
│   ├── inventory
│   ├── inventory.compute.gcp.yml
│   ├── inventory.yml
│   └── templates
│       ├── db_config.j2
│       └── mongod.conf.j2
├── playbooks
│   ├── app.yml
│   ├── clone.yml
│   ├── db.yml
│   ├── deploy.yml
│   ├── packer_app.yml
│   ├── packer_db.yml
│   ├── reddit_app_multiple_plays.yml
│   ├── reddit_app_one_play.yml
│   ├── site.yml
│   └── users.yml
├── requirements.txt
└── roles
    ├── app
    │   ├── defaults
    │   │   └── main.yml
    │   ├── files
    │   │   └── puma.service
    │   ├── handlers
    │   │   └── main.yml
    │   ├── meta
    │   │   └── main.yml
    │   ├── README.md
    │   ├── tasks
    │   │   └── main.yml
    │   ├── templates
    │   │   └── db_config.j2
    │   ├── tests
    │   │   ├── inventory
    │   │   └── test.yml
    │   └── vars
    │       └── main.yml
    ├── db
    │   ├── defaults
    │   │   └── main.yml
    │   ├── files
    │   ├── handlers
    │   │   └── main.yml
    │   ├── meta
    │   │   └── main.yml
    │   ├── README.md
    │   ├── tasks
    │   │   └── main.yml
    │   ├── templates
    │   │   └── mongod.conf.j2
    │   ├── tests
    │   │   ├── inventory
    │   │   └── test.yml
    │   └── vars
    │       └── main.yml
    └── jdauphant.nginx
        Содержимое этой роли я скрыл за ненадобностью
``` 
В корне папки ansible из файлов остаются только ansible.cfg и requirements.txt

Последовал рекомендации по твику ansible.cfg

На каждом этапе я тестировал изменения командами:
```
cd ~/OTUS/sgremyachikh_infra/terraform/stage/
terraform destroy
terraform plan
terraform apply -auto-approve=false
cd ~/OTUS/sgremyachikh_infra/ansible/
ansible-playbook playbooks/site.yml --check
ansible-playbook playbooks/site.yml
```
Заходил на 9292 порт внешнего ip сервера приложения

Работа с community-ролями. Создал requirements.yml c описанием jdauphant.nginx нужной роли

установил ее:
```
ansible-galaxy install -r environments/stage/requirements.yml
```
Добавил необходимую инфу в переменные группы хостов app:
```
nginx_sites:
  default:
    - listen 80
    - server_name "reddit"
    - location / {
        proxy_pass http://127.0.0.1:9292;
        }
```
Добавил в конфигурацию Terraform открытие 80 порта для инстанса приложения.
В модуль создания ресурсов виртуалки приложения main.tf добавил:
```
# правило открытия порта 80 на ВМ с приложением
resource "google_compute_firewall" "firewall_nginx" {
  name    = "allow-nginx-80-${var.environment}"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = var.source_ranges
  target_tags   = ["reddit-app"]
}
```
Добавил вызов роли jdauphant.nginx в плейбук app.yml:
```
---
- name: Configure app
  hosts: app
  become: true

  roles:
    - app
    - jdauphant.nginx
...
```
Применил плейбук site.yml и убедился в работе приложения на 80 порту.

Создал файл ключа vault ВНЕ репозитория. Указал его для использования в ansible.cfg

Создал плейбук users.yml для соданию юзеров ОС на серверах и внесения их в группы sudo опционально.

Для каждого окружения создан credentials.yml с соответственным содержимым.

Оба они зашифрованы при помощи vault:
```
ansible-vault encrypt environments/prod/credentials.yml
ansible-vault encrypt environments/stage/credentials.yml
```
Проверил зашифрованность вайлов. Добавил вызов плейбука в файл site.yml и проверил работоспособность для обоих окружений удачность развертывания и созлание пользователей.

Проверил созданных пользователей. Вход по паролю на инстансах GCE отключен по-умолчанию. Я вошел appuser-ом по ssh на каждый сервер по сертификатам. Попробовал:
```
su admin
```
или 
```
su qauser
```
и успешно авторизовался.

Задание с 2 звездами выполнять не стал.

----------------------------------------------
# HW: Локальная разработка Ansible ролей с Vagrant. Тестирование конфигурации. Разработка и тестирование Ansible ролей и плейбуков.

## Создал ветку репозитория ansible-4

Установил vagrant и VirtualBox

дополнил .gitignore
```
# Vagrant & molecule
.vagrant/
*.log
*.pyc
.molecule
.cache
.pytest_cache
```

Создал Vagrantfile. заполнил когод гиста и запустил, поднялись 2 виртуалки. проверил, что все в них нормально работает.
Команды, необходимые длябазовой работы с vagrant:
```
vagrant up # поднимает описанное в vagrantfile
vagrant box list # показывает список загруженных образов-боксов
vagrant status # показывает статус окружения, поднятого из файла Vagrantfile
vagrant ssh appserver # подключиться по ssh к хосту их описанных в Vagrantfile
vagrant provision dbserver # запуск провижена без перезапуска ВМ.
cat .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory
```
создал плейбук base.yml, который добавил в site.yml, который изменил с import_playbook на include:
```
---
- include: base.yml
- include: db.yml
- include: app.yml
- include: deploy.yml
...
```
Изменил по методичке роли для app и db, правла пришлось кое-что поменять:

1. include заменить на import_playbook - include уже deprecated. А потом назад на include - vagrand не любит новшеств.
2. Изменения сделать касаемо ключа репозитория для монги:
```
  - name: Add APT key
    become: true
    apt_key:
      url: https://www.mongodb.org/static/pgp/server-3.2.asc
      state: present
    tags: install
```
так универсальнее.

Вызов инвентори vagrant:
```
cat .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory
```
Параметризировал роль app вводом переменной deploy_user:

!!! ВАЖНО! Переменная в плейбуках должна браться в кавычках!!! Пример:
```
- name: copy config for DB connection
  template:
    src: db_config.j2
    dest: "/home/{{deploy_user}}/db_config"
    owner: "{{deploy_user}}"
    group: "{{deploy_user}}"
```
в противном случае можно долго плясать по граблям с кавычками.

После провижининга можно войти через браузер на http://10.10.10.20:9292/ и проверить приложение.
При удалении виртуалок и пересоздании так же можно войти в барузере успешно.

## Задание со звездочкой * .

На предыдущем шаге я сразу же проверил что у нас на 80 порту и увидел там заглушку nginx-а.
Очевидно, что групварс от окружения у нас не подтянулись.
Что сделал? поиграл с экстраварс:
```
ansible.extra_vars = {
  "deploy_user" => "ubuntu",
  "nginx_sites" => {
    "default" => [
      "listen 80",
      "server_name \"reddit\"",
      "location / {
        proxy_pass http://127.0.0.1:9292;
      }"
    ]
  }
}
```
!!! Тут важно было замаскировать кавычки! Не брать весь блок нжинкса в кавычки, а сделать это с каждой строкой, через запятую.

Сайт стал открывться на http://10.10.10.20/

## Тестирование роли

Поставим инструменты
```
sudo pip3 install molecule testinfra
```
