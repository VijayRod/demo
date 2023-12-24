```
az aks update -g $rg -n aks --api-server-authorized-ip-ranges 73.140.245.0/24
az aks update -g $rg -n aks --api-server-authorized-ip-ranges ""
az aks show -g $rg -n aks --query apiServerAccessProfile.authorizedIpRanges
```

```
nc -vz $fqdn 443 # works from a non-authorized IP too
Connection to aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io 443 port [tcp/https] succeeded!

telnet $fqdn 443 # works from a non-authorized IP too
Trying 4.225.35.13...
Connected to aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io.

curl https://$fqdn -k # from a non-authorized IP
curl: (28) Failed to connect to aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io port 443: Connection timed out

curl https://$fqdn -vk
*   Trying 4.225.35.13:443...
* TCP_NODELAY set
* connect to 4.225.35.13 port 443 failed: Connection timed out
* Failed to connect to aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io port 443: Connection timed out
* Closing connection 0
curl: (28) Failed to connect to aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io port 443: Connection timed out

tcpdump host 4.225.35.13 # curl https://$fqdn -k from a non-authorized IP
tcpdump port 443
19:49:04.991368 IP 172.30.58.38.56898 > 4.225.35.13.https: Flags [S], seq 2388298995, win 64240, options [mss 1460,sackOK,TS val 3053869690 ecr 0,nop,wscale 7], length 0
19:49:06.059940 IP 172.30.58.38.56898 > 4.225.35.13.https: Flags [S], seq 2388298995, win 64240, options [mss 1460,sackOK,TS val 3053870759 ecr 0,nop,wscale 7], length 0
19:49:08.139988 IP 172.30.58.38.56898 > 4.225.35.13.https: Flags [S], seq 2388298995, win 64240, options [mss 1460,sackOK,TS val 3053872839 ecr 0,nop,wscale 7], length 0
19:49:12.219820 IP 172.30.58.38.56898 > 4.225.35.13.https: Flags [S], seq 2388298995, win 64240, options [mss 1460,sackOK,TS val 3053876919 ecr 0,nop,wscale 7], length 0
19:49:20.699964 IP 172.30.58.38.56898 > 4.225.35.13.https: Flags [S], seq 2388298995, win 64240, options [mss 1460,sackOK,TS val 3053885399 ecr 0,nop,wscale 7], length 0
19:49:37.340037 IP 172.30.58.38.56898 > 4.225.35.13.https: Flags [S], seq 2388298995, win 64240, options [mss 1460,sackOK,TS val 3053902039 ecr 0,nop,wscale 7], length 0
19:50:09.979829 IP 172.30.58.38.56898 > 4.225.35.13.https: Flags [S], seq 2388298995, win 64240, options [mss 1460,sackOK,TS val 3053934679 ecr 0,nop,wscale 7], length 0

az aks get-credentials -g $rg -n aks --overwrite-existing # works from a non-authorized IP too
The behavior of this command has been altered by the following extension: aks-preview
Merged "aks" as current context in /root/.kube/config

kubectl get po # from a non-authorized IP
Unable to connect to the server: dial tcp 4.225.35.13:443: i/o timeout

kubectl get po --v=9
I1219 19:47:09.424486     523 loader.go:373] Config loaded from file:  /root/.kube/config
I1219 19:47:09.428626     523 round_trippers.go:466] curl -v -XGET  -H "Accept: application/json;as=Table;v=v1;g=meta.k8s.io,application/json;as=Table;v=v1beta1;g=meta.k8s.io,application/json" -H "User-Agent: kubectl/v1.27.1 (linux/amd64) kubernetes/4c94112" -H "Authorization: Bearer <masked>" 'https://aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io:443/api/v1/namespaces/default/pods?limit=500'
I1219 19:47:09.472854     523 round_trippers.go:495] HTTP Trace: DNS Lookup for aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io resolved to [{4.225.35.13 }]
I1219 19:47:39.429559     523 round_trippers.go:508] HTTP Trace: Dial to tcp:4.225.35.13:443 failed: dial tcp 4.225.35.13:443: i/o timeout
I1219 19:47:39.429636     523 round_trippers.go:553] GET https://aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io:443/api/v1/namespaces/default/pods?limit=500  in 30000 milliseconds
I1219 19:47:39.429690     523 round_trippers.go:570] HTTP Statistics: DNSLookup 44 ms Dial 29956 ms TLSHandshake 0 ms Duration 30000 ms
I1219 19:47:39.429696     523 round_trippers.go:577] Response Headers:
I1219 19:47:39.429780     523 helpers.go:264] Connection error: Get https://aks-rg-8d99b0-6s1xjo5i.hcp.swedencentral.azmk8s.io:443/api/v1/namespaces/default/pods?limit=500: dial tcp 4.225.35.13:443: i/o timeout
Unable to connect to the server: dial tcp 4.225.35.13:443: i/o timeout
```
     
- https://learn.microsoft.com/en-us/azure/aks/api-server-authorized-ip-ranges
- https://learn.microsoft.com/en-us/azure/architecture/aws-professional/eks-to-aks/private-clusters#authorized-ip-ranges
