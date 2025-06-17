packer {
  required_plugins {
    azure = {
      version = "~> 2"
      source  = "github.com/hashicorp/azure"
    }
  }
}

locals {
  timestamp    = regex_replace(timestamp(), "[- TZ:]", "")
  initial_user = "rpzjawltkdydwk"
  os_name      = "rocky8"
  service_name = "basic"
}

source "azure-arm" "rocky8" {
  azure_tags = {
    dept = "Engineering"
    task = "Image deployment"
  }
  client_id                         = "******-****-****-****-*********"
  client_secret                     = "******-****-****-****-*********"
  image_offer                       = "0001-com-ubuntu-server-jammy"
  image_publisher                   = "canonical"
  image_sku                         = "22_04-lts"
  location                          = "East US"
  managed_image_name                = "myPackerImage"
  managed_image_resource_group_name = "myResourceGroup"
  os_type                           = "Linux"
  subscription_id                   = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"
  tenant_id                         = "******-****-****-****-*********"
  vm_size                           = "Standard_DS2_v2"
}
################################## 검증 필요 (테스트 환경 부재로 보류) #######################################
build {
  sources = [
    # "source.azure-arm.${local.os_name}"
  ]
################################## 검증 필요 (테스트 환경 부재로 보류) #######################################

  provisioner "shell" {
    # 환경 변수 선언 내용
    environment_vars = [
      "SHELL=/bin/bash",
      "PATH=/sbin:/bin:/usr/sbin/:/usr/bin",
      # 초기 계정 변수 선언 내용
      "USERNAME=rpzjawltkdydwk"
    ]

    inline = [
      # 초기 계정 생성 내용 (rpzjalwtkdydwk)
      "echo =======================================",
      "echo [Creating an Initial Account]",
      "sudo useradd $USERNAME",
      "echo 'rpzjawltkdydwk:flsnrtm@1234' | sudo chpasswd",
      "sudo usermod -aG wheel $USERNAME",
      "echo =======================================",
      # 불필요한 서비스 비활성화 및 미사용 계정 제거 내용 내용
      "echo =======================================",
      "echo [Disable Selinux]",
      "sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config",
      "sudo sed -i '/^PasswordAuthentication/s/.*/PasswordAuthentication yes/' /etc/ssh/sshd_config",
      "echo =======================================",
      # 사용 패키지 설치 내용
      "echo =======================================",
      "echo [Installation of your package]",
      "sudo dnf install -y telnet wget net-tools sysstat psmisc",
      "sudo dnf update -y",
      "echo =======================================",
    ]
  }

  # setting 스크립트 및 기타 파일 내용
  provisioner "file" {
    source      = "../files/linux/setting.sh"
    destination = "/home/${local.initial_user}/setting.sh"
  }
}

