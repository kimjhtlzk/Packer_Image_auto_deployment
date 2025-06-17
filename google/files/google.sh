#!/bin/bash

IMAGE_NAME="$1"

for project in $(gcloud projects list --format="value(project_id)"); do
  # 해당 서비스 계정 이메일 설정
  service_account_email="terraform@${project}.iam.gserviceaccount.com"
  
  # 서비스 계정이 존재하는지 확인
  if gcloud iam service-accounts list --project="${project}" --filter="email:${service_account_email}" --format="value(email)" | grep -q "${service_account_email}"; then
    echo "Service account ${service_account_email} exists. Applying IAM policy..."
    # IAM 정책 추가
    gcloud compute images add-iam-policy-binding "${IMAGE_NAME}" \
      --project=gcp-ie3 \
      --member="serviceAccount:${service_account_email}" \
      --role="roles/compute.imageUser" || true
  else
    echo "Service account ${service_account_email} does not exist in project $project. Skipping..."
  fi
done