```
# https://argo-cd.readthedocs.io/en/stable/
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

```
kubectl get all -n argocd
NAME                                                    READY   STATUS    RESTARTS   AGE
pod/argocd-application-controller-0                     1/1     Running   0          8h
pod/argocd-applicationset-controller-6d65c8999c-4vdwd   1/1     Running   0          8h
pod/argocd-dex-server-69ddcd7d5c-7wvmf                  1/1     Running   0          8h
pod/argocd-notifications-controller-66c774b58d-7xzp8    1/1     Running   0          8h
pod/argocd-redis-7d8d46cc7f-5cd65                       1/1     Running   0          8h
pod/argocd-repo-server-7db5f754d4-qf596                 1/1     Running   0          8h
pod/argocd-server-6fbc544fb5-xxxlr                      1/1     Running   0          8h
NAME                                              TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)
    AGE
service/argocd-applicationset-controller          ClusterIP   10.0.100.138   <none>        7000/TCP,8080/TCP            8h
service/argocd-dex-server                         ClusterIP   10.0.238.158   <none>        5556/TCP,5557/TCP,5558/TCP   8h
service/argocd-metrics                            ClusterIP   10.0.70.10     <none>        8082/TCP
    8h
service/argocd-notifications-controller-metrics   ClusterIP   10.0.61.214    <none>        9001/TCP
    8h
service/argocd-redis                              ClusterIP   10.0.150.135   <none>        6379/TCP
    8h
service/argocd-repo-server                        ClusterIP   10.0.236.7     <none>        8081/TCP,8084/TCP            8h
service/argocd-server                             ClusterIP   10.0.63.32     <none>        80/TCP,443/TCP
    8h
service/argocd-server-metrics                     ClusterIP   10.0.132.221   <none>        8083/TCP
    8h
NAME                                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/argocd-applicationset-controller   1/1     1            1           8h
deployment.apps/argocd-dex-server                  1/1     1            1           8h
deployment.apps/argocd-notifications-controller    1/1     1            1           8h
deployment.apps/argocd-redis                       1/1     1            1           8h
deployment.apps/argocd-repo-server                 1/1     1            1           8h
deployment.apps/argocd-server                      1/1     1            1           8h
NAME                                                          DESIRED   CURRENT   READY   AGE
replicaset.apps/argocd-applicationset-controller-6d65c8999c   1         1         1       8h
replicaset.apps/argocd-dex-server-69ddcd7d5c                  1         1         1       8h
replicaset.apps/argocd-notifications-controller-66c774b58d    1         1         1       8h
replicaset.apps/argocd-redis-7d8d46cc7f                       1         1         1       8h
replicaset.apps/argocd-repo-server-7db5f754d4                 1         1         1       8h
replicaset.apps/argocd-server-6fbc544fb5                      1         1         1       8h
NAME                                             READY   AGE
statefulset.apps/argocd-application-controller   1/1     8h
```

- https://learn.microsoft.com/en-us/azure/architecture/example-scenario/gitops-aks/gitops-blueprint-aks
- https://argo-cd.readthedocs.io/en/stable/
- https://github.com/argoproj/argocd-example-apps
