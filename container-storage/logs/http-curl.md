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
```

- https://curl.se/docs/manual.html
