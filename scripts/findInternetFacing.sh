/* #!/bin/bash
if [ -z "$1" ]; then
    echo "supply namespace to invoke script as shown ./findInternetFacing.sh {namespace}"
    exit 1
fi
​
result=($(kubectl get ingress -n "$1" -o json | jq '.items[].metadata.annotations."meta.helm.sh/release-name",.items[].metadata.annotations."merge.ingress.kubernetes.io/config" | select( . != null )'))
halfOfArray=$((${#result[@]} / 2))
serviceName=("${result[@]:0:$halfOfArray}")
ingress=("${result[@]:$halfOfArray}")
echo "${#serviceName[@]}"
echo "${#ingress[@]}"
for i in "${!serviceName[@]}";do
  if [[ ${ingress[$i]} == *"internet-facing"* ]];then
    echo "${serviceName[$i]}   ${ingress[$i]}"
  fi
done
*/
#!/bin/bash
if [ -z "$1" ]; then
    echo "supply namespace to invoke script as shown ./findInternetFacing.sh {namespace}"
    exit 1
fi

result=$(kubectl get ingress -n "$1" -o json | jq '.items[] | select( (.metadata.annotations."merge.ingress.kubernetes.io/config" != null) and (.metadata.annotations."merge.ingress.kubernetes.io/config" | contains("internet-facing"))) | .metadata.name')

echo "$result"
