```
kubectl describe pod quick-start | grep token
      AZURE_FEDERATED_TOKEN_FILE:  /var/run/secrets/azure/tokens/azure-identity-token
```

```
# kubectl get sa workload-identity-sa
kubectl create token workload-identity-sa
```

```
# token=ey... decoded in jwt.io
# For a public cluster, the token's audience (aud) field includes the cluster's OpenID Connect (OIDC) Issuer Profile's issuer URL (oidcIssuerProfile.issuerUrl) and the cluster's fully qualified domain name (fqdn).
# For a private cluster, the audience field additionally includes the private fully qualified domain name (privateFqdn), in addition to the OIDC Issuer Profile's issuer URL and public fqdn.
{
  "aud": [
    "https://westcentralus.oic.prod-aks.azure.com/redactt-1111-1111-1111-111111111111/redacti-1111-1111-1111-111111111111/",
    "https://akswork-rg-111111-abcd11ef.hcp.westcentralus.azmk8s.io",
    "\"akswork-rg-111111-abcd11ef.hcp.westcentralus.azmk8s.io\""
  ],
  "exp": 1698686109,
  "iat": 1698682509,
  "iss": "https://westcentralus.oic.prod-aks.azure.com/redactt-1111-1111-1111-111111111111/redacti-1111-1111-1111-111111111111/",
  "kubernetes.io": {
    "namespace": "default",
    "serviceaccount": {
      "name": "workload-identity-sa",
      "uid": "redactuid-1111-1111-1111-111111111111"
    }
  },
  "nbf": 1698682509,
  "sub": "system:serviceaccount:default:workload-identity-sa"
}
```
