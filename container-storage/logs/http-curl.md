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

- https://curl.se/docs/manual.html
- https://everything.curl.dev/usingcurl/verbose
- TBD https://unix.stackexchange.com/questions/497706/does-curl-v-show-the-complete-http-request-including-the-body
