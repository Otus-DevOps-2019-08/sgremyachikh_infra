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
    access_config {
      # указываю использовать внешний ип, созданный отдельным ресурсом до виртуалки
      nat_ip = google_compute_address.db_ip.address
    }
  }
  metadata = {
    ssh-keys = "decapapreta:${file(var.public_key_path)}"
  }

  # вот это вот - костыль конечно и разврат:
  # монга из коробки стартует на локалхосте и его слушает
  # мы скриптом меняем интерфейс прослушивания бд на 0.0.0.0
  # По идее можно решать это заранее при содании образа, но мы не ищем легких путей
  provisioner "remote-exec" {
    script = "${path.module}/files/mongo.sh"
  }
  connection {
    type        = "ssh"
    host        = self.network_interface[0].access_config[0].nat_ip
    user        = "decapaprata"
    agent       = true
    private_key = file(var.connection_key)
  }
}
# внешний ип делаю
resource "google_compute_address" "db_ip" {
  name = "reddit-db-ip"
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
# Переменная для передачи в другой модуль app ip-адреса данного инстанса db
output "db_instance_ip" {
  value = google_compute_instance.db.network_interface[0].network_ip
}
