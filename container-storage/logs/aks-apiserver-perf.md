```
file=/tmp/curloutput
fqdn=redacted.hcp.swedencentral.azmk8s.io
while true; do date -u >> $file; curl https://$fqdn -k >> $file; sleep 1; done # Use Ctrl+C to stop the script
cat $file
# rm $file
```

```
file=/tmp/curloutput
fqdn=redacted.hcp.swedencentral.azmk8s.io
for ((i=1;i<=300;i++));do date -u; curl https://$fqdn -k; sleep 1; done >> $file # This loop runs for 300 iterations (approximately 300 seconds), then record output in file
cat $file
# rm $file
```

```
# https://kubernetes.io/docs/reference/using-api/health-checks/
fqdn=redacted.hcp.swedencentral.azmk8s.io
kubectl create sa k8sadmin
token=$(kubectl create token k8sadmin)
while true; do date -u; curl --connect-timeout 10 --show-error -sk --header "Authorization: Bearer $token" "https://$fqdn" > /dev/null; sleep 1; done
# kubectl delete sa k8sadmin
```

```
time kubectl get ns > null
curl -ikv https://$fqdn
```
