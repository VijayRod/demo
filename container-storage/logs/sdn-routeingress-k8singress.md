The Ingress resource must be in the same namespace as the backend service. Once it is created, it will have the external IP of the Ingress controller.

```
rg=rgingress
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s Standard_B2ms -c 1
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
```

```
# kubectl get ingressclass
NAME    CONTROLLER             PARAMETERS   AGE
nginx   k8s.io/ingress-nginx   <none>       145m

# kubectl get svc -l app.kubernetes.io/name=ingress-nginx -A
NAMESPACE       NAME                                 TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)             AGE
ingress-basic   ingress-nginx-controller             LoadBalancer   10.0.233.214   20.240.181.142   80:32279/TCP,443:30111/TCP   145m

# kubectl get ing
NAME              CLASS     HOSTS              ADDRESS          PORTS     AGE
minimal-ingress   nginx     *                  20.240.181.142   80        8m48s

# kubectl describe ing
Name:             minimal-ingress
Rules:
  Host        Path  Backends
  ----        ----  --------
  *
              /testpath   nginx:80 (10.244.0.37:80)
              /(.*)       nginx:80 (10.244.0.37:80)
```              

```
# curl 20.240.181.142 -I
HTTP/1.1 200 OK
         
# curl 20.240.181.142 | grep DOC
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>

# curl 20.240.181.142/testpath
<!DOCTYPE html>

# root@aks-nodepool1-51397738-vmss00000Z:/# curl 20.240.181.142
<!DOCTYPE html>

# root@aks-nodepool1-51397738-vmss00000Z:/# curl 20.240.181.142/testpath
<!DOCTYPE html>

# root@aks-nodepool1-51397738-vmss00000Z:/# curl 10.244.0.37:80
<!DOCTYPE html>
```

```
# To cleanup
kubectl delete ingress minimal-ingress
kubectl delete svc nginx
kubectl delete po nginx
```

- https://kubernetes.io/docs/concepts/services-networking/ingress/
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connection-issues-application-hosted-aks-cluster
- https://github.com/kubernetes/ingress-nginx/blob/main/docs/troubleshooting.md
- https://www.tkng.io/ingress/
