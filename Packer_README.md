Packer install 
https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli#installing-packer

※ 참고 사항
OS 이미지 provisioner 의 inline 작성시 실제로 유효한 명령어를 누적해서 사용해야 됩니다.
ㄴ 실제 존재하지 않거나, 그냥 던져 보는 방식의 작업을 누적시 이미지는 생성되지 않습니다. 
ㄴ 직접 확인하고 불필요하지 않은 작업으로 내용을 누적 시켜서 관리해야 됩니다.

○ 이미지 일원화 목표 내용
1. 리눅스
ㅡ 초기 계정 설정 (ID : rpzjawltkdydwk / flsnrtm@1234)
: 작업자 접근시 키 인증 방식이 아닌 패스워드 인증 방식으로 목표

ㅡ 불필요한 계정 / 서비스 삭제 및 비활성화
: 퍼블릭 클라우드별 불필요한 계정 / 서비스 확인 후 정리 목표
(작성 방식은 inline 을 통해 플랫폼의 OS별 정의 작성)

1-1 불필요한 계정 항목


1-2 불필요한 서비스 항목

ㅡ 이미지 이후에 작업자가 실행 시킬 script 내용 업데이트 간소화
: 해당 과정에서 Packer 도구로 실행된 계정 제거 예정 (ex, ec2-user, rocky, centos 등)

2. 윈도우
ㅡ 초기 계정 설정 (ID : rpzjawltkdydwk / flsnrtm@1234)
: 작업자 접근시 키 인증 방식이 아닌 패스워드 인증 방식으로 목표


