###UPDATE:
#--replication-instance-class
#--vpc-security-group-ids
#--replication-subnet-group-identifier
#--username
#--password
#--server-name
#--certificate-arn

###STEP 1
####Script need to create Replication Instance :
#!/bin/sh

declare -a StringArray=("agreement" "authentication" "device" "journey" "mobilityrental" "order" "paymentmethod" "pickupdelivery" "profile" "qrjobscheduler" "receipt" "ticketruter")
#aws dms create-replication-instance --replication-instance-identifier dms-instance --replication-instance-class "db.r5.4xlarge" --allocated-storage 50 --no-publicly-accessible --vpc-security-group-ids "sg-0adcbaddf94bc7e9f" --replication-subnet-group-identifier "$replicationsubnetgroupidentifier" --engine-version 3.4.6 --output text
rep_instance_arn=$(aws dms describe-replication-instances --filter=Name=replication-instance-id,Values=dms-instance --query 'ReplicationInstances[0].ReplicationInstanceArn' --output text)
for val in ${StringArray[@]}; do
#  jq -n --arg dbid "$val" '{rules: [ {"rule-type": "selection", "rule-id": 905279427843, "rule-name": 905279427843, "object-locator": {"schema-name": $dbid, "table-name": "%" }, "rule-action": "include", "filters": []}]}' > table-mappings.json
#  jq -n '{FullLoadSettings: {TargetTablePrepMode: "DO_NOTHING", "StopTaskCachedChangesNotApplied": false}, "Logging": {"EnableLogging": true} }' > task-settings.json


  jq -n --arg dbid "$val" '{rules: [ {"rule-type": "selection", "rule-id": 836110206, "rule-name": 836110206, "object-locator": {"schema-name": $dbid, "table-name": "%" }, "rule-action": "include", "filters": []}]}' > table-mappings.json
  jq -n '{FullLoadSettings: {TargetTablePrepMode: "DO_NOTHING", "StopTaskCachedChangesNotApplied": false}, "Logging": {"EnableLogging": true} }' > task-settings.json


  echo $val
#  aws dms create-endpoint --endpoint-identifier source-prod-api-${val} --endpoint-type source --engine-name docdb --username "rutadmin"  --database-name $val --password "4953dfb3ee5d26487e35abe2929cf85e" --server-name "rapp-api.cluster-cij2nx7zphs1.eu-west-1.docdb.amazonaws.com" --port 27017 --ssl-mode verify-full --certificate-arn "arn:aws:dms:eu-west-1:905279427843:cert:G2U7FZVCXO2RNBOZBHD5JT5A4MQO65HORJHYZ3Q" --output text
#  aws dms create-endpoint --endpoint-identifier target-prod-api-${val} --endpoint-type target --engine-name docdb --username "rutadmin"  --database-name $val --password "4953dfb3ee5d26487e35abe2929cf85e" --server-name "rapp-api-pd.cluster-cij2nx7zphs1.eu-west-1.docdb.amazonaws.com" --port 27017 --ssl-mode verify-full --certificate-arn "arn:aws:dms:eu-west-1:905279427843:cert:G2U7FZVCXO2RNBOZBHD5JT5A4MQO65HORJHYZ3Q" --output text
##Endpoint ARN
SourceName_arn=$(aws dms describe-endpoints --filter="Name=endpoint-id,Values=source-prod-api-${val}" --query="Endpoints[0].EndpointArn" --output text)
TargetName_arn=$(aws dms describe-endpoints --filter="Name=endpoint-id,Values=target-prod-api-${val}" --query="Endpoints[0].EndpointArn" --output text)
##Creating DMS TASKs
aws dms create-replication-task \
--replication-task-identifier "prod-api-${val}" \
--source-endpoint-arn $SourceName_arn \
--target-endpoint-arn $TargetName_arn \
--replication-instance-arn $rep_instance_arn \
--migration-type full-load-and-cdc \
--table-mappings file://table-mappings.json \
--replication-task-settings file://task-settings.json \
--output text

done
