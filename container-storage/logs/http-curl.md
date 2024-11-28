## curl

- https://curl.se/docs/manual.html
- https://everything.curl.dev/usingcurl/verbose
- TBD https://unix.stackexchange.com/questions/497706/does-curl-v-show-the-complete-http-request-including-the-body

## curl.debug.common

```
curl -v --trace-time google.com
15:49:39.679406 *   Trying 142.250.200.110:80...
15:49:39.679617 * TCP_NODELAY set
15:49:39.701931 * Connected to google.com (142.250.200.110) port 80 (#0)

curl -I google.com
HTTP/1.1 301 Moved Permanently
Location: http://www.google.com/
Content-Type: text/html; charset=UTF-8
Content-Security-Policy-Report-Only: object-src 'none';base-uri 'self';script-src 'nonce-VrKFjNOTylg4-UGnFbiI9g' 'strict-dynamic' 'report-sample' 'unsafe-eval' 'unsafe-inline' https: http:;report-uri https://csp.withgoogle.com/csp/gws/other-hp
Date: Mon, 02 Oct 2023 22:51:19 GMT
Expires: Wed, 01 Nov 2023 22:51:19 GMT
Cache-Control: public, max-age=2592000
Server: gws

time curl -I google.com
...
real    0m0.199s
user    0m0.019s
sys     0m0.010s

curl -kvv https://google.com
curl https://$fqdn -k --trace-time --trace /tmp/curl.log # cat /tmp/curl.log
url="https://google.com"; curl -Ss -m 10 -I $url >/dev/null 2>&1
```

```
kubectl exec -it nginx -- /bin/bash # curl google.com -I
```

## curl.debug.https.verbose

```
curl -v https://f989246f5c8f43179b0bd73c36268aaf.alb.azure.com
* Host f989246f5c8f43179b0bd73c36268aaf.alb.azure.com:443 was resolved.
* IPv6: (none)
* IPv4: 52.159.200.1
*   Trying 52.159.200.1:443...
* Connected to f989246f5c8f43179b0bd73c36268aaf.alb.azure.com (52.159.200.1) port 443
* ALPN: curl offers h2,http/1.1
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
*  CAfile: /etc/ssl/certs/ca-certificates.crt
*  CApath: /etc/ssl/certs
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* TLSv1.3 (IN), TLS handshake, Certificate (11):
* TLSv1.3 (IN), TLS handshake, CERT verify (15):
* TLSv1.3 (IN), TLS handshake, Finished (20):
* TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.3 (OUT), TLS handshake, Finished (20):
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384 / X25519 / RSASSA-PSS
* ALPN: server accepted h2
* Server certificate:
*  subject: C=US; ST=WA; L=Redmond; O=Microsoft Corporation; CN=f989.alb.azure.com
*  start date: Nov 28 18:00:47 2024 GMT
*  expire date: May 27 18:00:47 2025 GMT
*  subjectAltName: host "f989246f5c8f43179b0bd73c36268aaf.alb.azure.com" matched cert's "f989246f5c8f43179b0bd73c36268aaf.alb.azure.com"
*  issuer: C=US; O=Microsoft Corporation; CN=Microsoft Azure RSA TLS Issuing CA 07
*  SSL certificate verify ok.
*   Certificate level 0: Public key type RSA (2048/112 Bits/secBits), signed using sha384WithRSAEncryption
*   Certificate level 1: Public key type RSA (4096/152 Bits/secBits), signed using sha384WithRSAEncryption
*   Certificate level 2: Public key type RSA (2048/112 Bits/secBits), signed using sha256WithRSAEncryption
* using HTTP/2
* [HTTP/2] [1] OPENED stream for https://f989246f5c8f43179b0bd73c36268aaf.alb.azure.com/
* [HTTP/2] [1] [:method: GET]
* [HTTP/2] [1] [:scheme: https]
* [HTTP/2] [1] [:authority: f989246f5c8f43179b0bd73c36268aaf.alb.azure.com]
* [HTTP/2] [1] [:path: /]
* [HTTP/2] [1] [user-agent: curl/8.5.0]
* [HTTP/2] [1] [accept: */*]
> GET / HTTP/2
> Host: f989246f5c8f43179b0bd73c36268aaf.alb.azure.com
> User-Agent: curl/8.5.0
> Accept: */*
>
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* old SSL session ID is stale, removing
< HTTP/2 415
< content-type: application/grpc
< grpc-status: 3
< grpc-message: invalid gRPC request content-type ""
< x-envoy-upstream-service-time: 0
< date: Thu, 28 Nov 2024 18:17:18 GMT
< server: envoy
<
* Connection #0 to host f989246f5c8f43179b0bd73c36268aaf.alb.azure.com left intact
```
