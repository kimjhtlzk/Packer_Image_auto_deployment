# Build for Window 2019
source "googlecompute" "win2019" {
  source_image_family           = "windows-2019" # 최신 이미지
  image_name                    = "${var.company}-win2019-${var.default_service_name}"

  project_id                    = var.gcp_project_id
  zone                          = var.gcp_zone
  machine_type                  = var.gcp_machine_type
  disk_size                     = "50"

  winrm_username                = "administrator"
  winrm_password                = "asdasd@1234"
  communicator                  = "winrm"
  winrm_insecure                = "true"
  winrm_use_ssl                 = "false"

  metadata_files = {
    "sysprep-specialize-script-ps1" = "./files/init.ps1"
  }

  image_labels = {
    "base-pulbic-image"    = "windows-2019"
  }
}

# Build for Window 2019 + MSSQL 2019
source "googlecompute" "win2019-mssql2019" {
  source_image_family           = "sql-std-2019-win-2019" # 최신 이미지
  image_name                    = "${var.company}-win2019-mssql2019"

  project_id                    = var.gcp_project_id
  zone                          = var.gcp_zone
  machine_type                  = var.gcp_machine_type
  disk_size                     = "50"

  winrm_username                = "administrator"
  winrm_password                = "adsafㅇㄴㄹ@1234"
  communicator                  = "winrm"
  winrm_insecure                = "true"
  winrm_use_ssl                 = "false"

  metadata_files = {
    "sysprep-specialize-script-ps1" = "./files/init.ps1"
  }

  image_labels = {
    "base-pulbic-image"    = "sql-std-2019-win-2019"
  }
}

#################################################################################

build {
  sources = [
    "sources.googlecompute.win2019",
    "sources.googlecompute.win2019-mssql2019"
  ]

# 이미지 적용 내용 (1)
  provisioner "file" {
    source      = "./files/autounattend.xml"
    destination = "C:/Program Files/Google/Compute Engine/sysprep/unattended.xml"
  }
 
  provisioner "powershell" {
    scripts = [
      "../script/win2019/language_pack.ps1",
      "../script/win2019/init_script.ps1"  
    ]
  }

# 이미지 적용 내용 (2)
  provisioner "file" {
    source      = "../files/win/"
    destination = "C:\\zabbix\\"
  }

# 이미지 적용 내용 (3)
  provisioner "powershell" {
    inline = [
      "powershell -ExecutionPolicy Bypass -File \"C:/Program Files/Google/Compute Engine/sysprep/sysprep.ps1\""
    ]
  }

#################################################################################
# 구글 이미지 생성 이후 공유 작업 내용
  post-processor "shell-local" {
    only = [ "googlecompute.win2019" ]
    inline = [
      "chmod +x ./files/google.sh",
      "./files/google.sh ${var.company}-win2019-${var.default_service_name}",
    ]
  }

  post-processor "shell-local" {
    only = [ "googlecompute.win2019-mssql2019" ]
    inline = [
      "chmod +x ./files/google.sh",
      "./files/google.sh ${var.company}-win2019-mssql2019",
    ]
  }
}