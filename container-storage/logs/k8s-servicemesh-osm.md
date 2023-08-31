```
rg=rg2
az group create -g $rg -l swedencentral
az aks create -g $rg -n aksmesh -a open-service-mesh
az aks get-credentials -g $rg -n aksmesh --overwrite-existing
```

```
az aks show -g $rg -n aksmesh --query 'addonProfiles.openServiceMesh'

{
  "config": null,
  "enabled": true,
  "identity": null
}

kubectl get deployment -n kube-system osm-controller -o=jsonpath='{$.spec.template.spec.containers[:1].image}'

mcr.microsoft.com/oss/openservicemesh/osm-controller:v1.2.5

kubectl get all -n kube-system -l app.kubernetes.io/name=openservicemesh.io

NAME                                  READY   STATUS    RESTARTS   AGE
pod/osm-bootstrap-bc499b769-qhwj6     1/1     Running   0          2m34s
pod/osm-controller-7f8f76cb48-2nlf2   1/1     Running   0          2m21s
pod/osm-controller-7f8f76cb48-q2wzs   1/1     Running   0          2m34s
pod/osm-injector-78b9c59677-5ff7p     1/1     Running   0          2m34s
pod/osm-injector-78b9c59677-twtc2     1/1     Running   0          2m21s

NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                       AGE
service/osm-bootstrap    ClusterIP   10.0.251.236   <none>        9443/TCP,9091/TCP             2m35s
service/osm-controller   ClusterIP   10.0.81.131    <none>        15128/TCP,9092/TCP,9091/TCP   2m35s
service/osm-injector     ClusterIP   10.0.93.13     <none>        9090/TCP                      2m35s
service/osm-validator    ClusterIP   10.0.60.224    <none>        9093/TCP                      2m35s

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/osm-bootstrap    1/1     1            1           2m35s
deployment.apps/osm-controller   2/2     2            2           2m35s
deployment.apps/osm-injector     2/2     2            2           2m35s

NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/osm-bootstrap-bc499b769     1         1         1       2m35s
replicaset.apps/osm-controller-7f8f76cb48   2         2         2       2m35s
replicaset.apps/osm-injector-78b9c59677     2         2         2       2m35s

NAME                                                     REFERENCE                   TARGETS
MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/osm-controller-hpa   Deployment/osm-controller   <unknown>/80%, <unknown>/80%   2         5         2          2m37s
horizontalpodautoscaler.autoscaling/osm-injector-hpa     Deployment/osm-injector     <unknown>/80%                  2         10        2          2m37s
```
    
- https://learn.microsoft.com/en-us/azure/aks/open-service-mesh-about
- https://learn.microsoft.com/en-us/azure/aks/open-service-mesh-deploy-addon-az-cli
- https://learn.microsoft.com/en-us/azure/aks/open-service-mesh-troubleshoot
- https://docs.openservicemesh.io/
