```
oidcUri=$(az aks show -g $rg -n aks --query oidcIssuerProfile.issuerUrl -otsv)

az identity create -g $rg -n identity
clientId=$(az identity show -g $rg -n identity --query clientId -otsv)

serviceaccount=workload-identity-sa
serviceaccountns=default

echo $oidcUri $clientId $serviceaccountns:$serviceaccount

az aks get-credentials -g $rg -n aks
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: "$clientId"
  name: "$serviceaccount"
  namespace: "$serviceaccountns"
EOF

az identity federated-credential create -g $rg --identity-name identity -n fedidentity --issuer $oidcUri --subject system:serviceaccount:"$serviceaccountns":"$serviceaccount" --audience api://AzureADTokenExchange
date
sleep 120

kubectl delete po nginx
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  namespace: "$serviceaccountns" # note
  labels:
    azure.workload.identity/use: "true" # note
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  serviceAccountName: "$serviceaccount" # note
EOF
sleep 10
kubectl get po nginx
```

```
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          7m20s

kubectl describe po nginx
Containers:
  nginx:
    Environment:
      AZURE_CLIENT_ID:             redactc-1111-1111-1111-111111111111
      AZURE_TENANT_ID:             redactt-1111-1111-1111-111111111111
      AZURE_FEDERATED_TOKEN_FILE:  /var/run/secrets/azure/tokens/azure-identity-token
      AZURE_AUTHORITY_HOST:        https://login.microsoftonline.com/
    Mounts:
      /var/run/secrets/azure/tokens from azure-identity-token (ro)
Volumes:
  azure-identity-token:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3600
    
TBD kubectl logs nginx
```

- https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster#retrieve-the-oidc-issuer-url
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#serviceaccount-token-volume-projection
