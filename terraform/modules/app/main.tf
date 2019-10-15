# Создание виртуалки
resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["reddit-app"]
  boot_disk {
    initialize_params {
      # образ диска для ВМ с приложением
      image = "${var.app_disk_image}"
    }
  }
  network_interface {
    network = "default"
    access_config {
      # указываю использовать внешний ип, созданный отдельным ресурсом до виртуалки
      nat_ip = google_compute_address.app_ip.address
    }
  }
  metadata = {
    ssh-keys = "decapapreta:${file(var.public_key_path)}"

  }
  ## # Хитро передаю значение переменной из модуля db в файл для дальнейшей магии деплоя
  ## provisioner "file" {
  ##   content      = "DATABASE_URL=${var.database_url}"
  ##   destination = "/tmp/puma.env"
  ## }
  ## # Тут через интерполяцию указываю путь, файл-шаблон для создания юнита системд, что копируем его внутрь в /tmp
  ## provisioner "file" {
  ##   source      = "${path.module}/files/puma.service.tmpl"
  ##   destination = "/tmp/puma.service.tmpl"
  ## }
  ## # А тут вот запускается наш скрипт деплоя, формирующий в ВМ юнит-файл с нужным содержимым и запускающий установленное приложение
  ## provisioner "remote-exec" {
  ##   script = "${path.module}/files/deploy.sh"
  ## }
  ## connection {
  ##   type        = "ssh"
  ##   host        = self.network_interface[0].access_config[0].nat_ip
  ##   user        = "decapaprata"
  ##   agent       = false
  ##   private_key = file(var.connection_key)
  ## }
}

# создаю внешний ip этой ВМ
resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}

# правило открытия порта 9292 на ВМ с приложением
resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  source_ranges = var.source_ranges
  target_tags   = ["reddit-app"]
}
 