terraform {
  # Версия terraform
  required_version = "~>0.12.8"
}

provider "google" {
  # Версия провайдера
  version = "~> 2.7"
  # ID проекта
  project = var.project
  # регион развертывания
  region = var.region
}

# Добавляю глобальную метадату в виде ключей своего юзера
resource "google_compute_project_metadata_item" "ssh-keys" {
  key   = "ssh-keys"
  value = "decapapreta:${file(var.public_key_path)}"
}
