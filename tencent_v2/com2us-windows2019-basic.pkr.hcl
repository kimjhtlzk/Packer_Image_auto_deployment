# Build for windows 2019
source "tencentcloud-cvm" "win2019" {
  image_name                  = "${var.company}-win2019-${var.default_service_name}"
  secret_id                   = var.tc_secret_id
  secret_key                  = var.tc_secret_key  

  disk_type                   = var.tc_disk_type
  instance_type               = var.tc_instance_type
  vpc_id                      = var.tc_vpc_id
  subnet_id                   = var.tc_subnet_id
  source_image_id             = "img-bhvhr6pr" # Windows 2019 DataCenter 
  region                      = var.tc_region
  zone                        = var.tc_zone
  security_group_id           = var.tc_security_group_id
  associate_public_ip_address = var.tc_associate_public_ip_address
  image_share_accounts        = var.tc_image_share_accounts
  image_copy_regions          = var.tc_image_copy_regions


  winrm_username                = "administrator"
  winrm_password                = "sdfsdf@1234"
  communicator                  = "winrm"
  winrm_insecure                = "true"
  winrm_use_ssl                 = "false"

  user_data_file              = "./script/win-start-script.txt"

  image_tags = {
    "base-pulbic-image"    = "img-bhvhr6pr"
  }

  run_tags = {
    packer = "Working.."
  }  

}
################################## 검증 필요 (테스트 환경 부재로 보류) #######################################
build {
  sources = [
    "sources.googlecompute.win2019",
  ]
  ################################## 검증 필요 (테스트 환경 부재로 보류) #######################################

# 이미지 적용 내용 (2)
  provisioner "file" {
    source      = "../files/win/"
    destination = "C:\\zabbix\\"
  }


  provisioner "powershell" {
    scripts = [
      "../script/win2019/language_pack.ps1",
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
      "../script/win2019/init_script.ps1",
    ]
  }

  provisioner "file" {
    source      = "./files/win/Unattend.xml"
    destination = "C:\\windows\\"
  }

  provisioner "powershell" {
    inline = [
      "C:\\Windows\\System32\\sysprep\\sysprep.exe /generalize /oobe /unattend:C:\\windows\\Unattend.xml"
    ]
  }

}
