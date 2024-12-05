```
curl https://google.com -v
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* TLSv1.3 (IN), TLS handshake, Certificate (11):
* TLSv1.3 (IN), TLS handshake, CERT verify (15):
* TLSv1.3 (IN), TLS handshake, Finished (20):
* TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.3 (OUT), TLS handshake, Finished (20):
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
* ALPN, server accepted to use h2
* Server certificate:
*  subject: CN=*.google.com
*  start date: Jul 30 12:32:53 2024 GMT
*  expire date: Oct 22 12:32:52 2024 GMT
*  subjectAltName: host "google.com" matched cert's "google.com"
*  issuer: C=US; O=Google Trust Services; CN=WR2
*  SSL certificate verify ok.
* Using HTTP2, server supports multi-use
* Connection state changed (HTTP/2 confirmed)
* Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0
* Using Stream ID: 1 (easy handle 0x55c95ec5a0e0)
> GET / HTTP/2

curl https://google.com
tcpdump tcp port 443 and host 142.250.185.14
00:05:34.155361 IP 1.2.3.4.43400 > mad41s11-in-f14.1e100.net.https: Flags [S], seq 2815208136, win 64480, options [mss 1240,sackOK,TS val 273835758 ecr 0,nop,wscale 7], length 0
00:05:34.170518 IP mad41s11-in-f14.1e100.net.https > 1.2.3.4.43400: Flags [S.], seq 2269674812, ack 2815208137, win 65535, options [mss 1412,sackOK,TS val 1231705521 ecr 273835758,nop,wscale 8], length 0
00:05:34.170590 IP 1.2.3.4.43400 > mad41s11-in-f14.1e100.net.https: Flags [.], ack 1, win 504, options [nop,nop,TS val 273835773 ecr 1231705521], length 0
00:05:34.175325 IP 1.2.3.4.43400 > mad41s11-in-f14.1e100.net.https: Flags [P.], seq 1:518, ack 1, win 504, options [nop,nop,TS val 273835778 ecr 1231705521], length 517
00:05:34.189605 IP mad41s11-in-f14.1e100.net.https > 1.2.3.4.43400: Flags [.], ack 518, win 261, options [nop,nop,TS val 1231705540 ecr 273835778], length 0
00:05:34.212065 IP mad41s11-in-f14.1e100.net.https > 1.2.3.4.43400: Flags [P.], seq 1:2457, ack 518, win 261, options [nop,nop,TS val 1231705559 ecr 273835778], length 2456
00:05:34.212091 IP mad41s11-in-f14.1e100.net.https > 1.2.3.4.43400: Flags [P.], seq 2457:4913, ack 518, win 261, options [nop,nop,TS val 1231705559 ecr 273835778], length 2456
00:05:34.212092 IP mad41s11-in-f14.1e100.net.https > 1.2.3.4.43400: Flags [P.], seq 4913:6601, ack 518, win 261, options [nop,nop,TS val 1231705559 ecr 273835778], length 1688
00:05:34.212117 IP 1.2.3.4.43400 > mad41s11-in-f14.1e100.net.https: Flags [.], ack 2457, win 498, options [nop,nop,TS val 273835814 ecr 1231705559], length 0
00:05:34.212150 IP 1.2.3.4.43400 > mad41s11-in-f14.1e100.net.https: Flags [.], ack 4913, win 484, options [nop,nop,TS val 273835815 ecr 1231705559], length 0
00:05:34.212153 IP 1.2.3.4.43400 > mad41s11-in-f14.1e100.net.https: Flags [.], ack 6601, win 472, options [nop,nop,TS val 273835815 ecr 1231705559], length 0
00:05:34.213478 IP 1.2.3.4.43400 > mad41s11-in-f14.1e100.net.https: Flags [P.], seq 518:598, ack 6601, win 503, options [nop,nop,TS val 273835816 ecr 1231705559], length 80
00:05:34.213725 IP 1.2.3.4.43400 > mad41s11-in-f14.1e100.net.https: Flags [P.], seq 598:693, ack 6601, win 503, options [nop,nop,TS val 273835816 ecr 1231705559], length 95
00:05:34.213953 IP 1.2.3.4.43400 > mad41s11-in-f14.1e100.net.https: Flags [P.], seq 693:786, ack 6601, win 503, options [nop,nop,TS val 273835816 ecr 1231705559], length 93
00:05:34.227209 IP mad41s11-in-f14.1e100.net.https > 1.2.3.4.43400: Flags [P.], seq 6601:7249, ack 693, win 261, options [nop,nop,TS val 1231705578 ecr 273835816], length 648
00:05:34.227248 IP mad41s11-in-f14.1e100.net.https > 1.2.3.4.43400: Flags [P.], seq 7249:7280, ack 786, win 261, options [nop,nop,TS val 1231705578 ecr 273835816], length 31
00:05:34.227809 IP 1.2.3.4.43400 > mad41s11-in-f14.1e100.net.https: Flags [P.], seq 786:817, ack 7280, win 503, options [nop,nop,TS val 273835830 ecr 1231705578], length 31
00:05:34.245927 IP mad41s11-in-f14.1e100.net.https > 1.2.3.4.43400: Flags [.], ack 817, win 261, options [nop,nop,TS val 1231705597 ecr 273835830], length 0
00:05:34.255927 IP mad41s11-in-f14.1e100.net.https > 1.2.3.4.43400: Flags [P.], seq 7280:7700, ack 817, win 261, options [nop,nop,TS val 1231705607 ecr 273835830], length 420
00:05:34.255968 IP mad41s11-in-f14.1e100.net.https > 1.2.3.4.43400: Flags [P.], seq 7700:7951, ack 817, win 261, options [nop,nop,TS val 1231705607 ecr 273835830], length 251
00:05:34.255969 IP mad41s11-in-f14.1e100.net.https > 1.2.3.4.43400: Flags [P.], seq 7951:7982, ack 817, win 261, options [nop,nop,TS val 1231705608 ecr 273835830], length 31
00:05:34.255970 IP mad41s11-in-f14.1e100.net.https > 1.2.3.4.43400: Flags [P.], seq 7982:8021, ack 817, win 261, options [nop,nop,TS val 1231705608 ecr 273835830], length 39
00:05:34.256587 IP 1.2.3.4.43400 > mad41s11-in-f14.1e100.net.https: Flags [P.], seq 817:841, ack 8021, win 503, options [nop,nop,TS val 273835859 ecr 1231705607], length 24
00:05:34.257747 IP 1.2.3.4.43400 > mad41s11-in-f14.1e100.net.https: Flags [R.], seq 841, ack 8021, win 503, options [nop,nop,TS val 273835860 ecr 1231705607], length 0
00:05:34.270154 IP mad41s11-in-f14.1e100.net.https > 1.2.3.4.43400: Flags [F.], seq 8021, ack 841, win 261, options [nop,nop,TS val 1231705621 ecr 273835859], length 0
00:05:34.270246 IP 1.2.3.4.43400 > mad41s11-in-f14.1e100.net.https: Flags [R], seq 2815208977, win 0, length 0

curl https://google.com
wireshark tcp.port==443
ip.addr == 142.250.184.174 # Client Hello (SNI=google.com)
16	2024-08-09 00:15:24.251893	192.168.1.65	142.250.184.174	TCP	74	58100 ? 443 [SYN] Seq=0 Win=64480 Len=0 MSS=1240 SACK_PERM TSval=3382220263 TSecr=0 WS=128
17	2024-08-09 00:15:24.267745	142.250.184.174	192.168.1.65	TCP	74	443 ? 58100 [SYN, ACK] Seq=0 Ack=1 Win=65535 Len=0 MSS=1412 SACK_PERM TSval=114684267 TSecr=3382220263 WS=256
18	2024-08-09 00:15:24.268350	192.168.1.65	142.250.184.174	TCP	66	58100 ? 443 [ACK] Seq=1 Ack=1 Win=64512 Len=0 TSval=3382220279 TSecr=114684267
19	2024-08-09 00:15:24.277628	192.168.1.65	142.250.184.174	TLSv1.3	583	Client Hello (SNI=google.com)
20	2024-08-09 00:15:24.293403	142.250.184.174	192.168.1.65	TCP	66	443 ? 58100 [ACK] Seq=1 Ack=518 Win=66816 Len=0 TSval=114684293 TSecr=3382220289
21	2024-08-09 00:15:24.313175	142.250.184.174	192.168.1.65	TLSv1.3	1294	Server Hello, Change Cipher Spec
22	2024-08-09 00:15:24.313175	142.250.184.174	192.168.1.65	TCP	1294	443 ? 58100 [PSH, ACK] Seq=1229 Ack=518 Win=66816 Len=1228 TSval=114684312 TSecr=3382220289 [TCP segment of a reassembled PDU]
23	2024-08-09 00:15:24.313175	142.250.184.174	192.168.1.65	TCP	1294	443 ? 58100 [ACK] Seq=2457 Ack=518 Win=66816 Len=1228 TSval=114684312 TSecr=3382220289 [TCP segment of a reassembled PDU]
24	2024-08-09 00:15:24.314375	192.168.1.65	142.250.184.174	TCP	66	58100 ? 443 [ACK] Seq=518 Ack=2457 Win=63744 Len=0 TSval=3382220325 TSecr=114684312
25	2024-08-09 00:15:24.314512	192.168.1.65	142.250.184.174	TCP	66	58100 ? 443 [ACK] Seq=518 Ack=3685 Win=62848 Len=0 TSval=3382220325 TSecr=114684312
26	2024-08-09 00:15:24.315750	142.250.184.174	192.168.1.65	TCP	1294	443 ? 58100 [PSH, ACK] Seq=3685 Ack=518 Win=66816 Len=1228 TSval=114684312 TSecr=3382220289 [TCP segment of a reassembled PDU]
27	2024-08-09 00:15:24.315750	142.250.184.174	192.168.1.65	TCP	1294	443 ? 58100 [ACK] Seq=4913 Ack=518 Win=66816 Len=1228 TSval=114684312 TSecr=3382220289 [TCP segment of a reassembled PDU]
28	2024-08-09 00:15:24.315750	142.250.184.174	192.168.1.65	TLSv1.3	526	Application Data
30	2024-08-09 00:15:24.316739	192.168.1.65	142.250.184.174	TCP	66	58100 ? 443 [ACK] Seq=518 Ack=4913 Win=64384 Len=0 TSval=3382220328 TSecr=114684312
31	2024-08-09 00:15:24.316846	192.168.1.65	142.250.184.174	TCP	66	58100 ? 443 [ACK] Seq=518 Ack=6601 Win=62976 Len=0 TSval=3382220328 TSecr=114684312
32	2024-08-09 00:15:24.318496	192.168.1.65	142.250.184.174	TLSv1.3	146	Change Cipher Spec, Application Data
33	2024-08-09 00:15:24.318571	192.168.1.65	142.250.184.174	TLSv1.3	161	Application Data, Application Data
34	2024-08-09 00:15:24.318818	192.168.1.65	142.250.184.174	TLSv1.3	159	Application Data, Application Data
36	2024-08-09 00:15:24.333250	142.250.184.174	192.168.1.65	TLSv1.3	97	[TCP Previous segment not captured] , Application Data
37	2024-08-09 00:15:24.333250	142.250.184.174	192.168.1.65	TCP	714	[TCP Out-Of-Order] 443 ? 58100 [PSH, ACK] Seq=6601 Ack=693 Win=66816 Len=648 TSval=114684333 TSecr=3382220329
38	2024-08-09 00:15:24.334162	192.168.1.65	142.250.184.174	TCP	78	[TCP Dup ACK 31#1] 58100 ? 443 [ACK] Seq=786 Ack=6601 Win=64384 Len=0 TSval=3382220345 TSecr=114684312 SLE=7249 SRE=7280
39	2024-08-09 00:15:24.334301	192.168.1.65	142.250.184.174	TCP	66	58100 ? 443 [ACK] Seq=786 Ack=7280 Win=64384 Len=0 TSval=3382220345 TSecr=114684312
40	2024-08-09 00:15:24.335003	192.168.1.65	142.250.184.174	TLSv1.3	97	Application Data
43	2024-08-09 00:15:24.355974	142.250.184.174	192.168.1.65	TCP	66	443 ? 58100 [ACK] Seq=7280 Ack=817 Win=66816 Len=0 TSval=114684356 TSecr=3382220346
45	2024-08-09 00:15:24.372276	142.250.184.174	192.168.1.65	TLSv1.3	486	Application Data
46	2024-08-09 00:15:24.372276	142.250.184.174	192.168.1.65	TLSv1.3	317	Application Data
47	2024-08-09 00:15:24.372276	142.250.184.174	192.168.1.65	TLSv1.3	97	Application Data
48	2024-08-09 00:15:24.372276	142.250.184.174	192.168.1.65	TLSv1.3	105	Application Data
49	2024-08-09 00:15:24.375412	192.168.1.65	142.250.184.174	TLSv1.3	90	Application Data
50	2024-08-09 00:15:24.375525	192.168.1.65	142.250.184.174	TCP	66	58100 ? 443 [RST, ACK] Seq=841 Ack=8021 Win=64384 Len=0 TSval=3382220386 TSecr=114684363

curl https://google.com
tcpdump "tcp port 443 and (tcp[((tcp[12] & 0xf0) >>2)] = 0x16) && (tcp[((tcp[12] & 0xf0) >>2)+5] = 0x01)" -w /tmp/client-hello.pcap
wireshark tls.handshake.extensions_server_name == "google.com"
2	2024-08-09 00:31:11.848657	1.2.3.4	142.250.200.142	TLSv1	583	Client Hello (SNI=google.com)

curl https://google.com
wireshark ssl.handshake
176	2024-08-09 01:27:56.794758	192.168.1.65	142.250.185.14	TLSv1.3	583	Client Hello (SNI=google.com)
178	2024-08-09 01:27:56.834599	142.250.185.14	192.168.1.65	TLSv1.3	1294	Server Hello, Change Cipher Spec
```

- https://www.digicert.com/what-is-ssl-tls-and-https
- https://www.ssl.com/article/ssl-tls-handshake-ensuring-secure-online-interactions/
- https://developer.mozilla.org/en-US/docs/Web/Security/Transport_Layer_Security
- https://www.okta.com/identity-101/ssl-handshake/
- tbd https://auth0.com/blog/the-tls-handshake-explained/
- https://www.cloudflare.com/en-in/learning/ssl/what-is-https/
- https://www.cloudflare.com/en-in/learning/ssl/what-happens-in-a-tls-handshake/: What are the steps of a TLS handshake?
- https://datatracker.ietf.org/doc/html/rfc5246
- https://wiki.wireshark.org/TLS
- https://manpages.ubuntu.com/manpages/bionic/man1/mitmdump.1.html
- https://unix.stackexchange.com/questions/103037/what-tool-can-i-use-to-sniff-http-https-traffic
- tbd https://www.hostzealot.com/blog/how-to/ssl-handshake-capture-with-tcpdump
- tbd https://www.baeldung.com/linux/tcpdump-capture-ssl-handshake
- https://techkluster.com/linux/tcpdump-capture-ssl-handshake/
- https://www.sslshopper.com/ssl-checker.html
- https://learn.microsoft.com/en-us/troubleshoot/developer/webapps/iis/www-authentication-authorization/troubleshooting-ssl-related-issues-server-certificate
