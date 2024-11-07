```
# To deploy cert-manager which automatically generates and configures Let's Encrypt certificates.
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml
```

```
# kubectl get all -n cert-manager
NAME                                           READY   STATUS    RESTARTS   AGE
pod/cert-manager-655c4cf99d-xpsmk              1/1     Running   0          2m40s
pod/cert-manager-cainjector-845856c584-drphb   1/1     Running   0          2m40s
pod/cert-manager-webhook-57876b9fd-jhzbd       1/1     Running   0          2m40s
NAME                           TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
service/cert-manager           ClusterIP   10.0.2.20     <none>        9402/TCP   2m41s
service/cert-manager-webhook   ClusterIP   10.0.33.173   <none>        443/TCP    2m41s
NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cert-manager              1/1     1            1           2m40s
deployment.apps/cert-manager-cainjector   1/1     1            1           2m40s
deployment.apps/cert-manager-webhook      1/1     1            1           2m40s
NAME                                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/cert-manager-655c4cf99d              1         1         1       2m40s
replicaset.apps/cert-manager-cainjector-845856c584   1         1         1       2m40s
replicaset.apps/cert-manager-webhook-57876b9fd       1         1         1       2m40s

# kubectl get Issuers,ClusterIssuers,Certificates,CertificateRequests,Orders,Challenges --all-namespaces
No resources found
```

```
# To cleanup
# https://cert-manager.io/docs/installation/kubectl/#uninstalling
kubectl get Issuers,ClusterIssuers,Certificates,CertificateRequests,Orders,Challenges --all-namespaces
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/vX.Y.Z/cert-manager.yaml
```

- https://learn.microsoft.com/en-us/azure/aks/ingress-tls: To use TLS with Let's Encrypt certificates, you'll deploy cert-manager, which automatically generates and configures Let's Encrypt certificates.
- https://github.com/cert-manager/cert-manager
- https://cert-manager.io/docs/installation/: kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml
