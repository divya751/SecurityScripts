
#Check All SourceTargetEndpoints : aws dms describe-endpoints --filter="Name=endpoint-type,Values=target" --query="Endpoints[*].EndpointIdentifier" --output text

source_endpoint_arn=$(aws dms describe-endpoints --filter="Name=endpoint-type,Values=source" --query="Endpoints[*].EndpointArn" --output text)

#Check All TargetEndpoints : aws dms describe-endpoints --filter="Name=endpoint-type,Values=source" --query="Endpoints[*].EndpointIdentifier" --output text

target_endpoint_arn=$(aws dms describe-endpoints --filter="Name=endpoint-type,Values=target" --query="Endpoints[*].EndpointArn" --output text)

#Test source and target endpoints from the replication instance.
rep_instance_arn=$(aws dms describe-replication-instances  --query 'ReplicationInstances[0].ReplicationInstanceArn' --output text)

for SourceName in `aws dms describe-endpoints --filter="Name=endpoint-type,Values=source" --query="Endpoints[*].EndpointIdentifier" --output text`
do

  DBName=$(echo ${SourceName}| cut -d'-' -f 4)
  TargetName="target-$(echo ${SourceName}| cut -d'-' -f 2-4)"
  #echo "$TargetName"
  #echo "$DBName"
if [ ! -n "$DBName" ]
then
	echo "It is $TargetName"
else
  #SourceName_arn=$(aws dms describe-endpoints --filter="Name=endpoint-type,Values=source" --query="Endpoints[*].EndpointArn" --output text)
  SourceName_arn=$(aws dms describe-endpoints --filter="Name=endpoint-id,Values=$SourceName" --query="Endpoints[0].EndpointArn" --output text)
  TargetName_arn=$(aws dms describe-endpoints --filter="Name=endpoint-id,Values=$TargetName" --query="Endpoints[0].EndpointArn" --output text)
	#echo "TargetName_arn $TargetName_arn and SourceName_arn $SourceName_arn and REP $rep_instance_arn "
  aws dms test-connection --replication-instance-arn $rep_instance_arn --endpoint-arn $SourceName_arn
  aws dms test-connection --replication-instance-arn $rep_instance_arn --endpoint-arn $TargetName_arn
  #aws dms describe-connections --filter "Name=endpoint-arn,Values=$SourceName_arn,$TargetName_arn"
  ##Creating DMS TASKs
  aws dms create-replication-task \
  --replication-task-identifier $(echo ${SourceName}| cut -d'-' -f 2-4) \
  --source-endpoint-arn $SourceName_arn \
  --target-endpoint-arn $TargetName_arn \
  --replication-instance-arn $rep_instance_arn \
  --migration-type full-load-and-cdc \
  --table-mappings file://table-mappings.json \
  --replication-task-settings file://task-settings.json
fi

done

aws dms create-replication-task \
--replication-task-identifier "test-api-agreement" \
--source-endpoint-arn arn:aws:dms:eu-west-1:822152007605:endpoint:2PTKZ5C4O5HE7GM4KCDZS77GIJSKS7GOJITY4BY \
--target-endpoint-arn arn:aws:dms:eu-west-1:822152007605:endpoint:L6S2G7ZCQ6YV3RNKAVDTHH7V3VPXT4W556LFNTY \
--replication-instance-arn arn:aws:dms:eu-west-1:822152007605:rep:WCLPHS6JW4GT7OQP7DN3WLNLQDAR567T45UDWNQ \
--migration-type full-load-and-cdc \
--table-mappings file://table-mappings.json \
--replication-task-settings file://task-settings.json



###STEP 1
####Script need to create Replication Instance :
declare -a StringArray=("agreement" "authentication" "device" "journey" "mobilityrental" "order" "paymentmethod" "pickupdelivery" "profile" "qrjobscheduler" "receipt" "ticketruter")
aws dms create-replication-instance --replication-instance-identifier test-dms-instance --replication-instance-class dms.r5.large --allocated-storage 50 --output text
rep_instance_arn=$(aws dms describe-replication-instances --filter=Name=replication-instance-id,Values=test-dms-instance --query 'ReplicationInstances[0].ReplicationInstanceArn' --output text)
for val in ${StringArray[@]}; do
  jq -n --arg dbid "$val" '{rules: [ {name: "selection", "rule-id": 809593799, "rule-name": 809593799, "object-locator": {"schema-name": $dbid, "table-name": "%" }, "rule-action": "include", "filters": []}]}' > table-mappings.json
  jq -n '{FullLoadSettings: {TargetTablePrepMode: "DROP_AND_CREATE", "StopTaskCachedChangesNotApplied": false}, "Logging": {"EnableLogging": true} }' > task-settings.json
  echo $val
  aws dms create-endpoint --endpoint-identifier source-test-api-${val} --endpoint-type source --engine-name docdb --username "rutadmin"  --database-name $val --password "4efb5d52aa4caca649c3724f5041d468" --server-name "rapp-api.cluster-c0riy1xojgsv.eu-west-1.docdb.amazonaws.com" --port 27017
  aws dms create-endpoint --endpoint-identifier target-test-api-${val} --endpoint-type target --engine-name docdb --username "rutadmin"  --database-name $val --password "4efb5d52aa4caca649c3724f5041d468" --server-name "rapp-api-pd.cluster-c0riy1xojgsv.eu-west-1.docdb.amazonaws.com" --port 27017
##Endpoint ARN
SourceName_arn=$(aws dms describe-endpoints --filter="Name=endpoint-id,Values=source-dev-api-${val}" --query="Endpoints[0].EndpointArn" --output text)
TargetName_arn=$(aws dms describe-endpoints --filter="Name=endpoint-id,Values=target-dev-api-${val}" --query="Endpoints[0].EndpointArn" --output text)
##Creating DMS TASKs
aws dms create-replication-task \
--replication-task-identifier $(echo ${SourceName}| cut -d'-' -f 2-4) \
--source-endpoint-arn $SourceName_arn \
--target-endpoint-arn $TargetName_arn \
--replication-instance-arn $rep_instance_arn \
--migration-type full-load-and-cdc \
--table-mappings file://table-mappings.json \
--replication-task-settings file://task-settings.json

done


#Creating DMS TASKs
