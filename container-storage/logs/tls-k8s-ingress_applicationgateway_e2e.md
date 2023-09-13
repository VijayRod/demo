```
# Prerequisite: AKS cluster with -a ingress-appgw
mkdir /tmp/tls
cd /tmp/tls
rm *
ls

openssl ecparam -out frontend.key -name prime256v1 -genkey
openssl req -new -sha256 -key frontend.key -out frontend.csr -subj "/CN=frontend"
openssl x509 -req -sha256 -days 365 -in frontend.csr -signkey frontend.key -out frontend.crt
ls
# frontend.crt  frontend.csr  frontend.key

openssl ecparam -out backend.key -name prime256v1 -genkey
openssl req -new -sha256 -key backend.key -out backend.csr -subj "/CN=backend"
openssl x509 -req -sha256 -days 365 -in backend.csr -signkey backend.key -out backend.crt
ls
# backend.crt  backend.csr  backend.key  frontend.crt  frontend.csr  frontend.key

kubectl create secret tls frontend-tls --key="frontend.key" --cert="frontend.crt"
kubectl create secret tls backend-tls --key="backend.key" --cert="backend.crt"
kubectl get secrets

kubectl apply -f https://raw.githubusercontent.com/Azure/application-gateway-kubernetes-ingress/master/docs/examples/sample-https-backend.yaml
kubectl get po

# kubectl exec -it website-deployment-5c49d597ff-62hld -- curl -k https://localhost:8443
# Hello World!

# kubectl exec -it website-deployment-5c49d597ff-62hld -- curl -vk https://localhost:8443
* Server certificate:
*  subject: CN=backend
*  issuer: CN=backend
*  SSL certificate verify result: self-signed certificate (18), continuing anyway.
```

```
applicationGatewayName="myApplicationGateway"
resourceGroup="MC_myResourceGroup_myCluster_eastus"
az network application-gateway root-cert create \
    --gateway-name $applicationGatewayName  \
    --resource-group $resourceGroup \
    --name backend-tls \
    --cert-file backend.crt
    
cat << EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: website-ingress
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway
    appgw.ingress.kubernetes.io/ssl-redirect: "true"
    appgw.ingress.kubernetes.io/backend-protocol: "https"
    appgw.ingress.kubernetes.io/backend-hostname: "backend"
    appgw.ingress.kubernetes.io/appgw-trusted-root-certificate: "backend-tls"
spec:
  tls:
    - secretName: frontend-tls
      hosts:
        - website.com
  rules:
    - host: website.com
      http:
        paths:
        - path: /
          backend:
            service:
              name: website-service
              port:
                number: 8443
          pathType: Exact
EOF
kubectl get ingress

TBD
curl -k -H "Host: website.com" https://<gateway-ip>
*   Trying 4.157.173.247:443...

TBD
curl http://website.com --resolve website.com:443:4.157.173.247 -k -I
HTTP/1.1 403 Forbidden
Server: cloudflare
```

- https://azure.github.io/application-gateway-kubernetes-ingress/tutorials/tutorial.e2e-ssl/
