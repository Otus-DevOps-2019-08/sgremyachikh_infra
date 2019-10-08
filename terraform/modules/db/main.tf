# создаю ВМ с БД
resource "google_compute_instance" "db" {
  name         = "reddit-db"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["reddit-db"]
  boot_disk {
    initialize_params {
      # используется образ диска для ВМ с БД
      image = var.db_disk_image
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  metadata = {
    ssh-keys = "decapapreta:${file(var.public_key_path)}"
  }
}
# нужно разрешить подключения к монге
#мы создаем правило allow-mongo-default для 27017 порта
#для ВМ с тэгом из сорс-тэг для подключения к таргет-таг
resource "google_compute_firewall" "firewall_mongo" {
  name    = "allow-mongo-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }
  target_tags = ["reddit-db"]
  source_tags = ["reddit-app"]
}

