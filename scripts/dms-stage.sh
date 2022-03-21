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
echo -n "Account Number : "
#read accountid
echo -n "replication-instance-class (e.g. dms.r5.large) : "
#read replicationinstanceclass
echo -n "vpc-security-group-ids (e.g. sg-xxxxx) : "
#read vpcsecuritygroupids
echo -n "replication-subnet-group-identifier (e.g. default) : "
#read replicationsubnetgroupidentifier
echo -n "Source Server Name : "
#read Sourcearn
echo -n "Target Server Name : "
#read Targetarn
echo -n "username : "
#read username
echo -n "password : "
#read password
echo -n "certificate-arn : "
#read certificatearn

declare -a StringArray=("agreement" "authentication" "device" "journey" "mobilityrental" "order" "paymentmethod" "pickupdelivery" "profile" "qrjobscheduler" "receipt" "ticketruter")
#aws dms create-replication-instance --replication-instance-identifier dms-instance --replication-instance-class "dms.r5.2xlarge" --allocated-storage 50 --no-publicly-accessible --vpc-security-group-ids "sg-0ba964759f4c2e99a" --replication-subnet-group-identifier default-vpc-2c77664b --engine-version 3.4.6 --tags Key=CostCenter,Value=RAPP --output text
rep_instance_arn=$(aws dms describe-replication-instances --filter=Name=replication-instance-id,Values=dms-instance --query 'ReplicationInstances[0].ReplicationInstanceArn' --output text)
for val in ${StringArray[@]}; do
  jq -n --arg dbid "$val" '{rules: [ {"rule-type": "selection", "rule-id": 809593799, "rule-name": 809593799, "object-locator": {"schema-name": $dbid, "table-name": "%" }, "rule-action": "include", "filters": []}]}' > table-mappings.json
  jq -n '{FullLoadSettings: {TargetTablePrepMode: "DO_NOTHING", "StopTaskCachedChangesNotApplied": false}, "Logging": {"EnableLogging": true} }' > task-settings.json
  echo $val


  aws dms create-endpoint --endpoint-identifier source-test-api-${val} --endpoint-type source --engine-name docdb --username "rutadmin"  --database-name $val --password "94c0b99d3a614119a10d331dbca173bb" --server-name "rapp-api.cluster-cfjqx1trxymx.eu-west-1.docdb.amazonaws.com" --port 27017 --ssl-mode verify-full --certificate-arn "arn:aws:dms:eu-west-1:739805770819:cert:VE3KG2XVZZAVPB4MS4YHHM3HITL54HPKY7MPEOA"  --output text
  aws dms create-endpoint --endpoint-identifier target-test-api-${val} --endpoint-type target --engine-name docdb --username "rutadmin"  --database-name $val --password "94c0b99d3a614119a10d331dbca173bb" --server-name "rapp-api-pd.cluster-cfjqx1trxymx.eu-west-1.docdb.amazonaws.com" --port 27017 --ssl-mode verify-full --certificate-arn "arn:aws:dms:eu-west-1:739805770819:cert:VE3KG2XVZZAVPB4MS4YHHM3HITL54HPKY7MPEOA"  --output text
##Endpoint ARN
SourceName_arn=$(aws dms describe-endpoints --filter="Name=endpoint-id,Values=source-test-api-${val}" --query="Endpoints[0].EndpointArn"  --output text)
TargetName_arn=$(aws dms describe-endpoints --filter="Name=endpoint-id,Values=target-test-api-${val}" --query="Endpoints[0].EndpointArn"  --output text)
##Creating DMS TASKs
aws dms create-replication-task \
--replication-task-identifier "test-api-${val}" \
--source-endpoint-arn $SourceName_arn \
--target-endpoint-arn $TargetName_arn \
--replication-instance-arn $rep_instance_arn \
--migration-type full-load-and-cdc \
--table-mappings file://table-mappings.json \
--replication-task-settings file://task-settings.json \
--output text

done
