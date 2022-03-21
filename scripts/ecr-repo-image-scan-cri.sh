#!/usr/bin/env bash
# By Divya Anurag - CMP Team
# Usage: ./ecr-repo-image-scan.sh
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
            IMAGE_SCAN_STATUS=$(aws ecr describe-image-scan-findings --repository-name "$repo" --image-id imageDigest="$IMAGE_DIGEST" --query "imageScanStatus.status" 2>&1)
              #echo "$repo:  $IMAGE_SCAN_STATUS"
            if [[ $IMAGE_SCAN_STATUS != *"ScanNotFoundException"* ]]; then
#              echo "ECR Repo: $repo ImageTags $IMAGE_TAG without a scan"
#            else
              if [[ $IMAGE_SCAN_STATUS != *"FAILED"* ]]; then
#                echo "ECR Repo: $repo ImageTags $IMAGE_TAG with scan status $IMAGE_SCAN_STATUS"
#              else
                FINDINGS_COUNT=$(aws ecr describe-image-scan-findings --repository-name "$repo" --image-id imageDigest="$IMAGE_DIGEST" --query "imageScanFindings.findingSeverityCounts" 2>&1)
                if [[ ! -z "$FINDINGS_COUNT" ]]; then
                    SEVERITY_CRITICAL=$(echo "$FINDINGS_COUNT" | jq -r '.CRITICAL' )
                    FINDING_CVE=$(aws ecr describe-image-scan-findings --repository-name "$repo" --image-id imageDigest="$IMAGE_DIGEST" --query 'imageScanFindings.findings[?severity == `CRITICAL`].[name]' --output text)
                    FINDING_CVE_CRI=$(echo $FINDING_CVE|tr -d '\n')
                    if [[ "$SEVERITY_CRITICAL" != "null" ]]; then
                      echo "ECR Repo: $repo ImageTags $IMAGE_TAG with CRITICAL ($SEVERITY_CRITICAL) findings are: $FINDING_CVE_CRI"
                      #echo "OR "$FINDING_CVE
                    fi
                    SEVERITY_HIGH=$(echo "$FINDINGS_COUNT" | jq -r '.HIGH' )
                    FINDING_CVE_H=$(aws ecr describe-image-scan-findings --repository-name "$repo" --image-id imageDigest="$IMAGE_DIGEST" --query 'imageScanFindings.findings[?severity == `HIGH`].[name]' --output text)
                    FINDING_CVE_HIGH=$(echo $FINDING_CVE_H|tr -d '\n')
                    if [[ "$SEVERITY_HIGH" != "null" ]]; then
                      echo "ECR Repo: $repo ImageTags $IMAGE_TAG with HIGH ($SEVERITY_HIGH) findings are: $FINDING_CVE_HIGH"
                    fi
              #  else
              #    echo "ECR Repo: $repo ImageTags $IMAGE_TAG without findings"
                fi
              fi
            fi
#          else
#            echo "No images for ECR Repo: $repo"
          fi
        else
          #echo "ScanOnPush is not enabled for ECR Repo: $repo"
          IMAGE_SCANONPUSH_STATUS=$(aws ecr put-image-scanning-configuration --repository-name "$repo" --image-scanning-configuration scanOnPush=true 2>&1)
          echo "ScanOnPush is enabled $IMAGE_SCANONPUSH_STATUS now !"
        fi
      done
    else
      echo "No ECR repositories found"
    fi
