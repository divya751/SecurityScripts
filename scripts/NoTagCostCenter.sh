#All Resources without CostCenter Tag
aws resourcegroupstaggingapi get-resources  | jq '.ResourceTagMappingList[] | select(contains({Tags: [{Key: "CostCenter"} ]}) | not)' | grep ResourceARN
###Specific
echo "EC2 Instance not with CostCenter Tag"
aws ec2 describe-instances \
  --output text \
  --query 'Reservations[].Instances[?!not_null(Tags[?Key == `CostCenter`].Value)] | [].[InstanceId]'
echo "EBS VolumeIDs not with CostCenter Tag"
aws ec2 describe-volumes \
 --output text \
 --query 'Volumes[?!not_null(Tags[?Key == `CostCenter`].Value)] | [].[VolumeId,Size]'
