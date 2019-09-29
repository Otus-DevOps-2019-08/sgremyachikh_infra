# Пилю инстанс группу для инстансов
data "google_compute_instance_group" "all" {
    name = "instance-group-name"
    zone = var.instance_zone
    instances = "redddit-app"
}
resource "google_compute_target_http_proxy" "default" {
  name        = "test-proxy"
  url_map     = "${google_compute_url_map.default.self_link}"
}

resource "google_compute_url_map" "default" {
  name        = "url-map"
  default_service = "${google_compute_backend_service.default.self_link}"

  host_rule {
    hosts        = ["reddit-app"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = "${google_compute_backend_service.default.self_link}"

    path_rule {
      paths   = ["/*"]
      service = "${google_compute_backend_service.default.self_link}"
    }
  }
}

resource "google_compute_backend_service" "default" {
  name        = "backend-service"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10
  
  health_checks = ["${google_compute_http_health_check.default.self_link}"]
}

resource "google_compute_http_health_check" "default" {
  name               = "http-health-check"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
  port               = 9292
}