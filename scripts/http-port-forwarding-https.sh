#!/usr/bin/env bash

# Check if Elastic Load Balancers have HTTP Port Forwarding to HTTPS listeners

    LIST_OF_ELBS=$(aws elb describe-load-balancers --query 'LoadBalancerDescriptions[*].LoadBalancerName' --output text|xargs -n1)
    LIST_OF_ELBSV2=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[?(Type == `application`)].LoadBalancerArn' --output text|xargs -n1)
    if [[ $LIST_OF_ELBS || $LIST_OF_ELBSV2 ]]; then
      if [[ $LIST_OF_ELBS ]]; then
        ENCRYPTEDPROTOCOLS=("HTTPS" "SSL")
        for elb in $LIST_OF_ELBS; do
#          echo "ELB: "$elb
          ELB_PROTOCOLS=$(aws elb describe-load-balancers --load-balancer-name $elb --query "LoadBalancerDescriptions[0].ListenerDescriptions[*].Listener.Protocol" --output text)
          passed=true
          potential_redirect=false
          for protocol in $ELB_PROTOCOLS; do
            #echo "PROTOCOLS "$ELB_PROTOCOLS "FOR ELB "$elb
            if [[ "$protocol" =~ ^(HTTPS|SSL)$ ]]; then
##              echo "ELB: "$elb
##              echo Protocol : $protocol
              continue
            else
              # Check if both HTTP and HTTPS in use
              if [[ $(echo $ELB_PROTOCOLS | grep HTTPS) ]]; then
                 potential_redirect=true
              fi
              passed=false
            fi
          done

#          if $passed; then
#            echo " $elb has encrypted listeners"
#          else
#            if $potential_redirect; then
#              echo " $elb has both encrypted and non-encrypted listeners"
#            else
#              echo " $elb has non-encrypted listeners"
#            fi
#          fi
        done
      fi
      if [[ $LIST_OF_ELBSV2 ]]; then
        for elbarn in $LIST_OF_ELBSV2; do
          https_only=true
          redirect_rule=false
          elbname=$(echo $elbarn | awk -F 'loadbalancer/app/' '{print $2}' | awk -F '/' '{print $1}')

          ELBV2_LISTENERS=$(aws elbv2 describe-listeners --load-balancer-arn $elbarn --query "Listeners[*]")
          ELBV2_PROTOCOLS=$(echo $ELBV2_LISTENERS | jq -r '.[].Protocol')

          if [[ $(echo $ELBV2_PROTOCOLS | grep HTTPS) ]]; then
             for line in $(echo $ELBV2_LISTENERS | jq -r '.[] | .Protocol + "," + .ListenerArn'); do
                protocol=$(echo $line | awk -F ',' '{print $1}')
                listenerArn=$(echo $line | awk -F ',' '{print $2}')
                if [[ $protocol  == "HTTP" ]]; then
                  https_only=false
                  # Check for redirect rule
                  ELBV2_RULES=$(aws elbv2 describe-rules --listener-arn $listenerArn --query 'Rules[]')
                  if [[ $(echo $ELBV2_RULES | jq -r '.[].Actions[].RedirectConfig.Protocol' | grep HTTPS) ]]; then
                     redirect_rule=true
                  fi
               fi
             done

             if $https_only; then
               echo " $elbname has HTTPS listeners only"
             else
               if $redirect_rule; then
                 echo " $elbname has HTTP (Port 80) listener that redirects to HTTPS(Port 443) "
      ###         else
      ###           echo " $elbname has non-encrypted listeners"
               fi
             fi
      ###    else
      ###      echo " $elbname has non-encrypted listeners"
          fi
        done
      fi
    else
      echo " No ELBs found"
    fi
