Packer Reference (Google) 
https://developer.hashicorp.com/packer/integrations/hashicorp/googlecompute

Google Auth 내용 (진행 필요)
Reference : https://developer.hashicorp.com/packer/integrations/hashicorp/googlecompute#precedence-of-authentication-methods
CLI : gcloud auth application-default login --project=gcp-ie3

방화벽 작업 내용 (진행 필요)
Reference : https://developer.hashicorp.com/packer/integrations/hashicorp/googlecompute#windows-example
CLI :   gcloud compute firewall-rules create allow-winrm --allow tcp:22 (linux)
        gcloud compute firewall-rules create allow-winrm --allow tcp:5986 (windows)

이미지 참고 사항
ㅡ rocky 8 
: wheel 그룹 권한에 초기 계정 권한 필요합니다.