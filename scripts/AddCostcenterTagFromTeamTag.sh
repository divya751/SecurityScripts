#!/usr/bin/env bash
# By Divya Anurag - dpi Team
#cmp, dpi,
declare -a StringArray=("CMP" "cmp" "dpi" "kapp" "km" "ks" "ops" "plandata" "ps" "rapp" "ruterbillett" "rutersalg" "sanntid" "sb" "tb" "tid" "rdp" "web-teamet")
for val in ${StringArray[@]}; do
  #echo $val
  TEAM_TAGGED_RESOURCES=$(aws resourcegroupstaggingapi get-resources --tag-filters Key=Team,Values=$val | jq '.ResourceTagMappingList[] | select(contains({Tags: [{Key: "CostCenter"} ]}) | not)' | grep ResourceARN | cut -d ":" -f 2-10 | cut -d "," -f1 2>&1)
  if [[ ! -z "$TEAM_TAGGED_RESOURCES" ]]; then
    for team_resource in $TEAM_TAGGED_RESOURCES; do
      team_resource="${team_resource%\"}"
      team_resource="${team_resource#\"}"
      echo " $team_resource "
      aws elbv2 add-tags --resource-arns $team_resource --tags "Key=CostCenter,Value=$val"
    done
  fi
done

declare -a StringArray=("cmp-test" "cmp" "dpi-dev" "rdp-common-utils" "rdp-monitoring" "rdp-monitoring-dev" "kapp" "km" "ks" "sb" "ks-dev" "mqtt" "ops" "plandata" "ps" "rapp" "ruterbillett" "sanntid" "sanntid-dev" "sanntid-temp" "sb-dev" "sb-test" "tid" "rdp" "web-teamet" "tb" "rutersalg")
for val in ${StringArray[@]}; do
  echo $val
  TEAM_TAGGED_RESOURCES=$(aws resourcegroupstaggingapi get-resources --tag-filters Key="kubernetes.io/created-for/pvc/namespace",Values=$val  | jq '.ResourceTagMappingList[] | select(contains({Tags: [{Key: "CostCenter"} ]}) | not)' | grep ResourceARN | cut -d ":" -f 2-10 | cut -d "," -f1 2>&1)
  if [[ ! -z "$TEAM_TAGGED_RESOURCES" ]]; then
    for team_resource in $TEAM_TAGGED_RESOURCES; do
      team_resource="${team_resource%\"}"
      team_resource="${team_resource#\"}"
      echo " $team_resource "
      #aws elbv2 add-tags --resource-arns $team_resource --tags "Key=CostCenter,Value=$val"
      aws resourcegroupstaggingapi tag-resources --resource-arn-list $team_resource --tags "CostCenter=$val"
    done
  fi
done

declare -a StringArray=("cmp-test" "cmp" "dpi-dev" "rdp-common-utils" "rdp-monitoring" "rdp-monitoring-dev" "kapp" "km" "ks" "sb" "ks-dev" "mqtt" "ops" "plandata" "ps" "rapp" "ruterbillett" "sanntid" "sanntid-dev" "sanntid-temp" "sb-dev" "sb-test" "tid" "rdp" "tb" "rutersalg" "web-teamet")
for val in ${StringArray[@]}; do
  echo $val
  TEAM_TAGGED_RESOURCES=$(aws resourcegroupstaggingapi get-resources --tag-filters Key=Team,Values=$val  | jq '.ResourceTagMappingList[] | select(contains({Tags: [{Key: "CostCenter"} ]}) | not)' | grep ResourceARN | cut -d ":" -f 2-10 | cut -d "," -f1 2>&1)
  if [[ ! -z "$TEAM_TAGGED_RESOURCES" ]]; then
    for team_resource in $TEAM_TAGGED_RESOURCES; do
      team_resource="${team_resource%\"}"
      team_resource="${team_resource#\"}"
      echo " $team_resource "
      #aws elbv2 add-tags --resource-arns $team_resource --tags "Key=CostCenter,Value=$val"
      aws resourcegroupstaggingapi tag-resources --resource-arn-list $team_resource --tags "CostCenter=$val"
    done
  fi
done

TEAM_TAGGED_RESOURCES=$(aws resourcegroupstaggingapi get-resources  | jq '.ResourceTagMappingList[] | select(contains({Tags: [{Key: "CostCenter"} ]}) | not)' | grep ResourceARN | grep rds |grep emqx| cut -d ":" -f 2-10 | cut -d "," -f1 2>&1)
if [[ ! -z "$TEAM_TAGGED_RESOURCES" ]]; then
  for team_resource in $TEAM_TAGGED_RESOURCES; do
    team_resource="${team_resource%\"}"
    team_resource="${team_resource#\"}"
    echo " $team_resource "
    aws rds add-tags-to-resource --resource-name $team_resource --tags "[{\"Key\": \"CostCenter\",\"Value\": \"sanntid\"}]"
  done
fi

TEAM_TAGGED_RESOURCES=$(aws resourcegroupstaggingapi get-resources  | jq '.ResourceTagMappingList[] | select(contains({Tags: [{Key: "CostCenter"} ]}) | not)' | grep ResourceARN | grep rds |grep km| cut -d ":" -f 2-10 | cut -d "," -f1 2>&1)
if [[ ! -z "$TEAM_TAGGED_RESOURCES" ]]; then
  for team_resource in $TEAM_TAGGED_RESOURCES; do
    team_resource="${team_resource%\"}"
    team_resource="${team_resource#\"}"
    echo " $team_resource "
    aws rds add-tags-to-resource --resource-name $team_resource --tags "[{\"Key\": \"CostCenter\",\"Value\": \"km\"}]"

  done
fi

TEAM_TAGGED_RESOURCES=$(aws resourcegroupstaggingapi get-resources  | jq '.ResourceTagMappingList[] | select(contains({Tags: [{Key: "CostCenter"} ]}) | not)' | grep ResourceARN | grep rds |grep ps-test| cut -d ":" -f 2-10 | cut -d "," -f1 2>&1)
if [[ ! -z "$TEAM_TAGGED_RESOURCES" ]]; then
  for team_resource in $TEAM_TAGGED_RESOURCES; do
    team_resource="${team_resource%\"}"
    team_resource="${team_resource#\"}"
    echo " $team_resource "
    aws rds add-tags-to-resource --resource-name $team_resource --tags "[{\"Key\": \"CostCenter\",\"Value\": \"ps\"}]"

  done
fi
