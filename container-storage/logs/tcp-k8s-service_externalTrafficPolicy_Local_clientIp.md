```
kubectl run nginx --image=nginx
kubectl expose po nginx --port=80 --type=LoadBalancer
```

```
kubectl get svc nginx
NAME    TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)        AGE
nginx   LoadBalancer   10.0.133.89   98.64.130.31   80:30295/TCP   15m

kubectl describe svc nginx | grep external -i
External Traffic Policy:  Cluster

curl 98.64.130.31 -I
HTTP/1.1 200 OK

kubectl logs nginx | tail # IP not in the virtual network
10.244.0.1 - - [12/Sep/2023:12:10:55 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.68.0" "-"

kubectl patch svc nginx -p '{"spec":{"externalTrafficPolicy":"Local"}}'

curl 98.64.130.31 -I
HTTP/1.1 200 OK

kubectl logs nginx | tail # Client IP
<clientIpRedacted> - - [12/Sep/2023:12:11:44 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.68.0" "-"
```

- https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
- https://kubernetes.io/docs/tutorials/services/source-ip/#source-ip-for-services-with-typeloadbalancer
