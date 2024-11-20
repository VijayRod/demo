## key.certificate

```
# See the section on openssl certificate, k8s certificate and key vault certificate

# certificate.self-signed
openssl genpkey -algorithm RSA -out mykey.pem
openssl req -new -key mykey.pem -out mycsr.csr -subj "/C=US/ST=State/L=City/O=Organization/OU=Department/CN=www.example.com"
openssl x509 -req -days 365 -in mycsr.csr -signkey mykey.pem -out cert.pem
cat mycsr.csr
```

- https://www.golinuxcloud.com/openssl-cheatsheet/: Creating Certificates, Checking and Verifying Certificates, Check certificate content
