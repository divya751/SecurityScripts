aws route53 list-hosted-zones|jq '.[] | .[] | .Id' | sed 's!/hostedzone/!!' | sed 's/"//g'> zones
for z in `cat zones`;
do
echo $z;
aws route53 list-resource-record-sets --hosted-zone-id $z --query 'ResourceRecordSets[].{DNS:Name,TargetHostZoneID:AliasTarget.HostedZoneId}' --output table;
done
