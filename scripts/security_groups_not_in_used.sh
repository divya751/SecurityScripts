#!/usr/bin/env bash
# Ensure there are no Security Groups not being used (Not Scored) (Not part of CIS benchmark)"

#  echo "Looking for Security Groups in all regions...  "

    SECURITYGROUPS=$(aws ec2 describe-security-groups --output json | jq '.SecurityGroups|map({(.GroupId): (.GroupName)})|add')
    if [[ $SECURITYGROUPS == "null" ]];
    then
      continue
    fi
    LIST_OF_SECURITYGROUPS=$(echo $SECURITYGROUPS|jq -r 'to_entries|sort_by(.key)|.[]|.key')
    for SG_ID in $LIST_OF_SECURITYGROUPS; do
      #echo $SG_ID
      SG_NOT_USED=$(aws ec2 describe-network-interfaces --filters "Name=group-id,Values=$SG_ID" --query "length(NetworkInterfaces)" --output text)
      # Default security groups can not be deleted, so draw attention to them
      if [[ $SG_NOT_USED -eq 0 ]];then
        GROUP_NAME=$(echo $SECURITYGROUPS | jq -r --arg id $SG_ID '.[$id]')
        if [[ $GROUP_NAME != "default" ]];
        then
          echo "$SG_ID"
        else
          echo "$SG_ID default security group"
        fi
  #    else
  #      echo "$SG_ID is being used"
      fi
    done
