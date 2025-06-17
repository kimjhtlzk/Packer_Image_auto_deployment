# Build for Rocky 9
source "tencentcloud-cvm" "rocky9" {
  image_name                  = "${var.company}-rocky9-${var.default_service_name}"
  secret_id                   = var.tc_secret_id
  secret_key                  = var.tc_secret_key

  disk_type                   = var.tc_disk_type
  instance_type               = var.tc_instance_type
  vpc_id                      = var.tc_vpc_id
  subnet_id                   = var.tc_subnet_id
  source_image_id             = "img-39ei7bw5" # Rocky 9.4
  region                      = var.tc_region
  zone                        = var.tc_zone
  security_group_id           = var.tc_security_group_id
  associate_public_ip_address = var.tc_associate_public_ip_address
  image_share_accounts        = var.tc_image_share_accounts
  image_copy_regions          = var.tc_image_copy_regions
  
  ssh_username                = "root"

  image_tags = {
    "base-pulbic-image"       = "img-39ei7bw5" # Rocky 9.4
  }

  run_tags = {
    packer = "Working.."
  }  

}
build {
  sources = [
    "source.tencentcloud-cvm.rocky9"
  ]

#################################################################################
# 이미지 적용 내용 (1)
  provisioner "shell" {
    scripts = ["../script/linux/init_script.sh"]
  }

# 이미지 적용 내용 (2)
  provisioner "file" {
    source      = "../files/linux/setting.sh"
    destination = "/tmp/linux_setting_v1.sh"
  }

#################################################################################

}