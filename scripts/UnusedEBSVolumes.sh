#!/usr/bin/env bash

#To generate a list of volume id’s of all detached EBS volumes.:

for volume in `aws ec2 describe-volumes --filter "Name=status,Values=available" --query "Volumes[*].VolumeId" --output text`
do

#aws ec2 describe-volumes --volume-ids $volume --query "Volumes[*].[Tags[?Key=='Name'].Value | [0]]" --output text
aws ec2 create-snapshot --volume-id $volume | awk {'print $2'} | grep snap* | sed 's/\"//g'|sed 's/\,//g' > /tmp/snapname

EBSSNAPNAME=$(cat /tmp/snapname)
TAGNAME=$(aws ec2 describe-tags --query "Tags[*].{Name:Value,ResourceId:ResourceId}" --filters "Name=key,Values=Name" --filters "Name=resource-type,Values=volume" --filters "Name=resource-id,Values=$volume" --output text| awk '{ print $1 }'| head -n 1)
sleep 5
echo "Snapshot of volume $volume is $EBSSNAPNAME"
aws ec2 create-tags --resources $EBSSNAPNAME --tags Key=Name,Value=$TAGNAME >/dev/null
aws ec2 create-tags --resources $EBSSNAPNAME --tags Key=Volume-Id,Value=$volume >/dev/null
aws ec2 create-tags --resources $EBSSNAPNAME --tags Key=Retention,Value=$volume >/dev/null
echo "aws ec2 delete-volume --volume-id $volume" >> /tmp/delete_snapshot
done
