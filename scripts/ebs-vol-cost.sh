declare -a StringArray=("cmp-test" "cmp" "dpi-dev" "rdp-common-utils" "rdp-monitoring" "rdp-monitoring-dev" "kapp" "km" "ks" "ks-dev" "mqtt" "ops" "plandata" "ps" "rapp" "ruterbillett" "sanntid" "sanntid-dev" "sanntid-temp" "sb-dev" "sb-test" "tid" "rutersalg" "tb")
for val in ${StringArray[@]}; do
  #echo $val
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
