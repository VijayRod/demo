```
# curl https://akscustomd-testshack-111111-a17yzvzi.hcp.swedencentral.azmk8s.io:443
curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.haxx.se/docs/sslcerts.html
curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.

# curl -k https://akscustomd-testshack-111111-a17yzvzi.hcp.swedencentral.azmk8s.io:443
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "Unauthorized",
  "reason": "Unauthorized",
  "code": 401
}

# curl --insecure -vvI https://akscustomd-testshack-111111-a17yzvzi.hcp.swedencentral.azmk8s.io:443 2>&1 | awk 'BEGIN { cert=0 } /^\* SSL connection/ { cert=1 } /^\*/ { if (cert) print }'
* SSL connection using TLSv1.3 / TLS_AES_128_GCM_SHA256
* ALPN, server accepted to use h2
* Server certificate:
*  subject: CN=apiserver
*  start date: Aug  4 13:13:07 2023 GMT
*  expire date: Aug  4 13:23:07 2025 GMT
*  issuer: CN=ca
*  SSL certificate verify result: unable to get local issuer certificate (20), continuing anyway.
* Using HTTP2, server supports multi-use
* Connection state changed (HTTP/2 confirmed)
* Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0
* Using Stream ID: 1 (easy handle 0x5574fa8288d0)
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* Connection state changed (MAX_CONCURRENT_STREAMS == 250)!
* Connection #0 to host akscustomd-testshack-8d99b0-a17yzvzi.hcp.swedencentral.azmk8s.io left intact

# openssl s_client -showcerts -connect akscustomd-testshack-111111-a17yzvzi.hcp.swedencentral.azmk8s.io:443
CONNECTED(00000003)
depth=0 CN = apiserver
verify error:num=20:unable to get local issuer certificate
verify return:1
depth=0 CN = apiserver
verify error:num=21:unable to verify the first certificate
verify return:1
---
Certificate chain
 0 s:CN = apiserver
   i:CN = ca
-----BEGIN CERTIFICATE-----
...
```

```
# To curl with the certificate
fqdn="akscustomd-testshack-111111-a17yzvzi.hcp.swedencentral.azmk8s.io"
port=443
openssl s_client -showcerts -connect $fqdn:$port </dev/null | sed -n -e '/-.BEGIN/,/-.END/ p' > /tmp/aksfqdncert.pem
## cat /tmp/aksfqdncert.pem
curl --cacert /tmp/akscustomd.pem $fqdn:$port

# Here is a sample output below
Client sent an HTTP request to an HTTPS server.
```

- https://stackoverflow.com/questions/10079707/https-connection-using-curl-from-command-line
- http://javamemento.blogspot.com/2015/10/using-curl-with-ssl-cert-chain.html
