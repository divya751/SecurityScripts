##ruter-cloud tag which has Name tag too.

aws resourcegroupstaggingapi get-resources --tag-filters Key=CostCenter,Values=ruter-cloud | jq '.ResourceTagMappingList[] | select(contains({Tags: [{Key: "Name"} ]}))' | grep ResourceARN | cut -d ":" -f 2-10 | cut -d "," -f1 2>&1
aws resourcegroupstaggingapi get-resources --tag-filters Key=CostCenter,Values=ruter-cloud | jq '.ResourceTagMappingList[] | select(contains({Tags: [{Key: "ProjectID"} ]})| not)' | grep ResourceARN | cut -d ":" -f 2-10 | cut -d "," -f1 2>&1 > ../ModifyRuterCloudTagsNoProject.lst
aws resourcegroupstaggingapi get-resources --tag-filters Key=CostCenter,Values=ruter-cloud | jq '.ResourceTagMappingList[] | select(contains({Tags: [{Key: "ProjectID"} ]}))' | grep ResourceARN | cut -d ":" -f 2-10 | cut -d "," -f1 2>&1 > ../ModifyRuterCloudTagsWithProject.lst

cat ../ModifyRuterCloudTagsWithName.lst | cut -d ":" -f6-7
cat ../ModifyRuterCloudTagsWithProject.lst | cut -d ":" -f6 | cut -d "/" -f1 |sort -u
cat ../ModifyRuterCloudTagsNoProject.lst | cut -d ":" -f6 | cut -d "/" -f1 |sort -u

for r_name in `aws resourcegroupstaggingapi get-resources --tag-filters Key=CostCenter,Values=ruter-cloud | jq '.ResourceTagMappingList[]' | grep ResourceARN | cut -d ":" -f 2-10 | cut -d "," -f1 2>&1`
do
  r_type= echo "${r_name}"| cut -d ":" -f6
#  r_type="${r_type%\"}"
#  r_type="${r_type#\"}"
  echo $r_type


#  if [[ "${r_name}" =~ ^(eu-west-1)$ ]]; then
#    echo "Default"
#  else

#    aws resourcegroupstaggingapi get-resources --r_name ${r_name} --query 'ResourceTagMappingList[].ResourceARN' --output json;
#  fi

done


aws ec2 describe-tags --filters "Name=resource-id,Values=i-0d946a7dcfc29c2eb" "Name=key,Values=ProjectID" --output=text | cut -f5


##ruter-cloud tag which has NO Name tag.

aws resourcegroupstaggingapi get-resources --tag-filters Key=CostCenter,Values=ruter-cloud | jq '.ResourceTagMappingList[] | select(contains({Tags: [{Key: "Name"} ]})| not)' | grep ResourceARN | cut -d ":" -f 2-10 | cut -d "," -f1 2>&1 > ../ModifyRuterCloudTagsNoName.lst
