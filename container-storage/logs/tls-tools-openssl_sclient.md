```
fqdn=stackoverflow.com
openssl s_client -connect $fqdn:443 -prexit
TBD openssl s_client -connect $fqdn:443 -tls1_2 -status -msg -debug -CAfile <path to trusted root ca pem> -key <path to client private key pem> -cert <path to client cert pem> # -tlsextdebug -prexit -state
openssl s_client -showcerts -connect $fqdn:443 < /dev/null # Add an End-of-Line (EOL) character to the STDIN to prevent hanging on the terminal
```

- https://www.openssl.org/docs/man1.0.2/man1/s_client.html
