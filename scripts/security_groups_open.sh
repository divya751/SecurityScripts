#!/usr/bin/env bash
## Ensure no security groups allow ingress from 0.0.0.0/0 or ::/0 to port 80 "
# "Ensure no security groups allow ingress from 0.0.0.0/0 or ::/0 to port 3389 "
#echo "========================================"
#echo "All Wide Open Outbound SGs: "
#echo "========================================"
#    SG_LIST=$(aws ec2 describe-security-groups --query 'SecurityGroups[?length(IpPermissionsEgress[?((FromPort==null && ToPort==null) || (FromPort<=`80` && ToPort>=`80`)) && (contains(IpRanges[].CidrIp, `0.0.0.0/0`) || contains(Ipv6Ranges[].CidrIpv6, `::/0`))]) > `0`].{GroupId:GroupId}' --output text)
#    if [[ $SG_LIST ]];then
#      for SG in $SG_LIST;do
#        echo "Outbound open $SG for all"
#      done
#    else
#      echo "No Security Groups found with port 80 TCP open to 0.0.0.0/0"
#    fi

echo "========================================"
echo "All Wide Open SSH in Inbound SGs: "
echo "========================================"
        SG_LIST=$(aws ec2 describe-security-groups --query 'SecurityGroups[?length(IpPermissions[?((FromPort==null && ToPort==null) || (FromPort<=`80` && ToPort>=`80`)) && (contains(IpRanges[].CidrIp, `0.0.0.0/0`) || contains(Ipv6Ranges[].CidrIpv6, `::/0`))]) > `0`].{GroupId:GroupId}' --output text)
        if [[ $SG_LIST ]];then
          for SG in $SG_LIST;do
            SG_NAME=$(aws ec2 describe-security-groups --filter Name=group-id,Values=$SG  --query 'SecurityGroups[*].[GroupName]' --output text )
            echo "Inbound open for SSH in $SG named $SG_NAME"
          done
        else
          echo "No Security Groups found with port 80 TCP open to 0.0.0.0/0"
        fi
