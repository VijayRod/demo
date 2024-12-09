## key.ec

```
# create
openssl ecparam -name prime256v1 -genkey -out ec_private.key # Generate an EC key using a specific curve
openssl ecparam -name secp384r1 -param_enc explicit -genkey -out ec_private_explicit.key # Generate an EC key with explicit parameters
openssl ecparam -list_curves # List all available EC curves

cat ec_private.key
-----BEGIN EC PARAMETERS-----
BredactedBw==
-----END EC PARAMETERS-----
-----BEGIN EC PRIVATE KEY-----
MHcredacted1
Awredacted2
3redacted3gw==
-----END EC PRIVATE KEY-----

# import.keyvault
# Use the Azure portal to create a key in the key vault
tbd az keyvault key import --vault-name $keyvault -n ecprivate --byok-file /tmp/ec_private.key --kty EC --curve P-256
```

- https://www.golinuxcloud.com/openssl-cheatsheet/
