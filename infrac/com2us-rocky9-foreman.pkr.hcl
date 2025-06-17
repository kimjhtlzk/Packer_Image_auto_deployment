packer {
  required_plugins {
    googlecompute = {
      version = "~> 1"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}
#################################################################################
variable "project_id" {
  type = string
}

variable "zone" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "company" {
  type = string
}

variable "os_rocky" {
  type = string
}
#################################################################################
locals {
  os_version   = "9"
  service_name = "foreman"
}

source "googlecompute" "rocky" {
  source_image_family      = "rocky-linux-${local.os_version}" # 최신 이미지
  image_name               = "${var.company}-${var.os_rocky}${local.os_version}-${local.service_name}"

  project_id               = var.project_id
  zone                     = var.zone
  machine_type             = var.machine_type

  ssh_username             = "packer"

  image_labels = {
    "base-pulbic-image"    = "rocky-linux-${local.os_version}"
  }
}

build {
  sources = [
    "source.googlecompute.${var.os_rocky}"
  ]

#################################################################################
# 이미지 적용 내용 (1)
  provisioner "shell" {
    scripts = [
      "../script/linux/init_script.sh",
    ]
  }

# 이미지 적용 내용 (2)
  provisioner "file" {
    source      = "../files/linux/setting.sh"
    destination = "~/linux_setting_v1.sh"
  }

#################################################################################
# 구글 이미지 생성 이후 공유 작업 내용
  post-processor "shell-local" {
    inline = [
      "chmod +x ./files/google.sh",
      "./files/google.sh ${var.company}-${var.os_rocky}${local.os_version}-${local.service_name}",
    ]
  }
#################################################################################
# 이후 작업 내용

  # service install 
  provisioner "shell" {
    environment_vars = [
      "SHELL=/bin/bash",
      "PATH=/sbin:/bin:/usr/sbin/:/usr/bin",
    ]

    inline = [
      "echo =======================================",
      "echo [Foreman install]",
      "sudo dnf -y install https://yum.puppet.com/puppet7-release-el-9.noarch.rpm",
      "sudo dnf -y install https://yum.theforeman.org/releases/3.11/el9/x86_64/foreman-release.rpm",
      "sudo dnf -y install https://cdn.azul.com/zulu/bin/zulu17.48.15-ca-jdk17.0.10-linux.x86_64.rpm",
      "sudo dnf -y module enable postgresql:13",
      "sudo dnf -y module enable redis:7",
      "sudo dnf -y install foreman-installer",
      "echo =======================================",
    ]
  }
}

