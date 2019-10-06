terraform {
  # Версия terraform
  required_version = "~>0.12.8"
}

provider "google" {
  # Версия провайдера
  version = "~> 2.7"
  # ID проекта
  project = "${var.project}"
  region = "${var.region}"
}

# Добавляю глобальную метадату в виде ключей своего юзера
resource "google_compute_project_metadata_item" "ssh-keys" {
  key   = "ssh-keys"
  value = "decapapreta:${file(var.public_key_path)} appuser1:${file(var.public_key_path)} appuser2:${file(var.public_key_path)}"
}


### app
resource "google_compute_instance" "app" {
  count = 2
  name         = "reddit-app-${count.index}"
  machine_type = "g1-small"
  zone         = "${var.instance_zone}"
  tags         = ["reddit-app"]
  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
  metadata = {
    # путь до публичного ключа
    ssh-keys = "decapapreta:${file(var.public_key_path)}"
  
  }
  connection {
    type  = "ssh"
    host  = "self.network_interface[0].access_config[0].nat_ip"
    user  = "decapapreta"
    agent = false
    # путь до приватного ключа
    private_key = "${file(var.connection_key)}"
  }
  # провижн путем копирования юнита в системд
  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }
  # провижн путем выполнения скрипта деплоя
  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

# tcp 9292
resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"
  # Название сети, в которой действует правило
  network = "default"
  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]
  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["reddit-app"]
}

# ssh
resource "google_compute_firewall" "firewall_ssh" {
  name = "default-allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

