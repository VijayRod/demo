```
kubectl get all
NAME                                READY   STATUS    RESTARTS   AGE
pod/fiopod                          1/1     Running   0          9h
pod/guestbook-ui-754d46fbf6-jzhfr   1/1     Running   0          33s
NAME                   TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/guestbook-ui   ClusterIP   10.0.43.3    <none>        80/TCP    33s
service/kubernetes     ClusterIP   10.0.0.1     <none>        443/TCP   10h
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/guestbook-ui   1/1     1            1           33s
NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/guestbook-ui-754d46fbf6   1         1         1       33s
```

- https://techcommunity.microsoft.com/t5/apps-on-azure-blog/getting-started-with-gitops-argo-and-azure-kubernetes-service/ba-p/3288595
- https://github.com/argoproj/argocd-example-apps/tree/master/guestbook
