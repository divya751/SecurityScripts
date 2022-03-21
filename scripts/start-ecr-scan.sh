#!/usr/bin/env bash
# By Divya Anurag - CMP Team
# Usage: ./start-ecr-scan.sh
# Remediation:
#
#   https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning.html
#
#   aws ecr put-image-scanning-configuration \
#     --region <value> \
#     --repository-name <value> \
#     --image-scanning-configuration scanOnPush=true
#
#   aws ecr describe-image-scan-findings \
#     --region <value> \
#     --repository-name <value>
#     --image-id imageTag=<value>

    LIST_ECR_REPOS=$(aws ecr describe-repositories --query "repositories[*].[repositoryName]" --output text 2>&1)
    if [[ $(echo "$LIST_ECR_REPOS" | grep AccessDenied) ]]; then
      echo "Access Denied to describe ECR repositories"
      continue
    fi
    if [[ ! -z "$LIST_ECR_REPOS" ]]; then
      for repo in $LIST_ECR_REPOS; do
        SCAN_ENABLED=$(aws ecr describe-repositories --query "repositories[?repositoryName==\`$repo\`].[imageScanningConfiguration.scanOnPush]" --output text 2>&1)
        if [[ "$SCAN_ENABLED" == "True" ]]; then

          IMAGE_DIGEST=$(aws ecr describe-images --repository-name "$repo" --query "sort_by(imageDetails,& imagePushedAt)[-1].imageDigest" 2>&1)
          IMAGE_TAG=$(aws ecr describe-images --repository-name "$repo" --query "sort_by(imageDetails,& imagePushedAt)[-1].imageTags[0]" 2>&1)
          if [[ "$IMAGE_DIGEST" != null ]]; then
            SCAN_STATUS=$(aws ecr start-image-scan --repository-name "$repo" --image-id imageDigest="$IMAGE_DIGEST" --query "imageScanStatus.status" 2>&1)
            echo "ScanOnPush started status for images $IMAGE_DIGEST for ECR Repo $repo is $SCAN_STATUS ."
          else
            echo "No images for ECR Repo: $repo"
          fi
        else
          echo "ScanOnPush is not enabled for ECR Repo: $repo"
        fi
      done
    else
      echo "No ECR repositories found"
    fi
