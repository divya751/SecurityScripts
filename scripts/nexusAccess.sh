#!/bin/bash
##USAGE: ./nexusAccess.sh 123.123.123.123 ruter-dev ola-grunnplattform@home
if [ -z "$1" ]; then
    echo "ip address is null invoke script as shown ./nexusAccess.sh {ip} {aws profile}"
    exit 1
fi
if [ -z "$2" ]; then
    echo "you have to send inn aws profile for aws cli"
    exit 1
fi
if [ -z "$3" ]; then
   echo "you have supply description"
   exit 1
fi
if [ $1 = "0.0.0.0" ]; then
    echo "0.0.0.0 is not allowed"
    exit 1
fi

aws ec2 authorize-security-group-ingress --group-id sg-4dc12630 --ip-permissions ToPort=443,IpProtocol=tcp,IpRanges='[{CidrIp=$1/24,Description="$3"}]' --profile $2
