#!/bin/bash

# 환경 변수 설정
export SHELL=/bin/bash
export PATH=/sbin:/bin:/usr/sbin/:/usr/bin
USERNAME="rpzjawltkdydwk"

# 초기 계정 생성
echo "======================================="
echo "[Creating an Initial Account]"
sudo useradd $USERNAME
echo "$USERNAME:flsnrtm@1234" | sudo chpasswd
sudo usermod -aG wheel $USERNAME
echo "======================================="

# 불필요한 서비스 비활성화 및 미사용 계정 제거
echo "======================================="
echo "[Disable SELinux]"
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sudo sed -i '/^PasswordAuthentication/s/.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo "======================================="

# 사용 패키지 설치
echo "======================================="
echo "[Installation of your package]"
sudo yum install -y telnet wget net-tools sysstat psmisc
sudo yum update -y
echo "======================================="

rm -rf ./init_script.sh
