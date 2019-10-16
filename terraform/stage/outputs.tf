# айпишник внешний
output "app_external_ip" {
  value = module.app.app_external_ip
# внешний линк на приложение
}
output "app_url" {
  value = "http://${module.app.app_external_ip}:9292"
}
# локальный айпишних ВМ с монгой
output "db_instance_ip" {
  value = module.db.db_internal_ip
}
# датабейс урл
output "database_url" {
  value = "${module.db.db_internal_ip}:27017"
}
