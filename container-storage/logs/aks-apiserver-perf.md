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
time kubectl get ns > null
curl -ikv https://$fqdn
```
