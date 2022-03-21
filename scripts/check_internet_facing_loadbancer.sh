#!/usr/bin/env bash

#CHECK_ID_extra79="7.9"
# Check for internet facing Elastic Load Balancers.



    LIST_OF_PUBLIC_ELBS=$(aws elb describe-load-balancers --query 'LoadBalancerDescriptions[?Scheme == `internet-facing`].[LoadBalancerName,DNSName]' --output text)
    LIST_OF_PUBLIC_ELBSV2=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[?Scheme == `internet-facing`].[LoadBalancerName,DNSName]' --output text)
    LIST_OF_ALL_ELBS=$( echo $LIST_OF_PUBLIC_ELBS; echo $LIST_OF_PUBLIC_ELBSV2)
    LIST_OF_ALL_ELBS_PER_LINE=$( echo $LIST_OF_ALL_ELBS| xargs -n2 )
     if [[ $LIST_OF_ALL_ELBS ]];then
      while read -r elb;do
        #echo $elb
        ELB_NAME=$(echo $elb | awk '{ print $1; }')
        ELB_DNSNAME=$(echo $elb | awk '{ print $2; }')
        echo " ELB: $ELB_NAME at DNS: $ELB_DNSNAME is internet-facing!"
      done <<< "$LIST_OF_ALL_ELBS_PER_LINE"
      else
        echo " no Internet Facing ELBs found"
    fi
