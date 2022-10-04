#!/bin/bash

# Pulling all secrets from k8s cluster
# Prerequisite:
#	kubectl installed
#	Set config for cluster
##########################################################

kubectl get namespaces | tail -n +2 | awk '{print $1}' > namespaces.txt
mkdir -p secrets
sleep 1
while read n; do

  kubectl get secrets -n $n | tail -n +2 | awk '{print $1}' | grep -v 'sh.helm.release' > secrets.txt
  echo ""
  echo "Pulling secrets from $n namespace:"
  while read s; do
    kubectl get secret $s -n $n -o yaml > secrets/"$s-secret.yaml"
    #if file is empty repeat
    if [ -s secrets/"$s-secret.yaml" ]; then
        # The file is not-empty.
        echo "$s-secret.yaml created"
    else
        # The file is empty.
        echo "FAIL: Retry pulling $s-secret.yaml"
        kubectl get secret $s -n $n -o yaml > secrets/"$s-secret.yaml"
    fi
  done <secrets.txt
  echo ""
  echo "Pulled all secrets from $n namespace"
  echo "-------------------------------------"
  rm secrets.txt
done <namespaces.txt

rm namespaces.txt
echo ""
echo "=== DONE ==="