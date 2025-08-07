
```
# aks.enable-oidc-issuer
az aks create -g $rg -n akswi --enable-oidc-issuer -s $vmsize
# az aks update -g $rg -n aks --enable-oidc-issuer
```

- https://learn.microsoft.com/en-us/azure/aks/use-oidc-issuer

```
# aks.enable-oidc-issuer.more

az aks show -g $rg -n aks --query oidcIssuerProfile -otsv
The behavior of this command has been altered by the following extension: aks-preview
{
  "enabled": true,
  "issuerUrl": "https://westcentralus.oic.prod-aks.azure.com/redactt-1111-1111-1111-111111111111/redacti-1111-1111-1111-111111111111/"
}
```
  
```
# aks.enable-oidc-issuer.openid-configuration
# laptop
curl -v https://westcentralus.oic.prod-aks.azure.com/redactt-1111-1111-1111-111111111111/redacti-1111-1111-1111-111111111111/.well-known/openid-configuration
* Connection #0 to host westcentralus.oic.prod-aks.azure.com left intact
```
- https://learn.microsoft.com/en-us/entra/identity-platform/v2-protocols-oidc: /.well-known/openid-configuration

