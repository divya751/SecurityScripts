#!/usr/bin/env bash

## Ensure routing tables for VPC peering are \"least access\"
CHECK_ASFF_RESOURCE_TYPE_check44="AwsEc2Vpc"
CHECK_ALTERNATE_check404="check44"

  # "Ensure routing tables for VPC peering are \"least access\" (Not Scored)"
  # echo "Looking for VPC peering in all regions...  "

    LIST_OF_VPCS_PEERING_CONNECTIONS=$(aws ec2 describe-vpc-peering-connections --vpc-peering-connection-ids pcx-da4d05b3 --output text  --query 'VpcPeeringConnections[*].VpcId'| sort | paste -s -d" " -)
    #if [[ $LIST_OF_VPCS_PEERING_CONNECTIONS ]];then
    #  echo "$LIST_OF_VPCS_PEERING_CONNECTIONS - review routing tables"
      #LIST_OF_VPCS=$(aws ec2 describe-vpcs  --query 'Vpcs[*].VpcId' --output text)
      LIST_OF_VPCS="vpc-cc04ccab vpc-5e766739"
      #aws ec2 describe-route-tables --filter "Name=vpc-id,Values=vpc-0213e864" --query "RouteTables[*].{RouteTableId:RouteTableId, VpcId:VpcId, Routes:Routes, AssociatedSubnets:Associations[*].SubnetId}"
       for vpc in $LIST_OF_VPCS; do
      #   echo $vpc
         #VPCS_WITH_PEERING=$(aws ec2 describe-route-tables --filter "Name=vpc-id,Values=$vpc"  --query "RouteTables[*].{RouteTableId:RouteTableId, VpcId:VpcId, Routes:Routes, AssociatedSubnets:Associations[*].SubnetId}"|grep DestinationCidrBlock|cut -f2 -d ":"| cut -f1 -d ",")
         VPCS_WITH_PEERING=$(aws ec2 describe-route-tables --filter "Name=vpc-id,Values=$vpc" --output json --query "RouteTables[*].{RouteTableId:RouteTableId, VpcId:VpcId, Routes:Routes[*].DestinationCidrBlock}")
         #VPCS_WITH_PEERING=$(aws ec2 describe-route-tables --filter "Name=vpc-id,Values=$vpc"  --query "RouteTables[*].[join(':',[RouteTableId, VpcId, Routes[*].DestinationCidrBlock])]")
         echo $VPCS_WITH_PEERING
       done
#      echo $VPCS_WITH_PEERING
  #  else
  #     echo " No VPC peering found"
  #  fi
