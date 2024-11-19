```
rg=rgtls
cert=cert
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize
az aks get-credentials -g $rg -n aks --overwrite-existing

# https://learn.microsoft.com/en-us/azure/aks/ingress-basic?tabs=azure-cli#basic-configuration
NAMESPACE=ingress-basic
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace \
  --namespace $NAMESPACE \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz

kubectl run nginx --image=nginx
kubectl expose po nginx --port=80

# https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-nginx-tls#generate-a-tls-certificate
mkdir /tmp/tls
cd /tmp/tls
rm *
ls
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $cert.pem -out $cert.crt -subj "/CN=https-example.foo.com/O=aks-ingress-tls" # self-signed root cert. host=CN
# cert.crt  cert.pem

kubectl create secret tls $cert --key $cert.pem --cert $cert.crt
kubectl get secret $cert # TYPE=kubernetes.io/tls
# kubectl describe secret $cert

kubectl delete ingress minimal-ingress
cat << EOF | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minimal-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  tls:
  - hosts:
      - https-example.foo.com # host=CN
    secretName: $cert
  rules:
  - host: https-example.foo.com # host=CN
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
EOF
kubectl get ingress minimal-ingress # PORTS 80, 443
```

```
NAME              CLASS   HOSTS                   ADDRESS        PORTS     AGE
minimal-ingress   nginx   https-example.foo.com   4.225.64.204   80, 443   65s

root@aks-nodepool1-17429108-vmss000000:/# curl https://https-example.foo.com --resolve https-example.foo.com:443:4.225.64.204 -kI
HTTP/2 200

root@aks-nodepool1-17429108-vmss000000:/# curl https://https-example.foo.com --resolve https-example.foo.com:443:4.225.64.204 -kIv
* Server certificate:
*  subject: CN=https-example.foo.com; O=aks-ingress-tls
*  issuer: CN=https-example.foo.com; O=aks-ingress-tls
*  SSL certificate verify result: self-signed certificate (18), continuing anyway.

root@aks-nodepool1-17429108-vmss000000:/# curl http://https-example.foo.com --resolve https-example.foo.com:80:4.225.64.204 -I
HTTP/1.1 308 Permanent Redirect
Location: https://https-example.foo.com

# ingress.finalizers
kubectl get svc -n ingress-basic ingress-nginx-controller -oyaml
metadata:
  finalizers:
  - service.kubernetes.io/load-balancer-cleanup

kubectl delete secret $cert
kubectl get ingress minimal-ingress
```

- https://kubernetes.io/docs/concepts/services-networking/ingress/#tls
- https://kubernetes.github.io/ingress-nginx/user-guide/tls/
- https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-nginx-tls#generate-a-tls-certificate
- https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-nginx-tls#test-ingress-secured-with-tls
