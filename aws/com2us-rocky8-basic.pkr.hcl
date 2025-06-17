# Source for Rocky Linux 8
source "amazon-ebs" "rocky8" {
  ami_name      = "${var.company}-rocky8-${var.default_service_name}"
  access_key    = var.aws_access_key
  secret_key    = var.aws_secret_key
  
  region        = var.aws_region
  vpc_id        = var.aws_vpc_id
  subnet_id     = var.aws_subnet_id
  ami_users     = var.aws_ami_users
  ami_regions   = var.aws_ami_regions
  instance_type = var.aws_instance_type

  source_ami_filter {
    filters = {
      name                = "Rocky-8-EC2-Base-*.x86_64-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["46464687"]
  }

  ssh_username = "rocky"

  tags = {
    base-pulbic-image = "{{ .SourceAMIName }}"
    Name = "${var.company}-rocky8-${var.default_service_name}"
  }
}

#################################################################################

build {
  sources = [
    "source.amazon-ebs.rocky8"
  ]
  provisioner "shell" {
    scripts = ["../script/linux/init_script.sh"]
  }
  provisioner "file" {
    source      = "../files/linux/setting.sh"
    destination = "/tmp/linux_setting_v1.sh"
  }
}