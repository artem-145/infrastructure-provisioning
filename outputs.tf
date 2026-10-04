# =============================================================================
# outputs.tf
# Вывод ключевых данных после применения конфигурации.
# =============================================================================

# Публичный IP-адрес виртуальной машины (для SSH-подключения).
output "vm_public_ip" {
  description = "Публичный IP-адрес виртуальной машины"
  value       = yandex_compute_instance.vm.network_interface[0].nat_ip_address
}

# Внутренний IP-адрес виртуальной машины.
output "vm_internal_ip" {
  description = "Внутренний IP-адрес виртуальной машины"
  value       = yandex_compute_instance.vm.network_interface[0].ip_address
}

# Идентификатор VPC-сети.
output "network_id" {
  description = "Идентификатор VPC-сети"
  value       = yandex_vpc_network.main.id
}

# Идентификатор подсети.
output "subnet_id" {
  description = "Идентификатор подсети"
  value       = yandex_vpc_subnet.main.id
}

# Идентификатор виртуальной машины.
output "vm_id" {
  description = "Идентификатор виртуальной машины"
  value       = yandex_compute_instance.vm.id
}

# Готовая команда для SSH-подключения к ВМ.
output "ssh_command" {
  description = "Команда для SSH-подключения к виртуальной машине"
  value       = "ssh ${var.vm_username}@${yandex_compute_instance.vm.network_interface[0].nat_ip_address}"
}