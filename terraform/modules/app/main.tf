# Создание виртуалки
resource "google_compute_instance" "app" {
  name         = "reddit-app-${var.environment}"
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
}

# создаю внешний ip этой ВМ
resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip-${var.environment}"
}

# правило открытия порта 9292 на ВМ с приложением
resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default-${var.environment}"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  source_ranges = var.source_ranges
  target_tags   = ["reddit-app"]
}
 