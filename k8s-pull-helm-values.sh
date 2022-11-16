#!/bin/bash
kubectl get namespaces | tail -n +2 | awk '{print $1}' > namespaces.txt
sleep 1
while read n; do

  helm ls -n $n | tail -n +2 | awk '{print $1}' > values.txt
  while read s; do
    if [ -s "values.txt" ]; then
        echo ""
        echo "Pulling helm values from $n namespace:"
    else
        # The file is empty.
        break
    fi
    echo helm get values $s -n $n -o yaml
    helm get values $s -n $n -o yaml > "$s-$n-values.yaml"
    sleep 1
    #if file is empty repeat
    if [ -s "$s-$n-values.yaml" ]; then
        # The file is not-empty.
        echo "$s-$n-values.yaml created"
    else
        # The file is empty.
        echo "FAIL: Retry pulling $s-values.yaml"
        helm get values $s -n $n -o yaml > "$s-$n-values.yaml"
    fi
  done <values.txt
  if [ -s "values.txt" ]; then
        echo ""
        echo "Pulled all helm values from $n namespace"
        echo "-------------------------------------"
  fi
  
  rm values.txt
  sleep 1
done <namespaces.txt

rm namespaces.txt
echo ""
echo "=== DONE ==="