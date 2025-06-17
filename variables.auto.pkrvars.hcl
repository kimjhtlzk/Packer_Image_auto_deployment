############################################################
# [Common]
############################################################
company                         = "com2"
default_service_name            = "basic"
############################################################

############################################################
# [Google]
############################################################
gcp_project_id                  = "gcp-ie3"
gcp_zone                        = "asia-northeast3-a"
gcp_machine_type                = "n1-standard-2"

############################################################
# [Tencent]
############################################################
tc_secret_id                    = "*********************"
tc_secret_key                   = "*********************"
tc_disk_type                    = "CLOUD_PREMIUM"
tc_instance_type                = "S3.MEDIUM4"
tc_internet_max_bandwidth_out   = "100"
tc_associate_public_ip_address  = "true"
tc_image_share_accounts         = [
    # [개발]    
#    "123123132", # tc-infrac-test
    # [상용]    
#    "123132132", # tc-infrac-live
]
tc_vpc_id                       = "vpc-3cz7t3tu"
tc_subnet_id                    = "subnet-8txf3gtz"
tc_region                       = "ap-seoul"
tc_zone                         = "ap-seoul-1"
tc_security_group_id            = "sg-fglo4nqp"
tc_image_copy_regions           = [
    # "ap-seoul", # 서울, 복사 제외
    "ap-shanghai",
    "na-siliconvalley",
    "ap-singapore",
    "ap-jakarta",
    "ap-bangkok",
    "sa-saopaulo",
    "na-ashburn",
    "eu-frankfurt",
]
############################################################
# [AWS]
############################################################
# [Project infrac-live]
aws_access_key			        = "*********************"
aws_secret_key			        = "*********************"

aws_instance_type               = "c7i.large"
aws_ami_users                   = [
    # [개발]
    "123123132", # c2s-centralserver
    # [상용]
    "132123132", # starseed-live
]
# [Seoul]
# igw 연결 필요 (packer 실행 서버와의 통신이 필요함)
aws_vpc_id                      = "vpc-0e35afb603"
# 서브넷 퍼블릭 ipv4 주소 할당 설정 확인 필요
aws_region                      = "ap-northeast-2"
aws_subnet_id                   = "subnet-0f4c9112f"
aws_ami_regions                 = [
    # "ap-northeast-2", # 서울, 복사 제외
    "ap-northeast-1", # 도쿄
    "us-west-1", # 캘리포니아    
]
