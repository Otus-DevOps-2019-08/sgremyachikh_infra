# Создание виртуалки
resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "g1-small"
  zone         = var.instance_zone
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

# создаю внешний ip
resource "google_compute_address" "app_ip" { 
  name = "reddit-app-ip" 
}

# правило открытия порта 9292 на ВМ с приложением
resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports = ["9292"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["reddit-app"]
}
