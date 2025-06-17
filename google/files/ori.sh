#!/bin/bash

IMAGE_NAME="$1"

# gcloud projects list에서 프로젝트 ID 가져오기
projects=$(gcloud projects list --format="value(project_id)")

# 각 프로젝트에 대해 작업 수행 함수 정의
apply_iam_policy() {
  project="$1"
  service_account_email="terraform@${project}.iam.gserviceaccount.com"
  
  # 서비스 계정 존재 확인
  if gcloud iam service-accounts list --project="${project}" --filter="email:${service_account_email}" --format="value(email)" | grep -q "${service_account_email}"; then
    echo "Service account ${service_account_email} exists in project ${project}. Applying IAM policy..."
    # IAM 정책 추가
    gcloud compute images add-iam-policy-binding "${IMAGE_NAME}" \
      --project=gcp-ie3 \
      --member="serviceAccount:${service_account_email}" \
      --role="roles/compute.imageUser" || true
  else
    echo "Service account ${service_account_email} does not exist in project ${project}. Skipping..."
  fi
}

export -f apply_iam_policy

# xargs로 병렬 처리 설정 (-P 4: 병렬 작업 수 설정)
echo "${projects}" | xargs -n 1 -P 4 -I {} bash -c 'apply_iam_policy "$@"' _ {}
