#!/usr/bin/env bash
#
for region in `aws ec2 describe-regions --query 'Regions[].RegionName' --region us-west-1 --output text`
do
  if [[ "${region}" =~ ^(eu-west-1)$ ]]; then
    echo "Default"
  else
    echo "region = ${region}"
    aws resourcegroupstaggingapi get-resources --region ${region} --query 'ResourceTagMappingList[].ResourceARN' --output json;
  fi

done
