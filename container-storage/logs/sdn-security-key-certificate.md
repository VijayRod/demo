## key.certificate

```
# See the section on openssl certificate, k8s certificate and key vault certificate
# curl -v https://$albUrl
# openssl s_client -connect f989246f5c8f43179b0bd73c36268aaf.alb.azure.com:443 -showcerts

# certificate.self-signed
openssl genpkey -algorithm RSA -out mykey.pem
openssl req -new -key mykey.pem -out mycsr.csr -subj "/C=US/ST=State/L=City/O=Organization/OU=Department/CN=www.example.com"
openssl x509 -req -days 365 -in mycsr.csr -signkey mykey.pem -out cert.pem
cat mycsr.csr
```

- https://www.golinuxcloud.com/openssl-cheatsheet/: Creating Certificates, Checking and Verifying Certificates, Check certificate content
