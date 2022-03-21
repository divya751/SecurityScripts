#!/usr/bin/env bash
# Ensure there are no LOADBALANCERS not being used."
aws elb describe-load-balancers --output json |jq -r '.LoadBalancerDescriptions[] | select(.Instances==[]) | . as $l | [$l.LoadBalancerName] | @sh'
