# =============================================================================
# main.tf
# Основные ресурсы: VPC-сеть, подсеть, security group и виртуальная машина.
# =============================================================================

# -----------------------------------------------------------------------------
# VPC-сеть
# -----------------------------------------------------------------------------
resource "yandex_vpc_network" "main" {
  name        = var.network_name
  description = "Основная VPC-сеть для инфраструктуры"
  labels      = var.labels
}

# -----------------------------------------------------------------------------
# Подсеть в указанной зоне доступности
# -----------------------------------------------------------------------------
resource "yandex_vpc_subnet" "main" {
  name           = var.subnet_name
  description    = "Подсеть для виртуальной машины"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = var.subnet_cidr
  labels         = var.labels
}

# -----------------------------------------------------------------------------
# Security Group: правила доступа к ВМ
# -----------------------------------------------------------------------------
resource "yandex_vpc_security_group" "main" {
  name        = "main-sg"
  description = "Правила доступа к виртуальной машине"
  network_id  = yandex_vpc_network.main.id
  labels      = var.labels

  # Входящий SSH-трафик (порт 22) из разрешённых CIDR.
  ingress {
    description    = "SSH access"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = var.ssh_allowed_cidr
  }

  # Входящий ICMP-трафик (ping) из разрешённых CIDR.
  ingress {
    description    = "ICMP (ping)"
    protocol       = "ICMP"
    v4_cidr_blocks = var.ssh_allowed_cidr
  }

  # Исходящий трафик разрешён полностью.
  egress {
    description    = "Allow all outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# -----------------------------------------------------------------------------
# Cloud-init скрипт: создание пользователя и настройка SSH-доступа
# -----------------------------------------------------------------------------
locals {
  cloud_init = <<-EOT
    #cloud-config
    users:
      - name: ${var.vm_username}
        groups: sudo
        shell: /bin/bash
        sudo: ALL=(ALL) NOPASSWD:ALL
        ssh_authorized_keys:
          - ${var.ssh_public_key}
    package_update: true
    packages:
      - curl
      - htop
  EOT
}

# -----------------------------------------------------------------------------
# Виртуальная машина Compute Cloud
# -----------------------------------------------------------------------------
resource "yandex_compute_instance" "vm" {
  name        = var.vm_name
  description = "Виртуальная машина с публичным IP и SSH-доступом"
  zone        = var.zone
  labels      = var.labels

  # Прерываемая ВМ (дешевле, но может быть остановлена облаком).
  allow_stopping_for_update = true

  resources {
    cores  = var.vm_cores
    memory = var.vm_memory
  }

  # Загрузочный диск из указанного образа ОС.
  boot_disk {
    initialize_params {
      image_id = var.vm_image_id
      size     = var.vm_disk_size
      type     = "network-hdd"
    }
  }

  # Сетевой интерфейс: nat = true выдаёт публичный IP.
  network_interface {
    subnet_id          = yandex_vpc_subnet.main.id
    security_group_ids = [yandex_vpc_security_group.main.id]
    nat                = true
  }

  # Метаданные: cloud-init для настройки пользователя и SSH-ключа.
  metadata = {
    user-data = local.cloud_init
  }

  scheduling_policy {
    preemptible = var.preemptible
  }
}