The Ingress resource must be in the same namespace as the backend service. Once it is created, it will have the external IP of the Ingress controller.

```
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
