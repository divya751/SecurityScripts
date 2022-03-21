#!/bin/bash

for ns in $(kubectl get ns --no-headers -o=custom-columns=NAME:.metadata.name); do
  #printf "\Namespace: $ns \t"
  result=$(kubectl get ingress -n "$ns" -o json | jq '.items[] | select( (.metadata.annotations."merge.ingress.kubernetes.io/config" != null) and (.metadata.annotations."merge.ingress.kubernetes.io/config" | contains("internet-facing"))) | .metadata.name')
       echo "$ns : { $result }" | grep -v ": {  }"
done
