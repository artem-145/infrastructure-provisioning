# Infrastructure Provisioning (Yandex Cloud)

Профессиональный Terraform-проект для развёртывания базовой инфраструктуры в
**Yandex Cloud**: VPC-сеть, подсеть, security group и виртуальная машина
Compute Cloud с публичным IP и SSH-доступом через cloud-init.

## Возможности

- 🏗️ VPC-сеть и подсеть в указанной зоне доступности.
- 🔒 Security group с минимально необходимыми правилами (SSH, ICMP, исходящий трафик).
- 🖥️ Виртуальная машина Compute Cloud с публичным IP (`nat = true`).
- 🔑 Автоматическая настройка пользователя и SSH-ключа через cloud-init.
- 🔐 Без хардкода секретов: всё через переменные и переменные окружения.

## Структура проекта

```
infrastructure-provisioning/
├── .gitignore                  # Исключаем секреты, tfstate, .terraform
├── versions.tf                 # Версии Terraform и провайдера
├── providers.tf                # Настройка провайдера Yandex Cloud
├── variables.tf                # Объявления всех переменных
├── main.tf                     # VPC, подсеть, security group, ВМ + cloud-init
├── outputs.tf                  # Публичный IP, ID сети/подсети/ВМ
├── terraform.tfvars.example    # Пример значений переменных (без секретов)
└── README.md                   # Этот файл
```

## Требования

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5.0
- [Yandex Cloud CLI](https://cloud.yandex.ru/docs/cli/) (опционально, для получения ID)
- Аккаунт в Yandex Cloud

## Быстрый старт

### 1. Настройка аутентификации

Провайдер использует переменные окружения. Выберите один из способов:

**Способ A — OAuth-токен (для личного аккаунта):**

```bash
export YC_TOKEN="<ваш OAuth-токен>"
```

**Способ B — ключ сервисного аккаунта (рекомендуется для продакшена):**

```bash
export YC_SERVICE_ACCOUNT_KEY_FILE="/path/to/authorized_key.json"
```

### 2. Настройка переменных

Скопируйте пример и заполните реальные значения:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Отредактируйте `terraform.tfvars`:

- `cloud_id` и `folder_id` — получите через `yc config list` или в консоли Yandex Cloud.
- `vm_image_id` — ID образа ОС. Получить список:
  ```bash
  yc compute image list --folder-id <folder_id>
  ```
- `ssh_public_key` — содержимое вашего публичного ключа (например, `~/.ssh/id_rsa.pub`).

> ⚠️ `terraform.tfvars` игнорируется git и не должен попадать в репозиторий.

### 3. Инициализация и применение

```bash
terraform init      # скачивает провайдер
terraform plan      # показывает план изменений
terraform apply     # создаёт инфраструктуру
```

После `apply` в выводе появятся:

- `vm_public_ip` — публичный IP виртуальной машины.
- `ssh_command` — готовая команда для подключения.

### 4. Подключение по SSH

```bash
ssh ubuntu@<vm_public_ip>
```

### 5. Удаление инфраструктуры

```bash
terraform destroy
```

## Описание файлов

| Файл | Назначение |
|------|------------|
| `versions.tf` | Фиксирует версии Terraform и провайдера `yandex-cloud/yandex`. |
| `providers.tf` | Настраивает провайдер: `cloud_id`, `folder_id`, `zone`. Аутентификация — через переменные окружения. |
| `variables.tf` | Объявляет все переменные с типами, описаниями и значениями по умолчанию. |
| `main.tf` | Создаёт VPC-сеть, подсеть, security group и виртуальную машину с cloud-init. |
| `outputs.tf` | Выводит публичный/внутренний IP, ID сети/подсети/ВМ и команду SSH. |
| `.gitignore` | Исключает секреты, файлы состояния Terraform и временные файлы. |
| `terraform.tfvars.example` | Шаблон для заполнения реальных значений переменных. |

## Безопасность

- Секреты (токены, ключи) передаются только через переменные окружения.
- SSH-ключ помечен как `sensitive` и не выводится в логи.
- `terraform.tfvars` и файлы состояния исключены из git.
- Рекомендуется ограничить `ssh_allowed_cidr` своим IP-адресом вместо `0.0.0.0/0`.

## Лицензия

MIT