aws ec2 create-tags --resources rtb-06337446ecee59db7 --tags Key=CostCenter,Value=ruter-cloud || aws ec2 delete-tags --resources rtb-06337446ecee59db7 --tags Key=costcenter
aws ec2 create-tags --resources rtb-06337446ecee59db7 --tags Key=CostCenter,Value=ruter-cloud && aws ec2 delete-tags --resources rtb-06337446ecee59db7 --tags Key=costcenter
aws ec2 create-tags --resources rtb-0e0e8cf6c517a0b2c --tags Key=CostCenter,Value=ruter-cloud && aws ec2 delete-tags --resources rtb-0e0e8cf6c517a0b2c --tags Key=costcenter
aws ec2 create-tags --resources vpc-03cbbefe920a90eae subnet-0b018125ce74e8eec subnet-078f64feb806b6895 subnet-041880aa40abaebd5 --tags Key=CostCenter,Value=ruter-cloud && aws ec2 delete-tags --resources  vpc-03cbbefe920a90eae subnet-0b018125ce74e8eec subnet-078f64feb806b6895 subnet-041880aa40abaebd5 --tags Key=costcenter
aws ec2 create-tags --resources subnet-08383242ca9c8c7af subnet-0f3c3bef58e145e3d acl-0546c610eae79c094 subnet-0ff9fef0b3e60cafb subnet-06c29ed5d679dc560 acl-0119fd8155fb12689 subnet-031e2f1f8881f5cbe subnet-0522016c96526f0be subnet-085d85bbc8d9feb26 subnet-0a167e36aba059e9c subnet-02580252445b39aaf  --tags Key=CostCenter,Value=ruter-cloud && aws ec2 delete-tags --resources subnet-08383242ca9c8c7af subnet-0f3c3bef58e145e3d acl-0546c610eae79c094 subnet-0ff9fef0b3e60cafb subnet-06c29ed5d679dc560 acl-0119fd8155fb12689 subnet-031e2f1f8881f5cbe subnet-0522016c96526f0be subnet-085d85bbc8d9feb26 subnet-0a167e36aba059e9c subnet-02580252445b39aaf --tags Key=costcenter

#Adding CostCenter Tag on the basis of Tag Team which TorE have created.
###Only ELBs.
cat /Users/divyaanurag/Downloads/resources.csv | cut -d "," -f1 > add_tag_costcenter.lst
aws resourcegroupstaggingapi get-resources  | jq '.ResourceTagMappingList[] | select(contains({Tags: [{Key: "Team"} ]}))' | grep ResourceARN  > TeamTaggedResouces.lst
## Remove "ResouceArn" from the List
aws resourcegroupstaggingapi get-resources --tag-filters Key=Team | jq '.ResourceTagMappingList[] | select(contains({Tags: [{Key: "CostCenter"} ]}) | not)'
aws resourcegroupstaggingapi get-resources --tag-filters Key=Team,Values=cmp | jq '.ResourceTagMappingList[] | select(contains({Tags: [{Key: "CostCenter"} ]}) | not)' | grep ResourceARN | cut -d ":" -f 2-10 | cut -d "," -f1
LIST_ECR_REPOS=$(aws resourcegroupstaggingapi get-resources --tag-filters Key=Team,Values=cmp | jq '.ResourceTagMappingList[] | select(contains({Tags: [{Key: "CostCenter"} ]}) | not)' | grep ResourceARN | cut -d ":" -f 2-10 | cut -d "," -f1 2>&1)
if [[ ! -z "$LIST_ECR_REPOS" ]]; then
  for repo in $LIST_ECR_REPOS; do
    echo "ECR Repo: $repo "
  done
fi


aws resourcegroupstaggingapi get-resources | jq '.ResourceTagMappingList[] | select(contains({Tags: [{Key: "Team"} ]}) | not) | select(contains({Tags: [{Key: "aws:autoscaling:groupName"} ]}) | not) | select(contains({Tags: [{Key: "ManagedBy"} ]}) | not) | select(contains({Tags: [{Key: "Terraform"} ]}) | not) | select(contains({Tags: [{Key: "kubernetes.io/cluster/pd-1"} ]}) | not)| select(contains({Tags: [{Key: "kubernetes.io/cluster/gp-1"} ]}) | not) | select(contains({Tags: [{Key: "monitoringscope"} ]}) | not)| select(contains({Tags: [{Key: "node.k8s.amazonaws.com/instance_id"} ]}) | not) | select(contains({Tags: [{Key: "kubernetes.io/namespace"} ]}) | not)'| grep ResourceARN | cut -d ":" -f 2-10 | cut -d "," -f1 | grep -v snapshot | grep -v appconfig| grep -v session| grep -v transfer| sort -u > resource-not-have-terraform-tag-prod.lst
