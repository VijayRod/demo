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

az aks oidc-issuer rotate-signing-keys -g $rg -n akswork -y
# Be careful that rotate oidc issuer signing keys twice within short period will invalidate service accounts token immediately. Please refer to doc for details.
```

- https://learn.microsoft.com/en-us/azure/aks/use-oidc-issuer
- https://learn.microsoft.com/en-us/cli/azure/aks/oidc-issuer?view=azure-cli-latest
