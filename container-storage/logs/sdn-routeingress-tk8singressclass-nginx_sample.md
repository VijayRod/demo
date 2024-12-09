```
rg=rgnginx
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize
az aks get-credentials -g $rg -n aks --overwrite-existing

NAMESPACE=ingress-basic
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace \
  --namespace $NAMESPACE \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz
kubectl run nginx --image=nginx
kubectl expose po nginx --port=80

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
  rules:
  - http:
      paths:
      - path: /testpath
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
      - path: /(.*)
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
EOF
kubectl get ingress
ip=$(kubectl get ingress -o=jsonpath='{$.items[0].status.loadBalancer.ingress[0].ip}')
echo ip=$ip
curl https://$ip -kI
# HTTP/2 200
```

```
kubectl describe svc -n ingress-basic ingress-nginx-controller | grep -e External -e Health
External Traffic Policy:  Cluster

kubectl patch svc -n ingress-basic ingress-nginx-controller -p '{"spec":{"externalTrafficPolicy":"Local"}}'
kubectl describe svc -n ingress-basic ingress-nginx-controller | grep -e External -e Health
External Traffic Policy:  Local
HealthCheck NodePort:     30003

kubectl get deploy -n ingress-basic ingress-nginx-controller
kubectl patch deploy -n ingress-basic ingress-nginx-controller -p '{"spec":{"replicas":"3"}}'
kubectl get po -n ingress-basic -owide
```
