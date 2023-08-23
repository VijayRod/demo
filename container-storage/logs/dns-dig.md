```
# dig google.com

; <<>> DiG 9.11.3-1ubuntu1.18-Ubuntu <<>> google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 31728
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;google.com.                    IN      A

;; ANSWER SECTION:
google.com.             50      IN      A       172.217.21.174

;; Query time: 2 msec
;; SERVER: 127.0.0.53#53(127.0.0.53)
;; WHEN: Wed Aug 22 22:12:34 UTC 2023
;; MSG SIZE  rcvd: 55

# dig google.com ns +trace +nodnssec

; <<>> DiG 9.11.3-1ubuntu1.18-Ubuntu <<>> google.com ns +trace +nodnssec
;; global options: +cmd
;; Received 28 bytes from 127.0.0.53#53(127.0.0.53) in 0 ms
```
