```
az aks update -g $rg -n aks --enable-oidc-issuer
```

```
az aks show -g $rg -n aks --query oidcIssuerProfile -otsv
The behavior of this command has been altered by the following extension: aks-preview
{
  "enabled": true,
  "issuerUrl": "https://westcentralus.oic.prod-aks.azure.com/redactt-1111-1111-1111-111111111111/redacti-1111-1111-1111-111111111111/"
}
```

- https://learn.microsoft.com/en-us/azure/aks/use-oidc-issuer
