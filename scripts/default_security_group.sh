#!/usr/bin/env bash

  # "Ensure the default security group of every VPC restricts all traffic (Scored)"

    SGDEFAULT_IDS=$(aws ec2 describe-security-groups --filters Name=group-name,Values='default' --query 'SecurityGroups[*].GroupId[]' --output text)
    for SGDEFAULT_ID in $SGDEFAULT_IDS; do
      SGDEFAULT_ID_OPEN=$(aws ec2 describe-security-groups --group-ids $SGDEFAULT_ID --query 'SecurityGroups[*].{IpPermissions:IpPermissions,IpPermissionsEgress:IpPermissionsEgress,GroupId:GroupId}' --output text |egrep '0.0.0.0|\:\:\/0')
      if [[ $SGDEFAULT_ID_OPEN ]];then
        echo "Default Security Groups ($SGDEFAULT_ID) found that allow 0.0.0.0 IN or OUT traffic "
        aws ec2 describe-network-interfaces --filters Name=group-id,Values=$SGDEFAULT_ID --query 'NetworkInterfaces[*].{VpcId:VpcId}' --output text | sort -u
  #    else
  #      echo "Default Security Groups ($SGDEFAULT_ID) is NOT open to 0.0.0.0 "
      fi
    done
