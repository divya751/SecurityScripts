#!/usr/bin/env bash
# Ensure there are no LOADBALANCERS not being used."

  echo "Looking for Load Balancer in all regions...  "

    LOADBALANCERS=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[*].LoadBalancerName' --output text)
    if [[ $LOADBALANCERS == "null" ]];
    then
      continue
    fi
    echo $LOADBALANCERS

    for LB_ID in $LOADBALANCERS; do
      #echo $LB_ID
      LB_TG=$(aws elb describe-instance-health --load-balancer-name $LB_ID --query 'InstanceStates[*].State' --output text)
      echo "The state of $LB_ID is $LB_TG"
    done
