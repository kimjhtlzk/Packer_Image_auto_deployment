#################################################################################

source "amazon-ebs" "win2019" {
  ami_name                = "${var.company}-win2019-${var.default_service_name}"
  access_key              = var.aws_access_key
  secret_key              = var.aws_secret_key
  
  region                  = var.aws_region
  vpc_id                  = var.aws_vpc_id
  subnet_id               = var.aws_subnet_id
  ami_users               = var.aws_ami_users
  ami_regions             = var.aws_ami_regions
  instance_type           = var.aws_instance_type

  source_ami_filter {
    filters = {
      name                = "Windows_Server-2019-English-Full-Base-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  user_data_file          = "./script/win-start-script.txt"
  communicator            = "winrm"
  winrm_username          = "Administrator"
  winrm_password          = "asdasdas@1234"

  tags = {
    base-pulbic-image     = "{{ .SourceAMIName }}"
    Name                  = "${var.company}-win2019-${var.default_service_name}"
  }
}

source "amazon-ebs" "win2019-mssql2019" {
  ami_name                = "${var.company}-win2019-mssql2019"
  access_key              = var.aws_access_key
  secret_key              = var.aws_secret_key
  region                  = var.aws_region
  vpc_id                  = var.aws_vpc_id
  subnet_id               = var.aws_subnet_id
  ami_users               = var.aws_ami_users
  ami_regions             = var.aws_ami_regions
  instance_type           = var.aws_instance_type

  source_ami_filter {
    filters = {
      name                = "Windows_Server-2019-English-Full-SQL_2019_Standard*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  user_data_file          = "./script/win-start-script.txt"
  communicator            = "winrm"
  winrm_username          = "Administrator"
  winrm_password          = "asdasdas@1234"

  tags = {
    base-pulbic-image     = "{{ .SourceAMIName }}"
    Name                  = "${var.company}-win2019-mssql2019"
  }
}
#################################################################################
build {
  sources = [
    "source.amazon-ebs.win2019",
    "source.amazon-ebs.win2019-mssql2019"
  ]

# 이미지 적용 내용 (1)
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
  # https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/sysprep-troubleshoot.html
  provisioner "file" {
    source      = "./files/win2019/Unattend.xml"
    destination = "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Sysprep\\Unattend.xml"
  }

  provisioner "powershell" {
    inline = [
      "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\InitializeInstance.ps1 -Schedule",
      "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\SysprepInstance.ps1"
    ]
  }
}