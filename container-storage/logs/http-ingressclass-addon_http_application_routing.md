```
# Replace the below with appropriate values
rgname=
clustername=akshttp
```

```
# To create a cluster
az aks create -g $rgname -n $clustername --enable-addons http_application_routing
```

```
# az aks show -g $rgname -n $clustername --query addonProfiles.httpApplicationRouting
{
  "config": {
    "HTTPApplicationRoutingZoneName": "510f076342174b529387.swedencentral.aksapp.io"
  },
  "enabled": true,
  "identity": {
    "clientId": "dummyc11-a492-4575-bf6d-dc9c0536770c",
    "objectId": "dummyo11-8955-477b-aa86-ed61cc98790d",
    "resourceId": "/subscriptions/dummys-1111-1111-1111-111111111111/resourcegroups/MC_secureshack2_akshttp_swedencentral/providers/Microsoft.ManagedIdentity/userAssignedIdentities/httpapplicationrouting-akshttp"
  }
}

# az aks get-credentials -g $rgname -n $clustername
# kubectl get po -n kube-system | grep http
addon-http-application-routing-external-dns-57bd75cf69-pfkql      1/1     Running   0          3m48s
addon-http-application-routing-nginx-ingress-controller-5bzh5xj   1/1     Running   0          3m48s

# nslookup 510f076342174b529387.swedencentral.aksapp.io
*** Can't find 510f076342174b529387.swedencentral.aksapp.io: No answer
```

```
# kubectl get ingress. This is after deploying the ingress.
NAME             CLASS    HOSTS                                                         ADDRESS         PORTS   AGE
aks-helloworld   <none>   aks-helloworld.510f076342174b529387.swedencentral.aksapp.io   20.240.20.241   80      12m

# kubectl get ingress aks-helloworld -oyaml | grep class
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":...
    kubernetes.io/ingress.class: addon-http-application-routing
    
# curl aks-helloworld.510f076342174b529387.swedencentral.aksapp.io | grep DOC
<!DOCTYPE html>

# nslookup aks-helloworld.510f076342174b529387.swedencentral.aksapp.io
Name:   aks-helloworld.510f076342174b529387.swedencentral.aksapp.io
Address: 20.240.20.241
```

```
# kubectl logs -f deploy/addon-http-application-routing-external-dns -n kube-system
time="2023-08-03T14:32:14Z" level=info msg="Updating A record named 'aks-helloworld' to '20.240.20.241' for Azure DNS zone '510f076342174b529387.swedencentral.aksapp.io'."
time="2023-08-03T14:32:15Z" level=info msg="Updating TXT record named 'aks-helloworld' to '\"heritage=external-dns,external-dns/owner=default,external-dns/resource=ingress/default/aks-helloworld\"' for Azure DNS zone '510f076342174b529387.swedencentral.aksapp.io'."
time="2023-08-03T14:35:15Z" level=info msg="All records are already up to date"

# kubectl logs -f deploy/addon-http-application-routing-nginx-ingress-controller -n kube-system
I0803 14:32:00.027587       8 store.go:429] "Found valid IngressClass" ingress="default/aks-helloworld" ingressclass="addon-http-application-routing"
I0803 14:32:00.027975       8 controller.go:167] "Configuration changes detected, backend reload required"
I0803 14:32:00.028469       8 event.go:285] Event(v1.ObjectReference{Kind:"Ingress", Namespace:"default", Name:"aks-helloworld", UID:"4a6eafdb-cedb-412d-b10a-7a827210f8e9", APIVersion:"networking.k8s.io/v1", ResourceVersion:"3744", FieldPath:""}): type: 'Normal' reason: 'Sync' Scheduled for sync
I0803 14:32:00.087755       8 controller.go:184] "Backend successfully reloaded"
I0803 14:32:00.088635       8 event.go:285] Event(v1.ObjectReference{Kind:"Pod", Namespace:"kube-system", Name:"addon-http-application-routing-nginx-ingress-controller-5bzh5xj", UID:"be3a12a9-7920-4a8e-a383-7931b784649d", APIVersion:"v1", ResourceVersion:"1406", FieldPath:""}): type: 'Normal' reason: 'RELOAD' NGINX reload triggered due to a change in configuration
I0803 14:32:08.878022       8 status.go:299] "updating Ingress status" namespace="default" ingress="aks-helloworld" currentValue=[] newValue=[{IP:20.240.20.241 Hostname: Ports:[]}]
I0803 14:32:08.883483       8 event.go:285] Event(v1.ObjectReference{Kind:"Ingress", Namespace:"default", Name:"aks-helloworld", UID:"4a6eafdb-cedb-412d-b10a-7a827210f8e9", APIVersion:"networking.k8s.io/v1", ResourceVersion:"3784", FieldPath:""}): type: 'Normal' reason: 'Sync' Scheduled for sync
148.71.95.5 - - [03/Aug/2023:14:36:06 +0000] "GET / HTTP/1.1" 200 629 "-" "curl/7.68.0" 123 0.019 [default-aks-helloworld-80] [] 10.244.2.3:80 629 0.020 200 73325e727a9513dfcdbbe321042a2d59
```

- https://learn.microsoft.com/en-us/azure/aks/http-application-routing
