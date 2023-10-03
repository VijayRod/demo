```
kubectl create ns osm-dev
osm namespace add osm-dev
kubectl describe ns osm-dev
Name:         osm-dev
Labels:       kubernetes.io/metadata.name=osm-dev
              openservicemesh.io/monitored-by=osm
Annotations:  openservicemesh.io/sidecar-injection: enabled

kubectl run -n osm-dev nginx --image=nginx
sleep 20
kubectl get po -n osm-dev nginx
NAME    READY   STATUS    RESTARTS   AGE
nginx   2/2     Running   0          20s

kubectl describe po -n osm-dev nginx
Image:         mcr.microsoft.com/oss/envoyproxy/envoy:v1.26.4
```

```
TBD
kubectl create ns osm-test
kubectl annotate ns osm-test openservicemesh.io/sidecar-injection=enabled
kubectl run -n osm-test nginx --image=nginx
sleep 10
kubectl get po -n osm-test nginx
kubectl annotate pod -n osm-test nginx openservicemesh.io/sidecar-injection=enabled
```

- https://release-v1-0.docs.openservicemesh.io/docs/guides/app_onboarding/sidecar_injection/
