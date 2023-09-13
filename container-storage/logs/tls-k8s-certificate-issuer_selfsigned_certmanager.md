TBD

```
# To install
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade cert-manager jetstack/cert-manager \
    --install \
    --create-namespace \
    --wait \
    --namespace cert-manager \
    --set installCRDs=true
kubectl get all -n cert-manager

cat << EOF | kubectl create -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: www
spec:
  secretName: www-tls
  privateKey:
    rotationPolicy: Always
  commonName: www.$DOMAIN_NAME
  dnsNames:
    - www.$DOMAIN_NAME
  usages:
    - digital signature
    - key encipherment
    - server auth
  issuerRef:
    name: selfsigned
    kind: ClusterIssuer
EOF
kubectl get clusterissuer selfsigned
kubectl get certificate www
```

```
# kubectl get clusterissuer selfsigned
NAME         READY   AGE
selfsigned   True    0s

# kubectl get certificate www
NAME   READY   SECRET    AGE
www    True    www-tls   0s
```

```
# To cleanup
helm uninstall cert-manager --namespace cert-manager
kubectl delete certificate www
kubectl delete clusterissuer selfsigned
```

- https://cert-manager.io/docs/troubleshooting/    
- https://cert-manager.io/docs/tutorials/getting-started-aks-letsencrypt/
