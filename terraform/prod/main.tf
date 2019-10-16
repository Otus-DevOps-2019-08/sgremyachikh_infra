terraform {
  # Версия terraform
  required_version = "~>0.12.8"
}

provider "google" {
  # Версия провайдера
  version = "~> 2.15"
  # ID проекта
  project = var.project
  # регион развертывания
  region = var.region
}

#  модуль поднятия ВМ для приложения
module "app" {
  source          = "../modules/app"
  public_key_path = var.public_key_path
  zone            = var.zone
  app_disk_image  = var.app_disk_image
  machine_type    = var.machine_type
  # В эту переменную получаю от модуля db айпишник инстанса с БД
  database_url    = "${module.db.db_instance_ip}:27017"
}

# модуль для поднятия ВМ для монги 
module "db" {
  source          = "../modules/db"
  public_key_path = var.public_key_path
  zone            = var.zone
  db_disk_image   = var.db_disk_image
  machine_type    = var.machine_type
}

# модуль для доступа ко всем ВМ по 22 порту ssh
module "vpc" {
  source        = "../modules/vpc"
  source_ranges = var.source_ranges
}

# Добавляю глобальную метадату в виде ключей своего юзера
resource "google_compute_project_metadata_item" "ssh-keys" {
  key   = "ssh-keys"
  value = "decapapreta:${file(var.public_key_path)}"
}
