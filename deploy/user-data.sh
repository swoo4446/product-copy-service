#!/usr/bin/env bash
# Day 7 — EC2 최초 부팅 시 자동 실행되는 스크립트 (User Data 자리에 붙여넣기) — Ubuntu Server 24.04 LTS 기준
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive   # apt가 설치 중에 질문하지 않게 한다

AWS_REGION="ap-northeast-2"
REPO="product-copy-service"
TAG="0.1"

# 1) Docker 설치 — 첫 부팅 때 자동 업데이트가 apt를 잡고 있을 수 있어 최대 5분 기다린다
apt-get -o DPkg::Lock::Timeout=300 update -y
apt-get -o DPkg::Lock::Timeout=300 install -y docker.io
systemctl enable --now docker
# SSH로 들어오는 ubuntu 사용자도 sudo 없이 docker를 쓰게 한다
usermod -aG docker ubuntu

# 2) AWS CLI 설치 — Ubuntu AMI에는 기본으로 없다 (Amazon Linux와 다른 점)
snap wait system seed.loaded            # 첫 부팅 때 snap 준비가 끝날 때까지 기다린다
snap install aws-cli --classic
AWS=/snap/bin/aws

# 3) 계정 ID 조회 → ECR 주소 (AWS CLI를 설치한 뒤에 해야 한다)
AWS_ACCOUNT_ID="$("$AWS" sts get-caller-identity --region "$AWS_REGION" --query Account --output text)"
ECR="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# 4) ECR 로그인 (EC2에 ECR 읽기 권한 IAM 역할이 붙어 있어야 함)
"$AWS" ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "$ECR"

# 5) 이미지 내려받아 컨테이너 실행
#    --restart=always: 서버 재부팅·크래시에도 자동 재시작 (Day 10 Auto Healing의 관리형)
docker pull "${ECR}/${REPO}:${TAG}"
docker run -d --name product-copy-service --restart=always \
  -p 80:8000 \
  -e APP_ENV=production \
  "${ECR}/${REPO}:${TAG}"
