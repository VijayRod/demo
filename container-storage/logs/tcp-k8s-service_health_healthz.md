```
kubectl run nginx --image=nginx
kubectl expose po nginx --port=80 --type=LoadBalancer
kubectl patch svc nginx -p '{"spec":{"externalTrafficPolicy":"Local"}}' # Changing externalTrafficPolicy from 'cluster' (default)
kubectl get svc nginx
kubectl describe svc nginx | grep HealthCheck
```

```
HealthCheck NodePort:     31805

kubectl get po nginx -owide
NAME    READY   STATUS    RESTARTS   AGE     IP            NODE                              NOMINATED NODE   READINESS GATES
nginx   1/1     Running   0          2m23s   10.244.0.14   aks-default-24553791-vmss000002   <none>           <none>

root@aks-default-24553791-vmss000002:/# curl localhost:31805/healthz
{
        "service": {
                "namespace": "default",
                "name": "nginx"
        },
        "localEndpoints": 1
}

root@aks-default-24553791-vmss000002:/# tcpdump port 31805
23:34:31.230546 IP 168.63.129.16.61387 > aks-default-24553791-vmss000002.internal.cloudapp.net.31805: Flags [P.], seq 3693174295:3693174486, ack 3340588824, win 49151, length 191
23:34:31.230756 IP aks-default-24553791-vmss000002.internal.cloudapp.net.31805 > 168.63.129.16.61387: Flags [P.], seq 1:228, ack 191, win 501, length 227
23:34:31.245904 IP 168.63.129.16.61387 > aks-default-24553791-vmss000002.internal.cloudapp.net.31805: Flags [.], ack 228, win 49150, length 0
```

- https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#external-load-balancer-providers
- https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip: service.spec.healthCheckNodePort
- https://kubernetes.io/docs/tutorials/services/source-ip/#source-ip-for-services-with-type-loadbalancer
