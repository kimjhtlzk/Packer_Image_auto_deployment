Packer Reference (AWS)
https://developer.hashicorp.com/packer/integrations/hashicorp/amazon

ami 생성시 참고 사항
packer 동작시 아래의 aws 환경 조성이 필요합니다.
(VPC - subnet - igw 연결 확인)

이미지 참고 사항
ㅡ amz2 / rocky 8 
: wheel 그룹 권한을 주지 않아도 초기 계정은 root 권한 받아 사용 가능합니다.