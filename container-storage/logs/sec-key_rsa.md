## key.rsa

```
# rsa
openssl genrsa -out rsa_private.key 2048 # Generate a standard RSA key (2048 bits)
openssl genrsa -out rsa_private.key 4096 # Generate a stronger RSA key (4096 bits)
openssl genrsa -out rsa_private.key 2048 -F4 # Generate an RSA key with a custom exponent

cat rsa_private.key
-----BEGIN PRIVATE KEY-----
MIIEredacated
redacated
redacatedLc
-----END PRIVATE KEY-----

# rsa.keyvault
# Use the Azure portal to create a key in the key vault
```

- https://www.golinuxcloud.com/openssl-cheatsheet/
