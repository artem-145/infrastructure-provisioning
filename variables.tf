# =============================================================================
# variables.tf
# Объявление всех переменных проекта.
# Значения задаются в terraform.tfvars или через переменные окружения.
# =============================================================================

# --- Идентификаторы Yandex Cloud -------------------------------------------

variable "cloud_id" {
  description = "Идентификатор облака (cloud_id) в Yandex Cloud."
  type        = string
}

variable "folder_id" {
  description = "Идентификатор каталога (folder_id) в Yandex Cloud."
  type        = string
}

variable "zone" {
  description = "Зона доступности по умолчанию."
  type        = string
  default     = "ru-central1-a"
}

# --- Сеть (VPC) -------------------------------------------------------------

variable "network_name" {
  description = "Имя VPC-сети."
  type        = string
  default     = "main-network"
}

variable "subnet_name" {
  description = "Имя подсети."
  type        = string
  default     = "main-subnet"
}

variable "subnet_cidr" {
  description = "Список CIDR-диапазонов подсети."
  type        = list(string)
  default     = ["10.0.0.0/24"]
}

# --- Виртуальная машина -----------------------------------------------------

variable "vm_name" {
  description = "Имя виртуальной машины."
  type        = string
  default     = "web-server"
}

variable "vm_cores" {
  description = "Количество vCPU виртуальной машины."
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "Объём оперативной памяти ВМ в ГБ."
  type        = number
  default     = 2
}

variable "vm_disk_size" {
  description = "Размер загрузочного диска ВМ в ГБ."
  type        = number
  default     = 20
}

variable "vm_image_id" {
  description = "ID образа ОС для загрузочного диска (например, Ubuntu 22.04 LTS)."
  type        = string
}

variable "vm_username" {
  description = "Имя пользователя, создаваемого на ВМ для SSH-доступа."
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "Публичный SSH-ключ для доступа к ВМ (sensitive)."
  type        = string
  sensitive   = true
}

variable "ssh_allowed_cidr" {
  description = "Список CIDR, из которых разрешён SSH-доступ к ВМ."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "preemptible" {
  description = "Использовать ли прерываемую ВМ (дешевле, но может быть остановлена)."
  type        = bool
  default     = false
}

# --- Общие метки ------------------------------------------------------------

variable "labels" {
  description = "Метки (labels), применяемые к ресурсам."
  type        = map(string)
  default = {
    environment = "dev"
    managed_by  = "terraform"
  }
}