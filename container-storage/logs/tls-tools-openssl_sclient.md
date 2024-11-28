## openssl

- https://www.openssl.org/docs/man1.0.2/man1/s_client.html
  
## openssl.debug.common

```
fqdn=stackoverflow.com
openssl s_client -connect $fqdn:443 -prexit
TBD openssl s_client -connect $fqdn:443 -tls1_2 -status -msg -debug -CAfile <path to trusted root ca pem> -key <path to client private key pem> -cert <path to client cert pem> # -tlsextdebug -prexit -state
openssl s_client -showcerts -connect $fqdn:443 < /dev/null # Add an End-of-Line (EOL) character to the STDIN to prevent hanging on the terminal
```

## openssl.debug.s_client.showcerts

```
openssl s_client -connect f989246f5c8f43179b0bd73c36268aaf.alb.azure.com:443 -showcerts

CONNECTED(00000003)
depth=2 C = US, O = DigiCert Inc, OU = www.digicert.com, CN = DigiCert Global Root G2
verify return:1
depth=1 C = US, O = Microsoft Corporation, CN = Microsoft Azure RSA TLS Issuing CA 07
verify return:1
depth=0 C = US, ST = WA, L = Redmond, O = Microsoft Corporation, CN = f989.alb.azure.com
verify return:1
---
Certificate chain
 0 s:C = US, ST = WA, L = Redmond, O = Microsoft Corporation, CN = f989.alb.azure.com
   i:C = US, O = Microsoft Corporation, CN = Microsoft Azure RSA TLS Issuing CA 07
   a:PKEY: rsaEncryption, 2048 (bit); sigalg: RSA-SHA384
   v:NotBefore: Nov 28 18:00:47 2024 GMT; NotAfter: May 27 11:00:47 2025 GMT
-----BEGIN CERTIFICATE-----
MIIIzredacted
fA==
-----END CERTIFICATE-----
 1 s:C = US, O = Microsoft Corporation, CN = Microsoft Azure RSA TLS Issuing CA 07
   i:C = US, O = DigiCert Inc, OU = www.digicert.com, CN = DigiCert Global Root G2
   a:PKEY: rsaEncryption, 4096 (bit); sigalg: RSA-SHA384
   v:NotBefore: Jun  8 00:00:00 2023 GMT; NotAfter: Aug 25 23:59:59 2026 GMT
-----BEGIN CERTIFICATE-----
MIIFredacated
E/peia+Qcdk9Qsr+1VgCGA==
-----END CERTIFICATE-----
 2 s:C = US, O = DigiCert Inc, OU = www.digicert.com, CN = DigiCert Global Root G2
   i:C = US, O = DigiCert Inc, OU = www.digicert.com, CN = DigiCert Global Root G2
   a:PKEY: rsaEncryption, 2048 (bit); sigalg: RSA-SHA256
   v:NotBefore: Aug  1 12:00:00 2013 GMT; NotAfter: Jan 15 12:00:00 2038 GMT
-----BEGIN CERTIFICATE-----
MIIDjredacted
MrY=
-----END CERTIFICATE-----
---
Server certificate
subject=C = US, ST = WA, L = Redmond, O = Microsoft Corporation, CN = f989.alb.azure.com
issuer=C = US, O = Microsoft Corporation, CN = Microsoft Azure RSA TLS Issuing CA 07
---
No client certificate CA names sent
Peer signing digest: SHA256
Peer signature type: RSA-PSS
Server Temp Key: X25519, 253 bits
---
SSL handshake has read 5127 bytes and written 428 bytes
Verification: OK
---
New, TLSv1.3, Cipher is TLS_AES_256_GCM_SHA384
Server public key is 2048 bit
Secure Renegotiation IS NOT supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
Early data was not sent
Verify return code: 0 (ok)
---
---
Post-Handshake New Session Ticket arrived:
SSL-Session:
    Protocol  : TLSv1.3
    Cipher    : TLS_AES_256_GCM_SHA384
    Session-ID: C5A7556260A296A2BC91C20F175188162D6ED8591C39BAC6553589F05104E81C
    Session-ID-ctx:
    Resumption PSK: AC15E382225780A6EBB42A87DE03922FA6DE6E0B9E75319E31BF5F3A95A8B3D378A2FC90B2068899377FCEAA17282C1A
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    TLS session ticket lifetime hint: 172800 (seconds)
    TLS session ticket:
    0000 - 2c e1 3f 66 c3 48 e5 2f-2f 71 a1 13 55 b8 a3 19   ,.?f.H.//q..U...
    0010 - 1e 14 8f e8 14 85 7d 14-98 30 2a 11 d2 a5 23 b3   ......}..0*...#.
    0020 - 2b 22 bf 6f d2 f6 8e 47-55 51 86 ac d0 88 ca 04   +".o...GUQ......
    0030 - b3 8e 4e 41 1f 10 67 a0-4d 90 dc ff 75 a6 f1 34   ..NA..g.M...u..4
    0040 - 91 31 e5 40 90 65 1a 41-be d4 ad 09 4e b3 5d 7b   .1.@.e.A....N.]{
    0050 - b2 a7 21 e0 09 27 06 72-37 20 0d be be 6f 2b b8   ..!..'.r7 ...o+.
    0060 - 0d 09 1b d6 60 7c 95 94-ca 12 3b 2d e2 06 43 b8   ....`|....;-..C.
    0070 - 43 7f 26 dd 34 ab d1 17-6e 3f 73 4a 39 69 60 a4   C.&.4...n?sJ9i`.
    0080 - 3a ea f1 7a f0 9d 56 87-0f 2c b5 82 e7 20 91 fa   :..z..V..,... ..
    0090 - dc 2f e8 14 4a 14 24 39-94 e2 51 01 1b f6 b7 57   ./..J.$9..Q....W
    00a0 - 4e 41 a9 bb e5 a5 10 fd-8c 6f 11 61 76 c7 27 a3   NA.......o.av.'.
    00b0 - e0 57 80 07 9c df ea 88-2f 46 61 dc 31 ef 52 a1   .W....../Fa.1.R.
    00c0 - d6 fd 7c 2e 61 00 f0 11-c2 05 51 f3 03 03 92 18   ..|.a.....Q.....

    Start Time: 1732792777
    Timeout   : 7200 (sec)
    Verify return code: 0 (ok)
    Extended master secret: no
    Max Early Data: 0
---
read R BLOCK
---
Post-Handshake New Session Ticket arrived:
SSL-Session:
    Protocol  : TLSv1.3
    Cipher    : TLS_AES_256_GCM_SHA384
    Session-ID: AB2080E2A2B83E22F79ED25C10321FADB7F084B99F4A34CC5DDF69BB287D2D03
    Session-ID-ctx:
    Resumption PSK: A2CA015F27A87248AA2339DFF99CE6F7CFE773203635F38C398E49B25395126173D16ECFCC02362F1717497C29F6D9BB
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    TLS session ticket lifetime hint: 172800 (seconds)
    TLS session ticket:
    0000 - 2c e1 3f 66 c3 48 e5 2f-2f 71 a1 13 55 b8 a3 19   ,.?f.H.//q..U...
    0010 - 34 f7 6a 36 79 41 4f 19-af 07 fd de ce 88 87 6d   4.j6yAO........m
    0020 - 5f 8c ed 8d 54 12 22 f8-08 c7 d1 8c c0 39 5f 60   _...T."......9_`
    0030 - ef b5 77 82 48 82 bb 4d-29 34 42 a2 ff 4d 57 e6   ..w.H..M)4B..MW.
    0040 - b7 15 0f e7 80 31 21 9d-d3 2a da ac c6 78 56 17   .....1!..*...xV.
    0050 - 5b e2 a9 4a 23 2b 45 2c-26 f4 39 35 da 1a 4b 7d   [..J#+E,&.95..K}
    0060 - 39 09 84 22 d3 a2 d2 e5-de 2f 81 e2 16 dd 88 9d   9.."...../......
    0070 - 99 7b fb 11 16 ea 2a ae-e2 f9 b5 e8 7e 38 34 78   .{....*.....~84x
    0080 - a8 e6 01 06 49 aa 52 ee-c2 de 3c a9 cb ef c2 e2   ....I.R...<.....
    0090 - 1b 50 97 98 05 9f c8 36-f5 c9 52 8d 72 2a 52 9d   .P.....6..R.r*R.
    00a0 - 7f a3 0d 10 24 ec 00 24-87 fc 51 58 ef ba 6b 2d   ....$..$..QX..k-
    00b0 - ad 2c e9 16 b5 96 ad 20-5d 14 f7 9c 6b f3 46 7e   .,..... ]...k.F~
    00c0 - 70 86 44 61 01 83 5e 5e-f2 85 ec ed 94 9d b9 d3   p.Da..^^........

    Start Time: 1732792777
    Timeout   : 7200 (sec)
    Verify return code: 0 (ok)
    Extended master secret: no
    Max Early Data: 0
---
read R BLOCK
closed
```
