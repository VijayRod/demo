```
nslookup aks-rgblob-111111-elknmkvh.hcp.swedencentral.azmk8s.io
Address: 51.12.129.redacted

nc aks-rg-111111-hptzgw9m.hcp.swedencentral.azmk8s.io 443 -z -v
Connection to aks-rg-111111-hptzgw9m.hcp.swedencentral.azmk8s.io 443 port [tcp/https] succeeded!

telnet aks-rgblob-111111-elknmkvh.hcp.swedencentral.azmk8s.io 443
Trying 51.12.129.redacted...
Connected to aks-rgblob-111111-elknmkvh.hcp.swedencentral.azmk8s.io:443.
Escape character is '^]'.

curl aks-rgblob-111111-elknmkvh.hcp.swedencentral.azmk8s.io:443 -I
HTTP/1.0 400 Bad Request
```

```
az aks command invoke -g $rg -n aks --command "kubectl get nodes"
command started at 2023-10-04 20:17:46+00:00, finished at 2023-10-04 20:17:47+00:00 with exitcode=0
NAME                                STATUS   ROLES   AGE     VERSION
aks-nodepool1-41508760-vmss000000   Ready    agent   7h50m   v1.26.6
```

```
# kubectl proxy --port=8080

curl -v -H "User-Agent: manual CURL test" 'http://localhost:8080/api/v1/nodes?limit=500'
*   Trying 127.0.0.1:8080...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 8080 (#0)
> GET /api/v1/nodes?limit=500 HTTP/1.1
...
< Date: Wed, 04 Oct 2023 20:18:57 GMT
{"kind":"NodeList","apiVersion":"v1"...

curl  -k -v -XGET -H "User-Agent: manual CURL test 2" 'https://aks-rg-111111-dr8gf1r0.hcp.swedencentral.azmk8s.io/api/v1/nodes?limit=500'
*   Trying redactedIp:443...
* TCP_NODELAY set
< date: Wed, 04 Oct 2023 20:19:32 GMT
* Connected to aks-rg-111111-dr8gf1r0.hcp.swedencentral.azmk8s.io (redactedIp) port 443 (#0)
{"kind":"Status","apiVersion":"v1","metadata":{},"status":"Failure","message":"Unauthorized","reason":"Unauthorized","code":401}
```
