# =============================================================================
# versions.tf
# Объявление версий Terraform и провайдера Yandex Cloud.
# =============================================================================

terraform {
  # Минимальная версия Terraform, необходимая для работы проекта.
  required_version = ">= 1.5.0"

  required_providers {
    # Официальный провайдер Yandex Cloud.
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.130.0"
    }
  }
}