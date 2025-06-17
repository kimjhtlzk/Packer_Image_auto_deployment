#################################################################################

source "amazon-ebs" "win2022" {
  ami_name                = "${var.company}-win2022-${var.default_service_name}"
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
      name                = "Windows_Server-2022-English-Full-Base-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  user_data_file          = "./script/win-start-script.txt"
  communicator            = "winrm"
  winrm_username          = "Administrator"
  winrm_password          = "asdfsdfsd@1234"

  tags = {
    base-pulbic-image     = "{{ .SourceAMIName }}"
    Name                  = "${var.company}-win2022-${var.default_service_name}"
  }
}

source "amazon-ebs" "win2022-mssql2022" {
  ami_name                = "${var.company}-win2022-mssql2022"
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
      name                = "Windows_Server-2022-English-Full-SQL_2022_Standard*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  user_data_file          = "./script/win-start-script.txt"
  communicator            = "winrm"
  winrm_username          = "Administrator"
  winrm_password          = "asdasd@1234"

  tags = {
    base-pulbic-image     = "{{ .SourceAMIName }}"
    Name                  = "${var.company}-win2022-mssql2022"
  }
}
#################################################################################
build {
  sources = [
    "source.amazon-ebs.win2022",
    "source.amazon-ebs.win2022-mssql2022"
  ]

# 이미지 적용 내용 (1)
  provisioner "powershell" {
    scripts = [
      "../script/win2022/language_pack.ps1",
      "../script/win2022/init_script.ps1"
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
    source      = "./files/win2022/Unattend.xml"
    destination = "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Sysprep\\Unattend.xml"
  }

  # https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/WindowsGuide/ec2launch-v2.html (미진행)
  # sysprep : https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/WindowsGuide/ec2launch-v2-settings.html#ec2launch-v2-sysprep
  # https://learn.microsoft.com/ko-kr/windows-hardware/manufacture/desktop/sysprep-command-line-options?view=windows-11
  provisioner "powershell" {
    inline = [
      "Remove-Item \"C:\\ProgramData\\Amazon\\EC2Launch\\state\\.run-once\" -force",
      "C:\\Windows\\System32\\Sysprep\\sysprep.exe /unattend:\"C:\\ProgramData\\Amazon\\EC2Launch\\Sysprep\\Unattend.xml\" /oobe /generalize /shutdown"
    ]
  }
}