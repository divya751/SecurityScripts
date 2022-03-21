for ns in $(kubectl get ns --no-headers -o=custom-columns=NAME:.metadata.name); do
  printf "\##################################Namespace: $ns ##################################\t \n"
  #kubectl get pods -o name -n $ns| xargs -I{} -n 1 -P 10 kubectl exec -n $ns --stdin {} -- /bin/sh -c "find / -name log4j-core*  | xargs -n1 echo \"\$HOSTNAME -\""
  kubectl get pods -o name -n $ns| xargs -I{} -n 1 -P 10 kubectl exec -n $ns --stdin {} -- /bin/sh -c 'echo "$HOSTNAME: log4j: `find / -name log4j-core* 2>/dev/null` jndi: `grep -c JndiLookup.class /app/libs/log4j-core-* 2>/dev/null`"'
done
