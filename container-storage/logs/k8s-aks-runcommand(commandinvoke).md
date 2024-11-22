## commandinvoke.aks

```
# See the section on private cluster commandinvoke

az aks command invoke -g $rg -n aks --command "kubectl get pods -n kube-system" # public/private cluster
command started at 2023-11-22 19:35:19+00:00, finished at 2023-11-22 19:35:19+00:00 with exitcode=0
NAME                                  READY   STATUS    RESTARTS   AGE
azure-ip-masq-agent-894qx             1/1     Running   0          3h30m
...

az aks command invoke -g $rg -n aks --command "kubectl get ns"
command started at 2024-10-22 23:04:44+00:00, finished at 2024-10-22 23:04:44+00:00 with exitcode=0
NAME              STATUS   AGE
aks-command       Active   4s
default           Active   73m
kube-node-lease   Active   73m
kube-public       Active   73m
kube-system       Active   73m
```

```
# conn

az aks show -g $rg -n aksprivate | grep azmk8s
WARNING: The behavior of this command has been altered by the following extension: aks-preview
  "azurePortalFqdn": "127956cd387c12f8541f055eee83e384-priv.portal.hcp.swedencentral.azmk8s.io",
  "fqdn": "aksprivate-rg-efec8e-vylsis3l.hcp.swedencentral.azmk8s.io",
  "privateFqdn": "aksprivate-rg-efec8e-2fc44ihq.ec2ccfad-dd02-4ef6-8ce0-e3f276ae86aa.privatelink.swedencentral.azmk8s.io",

az aks command invoke -g $rg -n aksprivate --command "curl -Iv https://aksprivate-rg-efec8e-2fc44ihq.ec2ccfad-dd02-4ef6-8ce0-e3f276ae86aa.privatelink.swedencentral.azmk8s.io"
command started at 2024-11-21 18:40:17+00:00, finished at 2024-11-21 18:40:17+00:00 with exitcode=60
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0*   Trying 10.224.0.4:443...
* Connected to aksprivate-rg-efec8e-2fc44ihq.ec2ccfad-dd02-4ef6-8ce0-e3f276ae86aa.privatelink.swedencentral.azmk8s.io (10.224.0.4) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*  CAfile: /etc/ssl/certs/ca-certificates.crt
*  CApath: /etc/ssl/certs
} [5 bytes data]
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
} [512 bytes data]
* TLSv1.3 (IN), TLS handshake, Server hello (2):
{ [122 bytes data]
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
{ [15 bytes data]
* TLSv1.3 (IN), TLS handshake, Request CERT (13):
{ [89 bytes data]
* TLSv1.3 (IN), TLS handshake, Certificate (11):
{ [1668 bytes data]
* TLSv1.3 (OUT), TLS alert, unknown CA (560):
} [2 bytes data]
* SSL certificate problem: unable to get local issuer certificate
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
* Closing connection 0
curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.se/docs/sslcerts.html
curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.

az aks command invoke -g $rg -n aksprivate --command "curl -Ikv https://aksprivate-rg-efec8e-2fc44ihq.ec2ccfad-dd02-4ef6-8ce0-e3f276ae86aa.privatelink.swedencentral.azmk8s.io"
command started at 2024-11-21 18:40:04+00:00, finished at 2024-11-21 18:40:04+00:00 with exitcode=0
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0*   Trying 10.224.0.4:443...
* Connected to aksprivate-rg-efec8e-2fc44ihq.ec2ccfad-dd02-4ef6-8ce0-e3f276ae86aa.privatelink.swedencentral.azmk8s.io (10.224.0.4) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*  CAfile: /etc/ssl/certs/ca-certificates.crt
*  CApath: /etc/ssl/certs
} [5 bytes data]
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
} [512 bytes data]
* TLSv1.3 (IN), TLS handshake, Server hello (2):
{ [122 bytes data]
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
{ [15 bytes data]
* TLSv1.3 (IN), TLS handshake, Request CERT (13):
{ [89 bytes data]
* TLSv1.3 (IN), TLS handshake, Certificate (11):
{ [1668 bytes data]
* TLSv1.3 (IN), TLS handshake, CERT verify (15):
{ [520 bytes data]
* TLSv1.3 (IN), TLS handshake, Finished (20):
{ [36 bytes data]
* TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
} [1 bytes data]
* TLSv1.3 (OUT), TLS handshake, Certificate (11):
} [8 bytes data]
* TLSv1.3 (OUT), TLS handshake, Finished (20):
} [36 bytes data]
* SSL connection using TLSv1.3 / TLS_AES_128_GCM_SHA256
* ALPN, server accepted to use h2
* Server certificate:
*  subject: CN=apiserver
*  start date: Nov 21 18:00:30 2024 GMT
*  expire date: Nov 21 18:10:30 2026 GMT
*  issuer: CN=ca
*  SSL certificate verify result: unable to get local issuer certificate (20), continuing anyway.
* Using HTTP2, server supports multi-use
* Connection state changed (HTTP/2 confirmed)
* Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0
} [5 bytes data]
* Using Stream ID: 1 (easy handle 0x5568efbe3620)
} [5 bytes data]
> HEAD / HTTP/2
> Host: aksprivate-rg-efec8e-2fc44ihq.ec2ccfad-dd02-4ef6-8ce0-e3f276ae86aa.privatelink.swedencentral.azmk8s.io
> user-agent: curl/7.74.0
> accept: */*
>
{ [5 bytes data]
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
{ [122 bytes data]
* Connection state changed (MAX_CONCURRENT_STREAMS == 100)!
} [5 bytes data]
< HTTP/2 401
< audit-id: 65a63548-6ae3-401c-9f07-21531f3a1597
< cache-control: no-cache, private
< content-type: application/json
< content-length: 157
< date: Thu, 21 Nov 2024 18:40:04 GMT
<
  0   157    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
* Closing connection 0
} [5 bytes data]
* TLSv1.3 (OUT), TLS alert, close notify (256):
} [2 bytes data]
HTTP/2 401
audit-id: 65a63548-6ae3-401c-9f07-21531f3a1597
cache-control: no-cache, private
content-type: application/json
content-length: 157
date: Thu, 21 Nov 2024 18:40:04 GMT

# does not include the IP
az aks command invoke -g $rg -n aksprivate --command "curl -Ik https://aksprivate-rg-efec
8e-2fc44ihq.ec2ccfad-dd02-4ef6-8ce0-e3f276ae86aa.privatelink.swedencentral.azmk8s.io"
command started at 2024-11-21 18:38:47+00:00, finished at 2024-11-21 18:38:47+00:00 with exitcode=0
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0   157    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
HTTP/2 401
audit-id: bb4b3fa1-8c1d-49ef-ac92-66c19f0d8e21
cache-control: no-cache, private
content-type: application/json
content-length: 157
date: Thu, 21 Nov 2024 18:38:47 GMT

# does not include the IP
az aks command invoke -g $rg -n aksprivate --command "curl -k https://aksprivate-rg-efec8e-2fc44ihq.ec2ccfad-dd02-4ef6-8ce0-e3f276ae86aa.privatelink.swedencentral.azmk8s.io"
command started at 2024-11-21 18:38:30+00:00, finished at 2024-11-21 18:38:30+00:00 with exitcode=0
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   157  100   157    0     0   7476      0 --:--:-- --:--:-- --:--:--  7476
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "Unauthorized",
  "reason": "Unauthorized",
  "code": 401
}
```

```
# don't run by default
  
az aks command invoke -g $rg -n aks --command "nc -v google.com 443 -w 1"
command started at 2024-11-21 18:49:32+00:00, finished at 2024-11-21 18:49:32+00:00 with exitcode=127
/bin/sh: 1: nc: not found

az aks command invoke -g $rg -n aks --command "nslookup google.com"
command started at 2024-11-21 18:32:15+00:00, finished at 2024-11-21 18:32:15+00:00 with exitcode=127
/bin/sh: 1: nslookup: not found

az aks command invoke -g $rg -n aks --command "dig google.com"
command started at 2024-11-21 18:33:50+00:00, finished at 2024-11-21 18:33:50+00:00 with exitcode=127
/bin/sh: 1: dig: not found

az aks command invoke -g $rg -n aks --command "az --version"
command started at 2024-11-21 18:29:40+00:00, finished at 2024-11-21 18:29:40+00:00 with exitcode=127
/bin/sh: 1: az: not found

az aks command invoke -g $rg -n aksnat --command "apt update -y"
/bin/sh: 1: apt: not found

az aks command invoke -g $rg -n aksnat --command "yum"
/bin/sh: 1: yum: not found
```
  
- https://azure.microsoft.com/en-us/updates/public-preview-of-azure-kubernetes-service-aks-runcommand-feature/
- https://learn.microsoft.com/en-us/azure/aks/access-private-cluster?tabs=azure-cli#run-commands-on-your-aks-cluster
