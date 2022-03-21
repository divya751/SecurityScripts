#!/bin/bash

#Elastic IPs that are not in a VPC do not have the AssociationId property, but elastic IPs in both VPC and EC2 Classic will output InstanceId.

aws ec2 describe-addresses --query 'Addresses[?InstanceId==null].PublicIp'
