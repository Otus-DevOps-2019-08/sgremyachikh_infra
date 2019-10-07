## создаю лоад балансер
# указываю группу инстансов
resource "google_compute_instance_group" "reddit-lb" {
  name        = "reddit-lb"
  description = "LoadBalancer for reddit-app instances"
  # все инстансы, которые в main создавал вот таким вот ресурсом:
  instances = [
    "${google_compute_instance.app[0].self_link}",
    "${google_compute_instance.app[1].self_link}"
  ]
  named_port {
    name = "reddit-port"
    port = "${var.app_port}"
  }
  zone = "${var.instance_zone}"
}

# создаю хелсчек для проверок инстансов
resource "google_compute_http_health_check" "reddit-hc" {
  name               = "reddit-hc"
  request_path       = "/"
  # тут он будет бегать на 9292 и смотреть жива ли нода
  port               = "${var.app_port}"
  # каждые 5 сек
  check_interval_sec = 5
  # максимальный таймаут
  timeout_sec        = 3
}

# создаю бэкенд сервис (группу которая на которую идет баллансировка)
resource "google_compute_backend_service" "reddit-back" {
  name          = "reddit-back"
  port_name     = "reddit-port"
  protocol      = "HTTP"
  timeout_sec   = 5
  # у бэкенда должен быть хелсчек чтоб занать что у нас в бэке и что мы может отдавать, описан выше
  health_checks = ["${google_compute_http_health_check.reddit-hc.self_link}"]
  # мы указываем группу, которую создали в начале
  backend {
    group = "${google_compute_instance_group.reddit-lb.self_link}"
  }
}

# создаю глобальное правило форвардинга (для проксирования)
resource "google_compute_global_forwarding_rule" "reddit-fwd-rule" {
  name        = "reddit-fwd-rule"
  description = "reddit-fwd-rule"
  # правило форвардинна указывает на прокси:
  target      = "${google_compute_target_http_proxy.reddit-proxy.self_link}"
  port_range  = "80"
}

# создаю http прокси
resource "google_compute_target_http_proxy" "reddit-proxy" {
  name        = "reddit-proxy"
  description = "reddit-proxy"
  # которое использует карту урлов
  url_map     = "${google_compute_url_map.reddit-url-map.self_link}"
}

# создаю карту улов
resource "google_compute_url_map" "reddit-url-map" {
  name            = "reddit-url-map"
  description     = "reddit-url-map"
  # использу.ю указанный бэкенд
  default_service = "${google_compute_backend_service.reddit-back.self_link}"
  # участвуют хосты бэка:
  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }
  # все пути указанные
  path_matcher {
    name            = "allpaths"
    default_service = "${google_compute_backend_service.reddit-back.self_link}"
  # правило путей
    path_rule {
      paths   = ["/*"]
      service = "${google_compute_backend_service.reddit-back.self_link}"
    }
  }
}
