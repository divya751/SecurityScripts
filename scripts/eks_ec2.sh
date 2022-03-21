kubectl get nodes -o=jsonpath='{range .items[*]}{.spec.providerID}{"\n"}{end}'
