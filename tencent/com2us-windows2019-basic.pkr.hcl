packer {
  required_plugins {
    tencentcloud = {
      version = "~> 1"
      source  = "github.com/hashicorp/tencentcloud"
    }
  }
}
#################################################################################
variable "secret_id" {
  type    = string
  default = "${env("TENCENTCLOUD_SECRET_ID")}"
}

variable "secret_key" {
  type    = string
  default = "${env("TENCENTCLOUD_SECRET_KEY")}"
}

variable "company" {
  type = string
}

variable "os_winddows" {
  type = string
}

variable "tc_profile" {
  type = string
}

variable "tc_disk_type" {
  type = string
}

variable "tc_instance_type" {
  type = string
}

variable "tc_vpc_id" {
  type = string
}

variable "tc_subnet_id" {
  type = string
}

variable "tc_win2019_id" {
  type = string
}

variable "tc_region" {
  type = string
}

variable "tc_zone" {
  type = string
}

variable "tc_security_group_id" {
  type = string
}

variable "internet_max_bandwidth_out" {
  type = string
}

variable "communicator" {
  type = string
}

variable "winrm_user" {
  type = string
}

variable "winrm_password" {
  type = string
}

variable "winrm_insecure" {
  type = bool
}

variable "winrm_use_ssl" {
  type = bool
}

variable "associate_public_ip_address" {
  type = bool
}

variable "tc_image_share_accounts" {
  type = list(string)
}

#################################################################################

locals {
  os_version                  = "2019"
  service_name                = "basic"
  winrm_user                  = "administrator"
  winrm_password              = "asdasda@1234"
}

source "tencentcloud-cvm" "win" {
  profile                     = var.tc_profile  
  image_name                  = "${var.company}-${var.os_rocky}${local.os_version}-${local.service_name}"

  disk_type                   = var.tc_disk_type
  instance_type               = var.tc_instance_type
  vpc_id                      = var.tc_vpc_id
  subnet_id                   = var.tc_subnet_id
  source_image_id             = var.tc_win2019_id
  region                      = var.tc_region
  zone                        = var.tc_zone
  security_group_id           = var.tc_security_group_id
  internet_max_bandwidth_out  = var.internet_max_bandwidth_out              
  associate_public_ip_address = var.associate_public_ip_address
  image_share_accounts        = var.tc_image_share_accounts

  secret_id                   = var.secret_id
  secret_key                  = var.secret_key
  communicator                = var.communicator
  winrm_username              = var.winrm_user
  winrm_password              = var.winrm_password
  winrm_insecure              = var.winrm_insecure            
  winrm_use_ssl               = var.winrm_use_ssl
  user_data_file              = "./script/${var.windows}-start-script.txt"

  image_tags = {
    "base-pulbic-image"    = "${var.tc_win2019_id}"
  }

  run_tags = {
    packer = "Working.."
  }  

}
################################## 검증 필요 (테스트 환경 부재로 보류) #######################################
build {
  sources = [
    "source.tencentcloud-cvm.${var.windows}"
  ]
  ################################## 검증 필요 (테스트 환경 부재로 보류) #######################################

  # setting 스크립트 및 기타 파일 내용
  provisioner "file" {
    source      = "../files/${var.windows}/"
    destination = "C:\\zabbix\\"
  }

  provisioner "powershell" {
    scripts = [
      "../script/${var.windows}${local.os_version}/language_pack.ps1",
    ]
  }

  provisioner "powershell" {
    inline = [
      "dism /online /add-package /packagepath:C:\\language_pack_ko-kr.cab",
      "dism /online /get-intl",
    ]
  }

  provisioner "powershell" {
    scripts = [
      "../script/${var.windows}${local.os_version}/init_script.ps1",
    ]
  }

  provisioner "file" {
    source      = "./files/${var.windows}/Unattend.xml"
    destination = "C:\\windows\\"
  }

  provisioner "powershell" {
    inline = [
      "C:\\Windows\\System32\\sysprep\\sysprep.exe /generalize /oobe /unattend:C:\\windows\\Unattend.xml"
    ]
  }

}
