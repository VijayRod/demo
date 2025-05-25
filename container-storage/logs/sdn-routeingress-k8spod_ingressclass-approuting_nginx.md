```
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aksapproute --enable-app-routing -s $vmsize
az aks get-credentials -g $rg -n aksapproute --overwrite-existing
```

- https://learn.microsoft.com/en-us/azure/aks/app-routing
- https://github.com/Azure/aks-app-routing-operator/blob/main/pkg/manifests/nginx.go

```
k get po -n app-routing-system -l app.kubernetes.io/component=ingress-controller -owide -w
nginx-7f6784b4b5-5bn7s   1/1     Running   0          5m26s
nginx-7f6784b4b5-rjkm4   1/1     Running   0          5m41s

kubectl describe po -n app-routing-system -l app=nginx | grep Image
    Image:         mcr.microsoft.com/oss/kubernetes/ingress/nginx-ingress-controller:v1.11.2
```
- https://kubernetes.github.io/ingress-nginx/
- https://github.com/kubernetes/ingress-nginx

```
kubectl get all -n app-routing-system --show-labels
NAME                         READY   STATUS    RESTARTS   AGE     LABELS
pod/nginx-7cd7f56848-7gxz6   1/1     Running   0          3m22s   app.kubernetes.io/component=ingress-controller,app.kubernetes.io/managed-by=aks-app-routing-operator,app=nginx,pod-template-hash=7cd7f56848
pod/nginx-7cd7f56848-fcvv7   1/1     Running   0          3m7s    app.kubernetes.io/component=ingress-controller,app.kubernetes.io/managed-by=aks-app-routing-operator,app=nginx,pod-template-hash=7cd7f56848
NAME            TYPE           CLUSTER-IP   EXTERNAL-IP     PORT(S)                                      AGE     LABELS
service/nginx   LoadBalancer   10.0.45.15   74.241.234.56   80:31507/TCP,443:31149/TCP,10254:32578/TCP   3m22s   app.kubernetes.io/component=ingress-controller,app.kubernetes.io/managed-by=aks-app-routing-operator,app.kubernetes.io/name=nginx
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE     LABELS
deployment.apps/nginx   2/2     2            2           3m22s   app.kubernetes.io/component=ingress-controller,app.kubernetes.io/managed-by=aks-app-routing-operator,app.kubernetes.io/name=nginx
NAME                               DESIRED   CURRENT   READY   AGE     LABELS
replicaset.apps/nginx-7cd7f56848   2         2         2       3m22s   app.kubernetes.io/component=ingress-controller,app.kubernetes.io/managed-by=aks-app-routing-operator,app=nginx,pod-template-hash=7cd7f56848
NAME                                        REFERENCE          TARGETS   MINPODS   MAXPODS   REPLICAS   AGE     LABELS
horizontalpodautoscaler.autoscaling/nginx   Deployment/nginx   0%/80%    2         100       2          3m23s   app.kubernetes.io/component=ingress-controller,app.kubernetes.io/managed-by=aks-app-routing-operator,app.kubernetes.io/name=nginx

kubectl logs -n app-routing-system -l app=nginx
I0902 18:19:22.817080       7 nginx.go:271] "Starting NGINX Ingress controller"
I0902 18:19:22.823417       7 event.go:377] Event(v1.ObjectReference{Kind:"ConfigMap", Namespace:"app-routing-system", Name:"nginx", UID:"b7c58f7d-c840-449e-a023-148feb78bc4b", APIVersion:"v1", ResourceVersion:"842", FieldPath:""}): type: 'Normal' reason: 'CREATE' ConfigMap app-routing-system/nginx
I0902 18:19:24.019111       7 nginx.go:317] "Starting NGINX process"
I0902 18:19:24.019279       7 leaderelection.go:250] attempting to acquire leader lease app-routing-system/nginx...
I0902 18:19:24.019595       7 controller.go:193] "Configuration changes detected, backend reload required"
I0902 18:19:24.048664       7 controller.go:213] "Backend successfully reloaded"
I0902 18:19:24.048863       7 controller.go:224] "Initial sync, sleeping for 1 second"
I0902 18:19:24.049100       7 event.go:377] Event(v1.ObjectReference{Kind:"Pod", Namespace:"app-routing-system", Name:"nginx-7cd7f56848-fcvv7", UID:"d1f3d035-a5d2-4792-a90e-871c26177ae5", APIVersion:"v1", ResourceVersion:"1169", FieldPath:""}): type: 'Normal' reason: 'RELOAD' NGINX reload triggered due to a change in configuration
I0902 18:19:24.049395       7 leaderelection.go:260] successfully acquired lease app-routing-system/nginx
I0902 18:19:24.049516       7 status.go:85] "New leader elected" identity="nginx-7cd7f56848-fcvv7"

k exec -it -n app-routing-system nginx-7f6784b4b5-rjkm4 -- cat /etc/nginx/nginx.conf

k describe crd nginxingresscontrollers.approuting.kubernetes.azure.com

k get po -A | grep nginx
k delete po --all -n app-routing-system; sleep 5
```

```
# ing.approuting.nginx.example.minimal

k delete ing aks-helloworld
cat << EOF | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: aks-helloworld
spec:
  ingressClassName: webapprouting.kubernetes.azure.com
  rules:
  - 
    http:
      paths:
      - backend:
          service:
            name: aks-helloworld
            port:
              number: 80
        path: /
        pathType: Prefix
EOF
date
sleep 60

# ing.create
k logs -n app-routing-system -l app.kubernetes.io/component=ingress-controller -f
I0523 18:03:26.856629       7 store.go:440] "Found valid IngressClass" ingress="default/aks-helloworld" ingressclass="webapprouting.kubernetes.azure.com"
I0523 18:03:26.856921       7 event.go:377] Event(v1.ObjectReference{Kind:"Ingress", Namespace:"default", Name:"aks-helloworld", UID:"5ed6ac11-f55b-4c63-aca2-58d5caa22960", APIVersion:"networking.k8s.io/v1", ResourceVersion:"126664", FieldPath:""}): type: 'Normal' reason: 'Sync' Scheduled for sync
W0523 18:03:26.857151       7 controller.go:1114] Error obtaining Endpoints for Service "default/aks-helloworld": no object matching key "default/aks-helloworld" in local store
I0523 18:03:26.857204       7 controller.go:193] "Configuration changes detected, backend reload required"
I0523 18:03:26.856996       7 store.go:440] "Found valid IngressClass" ingress="default/aks-helloworld" ingressclass="webapprouting.kubernetes.azure.com"
W0523 18:03:26.857251       7 controller.go:1114] Error obtaining Endpoints for Service "default/aks-helloworld": no object matching key "default/aks-helloworld" in local store
I0523 18:03:26.857304       7 controller.go:193] "Configuration changes detected, backend reload required"
I0523 18:03:26.857907       7 event.go:377] Event(v1.ObjectReference{Kind:"Ingress", Namespace:"default", Name:"aks-helloworld", UID:"5ed6ac11-f55b-4c63-aca2-58d5caa22960", APIVersion:"networking.k8s.io/v1", ResourceVersion:"126664", FieldPath:""}): type: 'Normal' reason: 'Sync' Scheduled for sync
I0523 18:03:26.904152       7 controller.go:213] "Backend successfully reloaded"

I0523 18:03:26.904447       7 event.go:377] Event(v1.ObjectReference{Kind:"Pod", Namespace:"app-routing-system", Name:"nginx-7f6784b4b5-5bn7s", UID:"d65eadc8-9e9b-42ad-aac8-acc2e79597ad", APIVersion:"v1", ResourceVersion:"1389", FieldPath:""}): type: 'Normal' reason: 'RELOAD' NGINX reload triggered due to a change in configuration
I0523 18:03:26.901035       7 controller.go:213] "Backend successfully reloaded"
I0523 18:03:26.901437       7 event.go:377] Event(v1.ObjectReference{Kind:"Pod", Namespace:"app-routing-system", Name:"nginx-7f6784b4b5-rjkm4", UID:"4168009c-6885-4d0d-b2ee-1e46919425a0", APIVersion:"v1", ResourceVersion:"1507", FieldPath:""}): type: 'Normal' reason: 'RELOAD' NGINX reload triggered due to a change in configuration
W0523 18:04:18.094523       7 controller.go:1114] Error obtaining Endpoints for Service "default/aks-helloworld": no object matching key "default/aks-helloworld" in local store
I0523 18:04:18.094593       7 event.go:377] Event(v1.ObjectReference{Kind:"Ingress", Namespace:"default", Name:"aks-helloworld", UID:"5ed6ac11-f55b-4c63-aca2-58d5caa22960", APIVersion:"networking.k8s.io/v1", ResourceVersion:"126935", FieldPath:""}): type: 'Normal' reason: 'Sync' Scheduled for sync
I0523 18:04:18.088390       7 status.go:304] "updating Ingress status" namespace="default" ingress="aks-helloworld" currentValue=null newValue=[{"ip":"135.116.15.69"}]
W0523 18:04:18.094508       7 controller.go:1114] Error obtaining Endpoints for Service "default/aks-helloworld": no object matching key "default/aks-helloworld" in local store
I0523 18:04:18.094667       7 event.go:377] Event(v1.ObjectReference{Kind:"Ingress", Namespace:"default", Name:"aks-helloworld", UID:"5ed6ac11-f55b-4c63-aca2-58d5caa22960", APIVersion:"networking.k8s.io/v1", ResourceVersion:"126935", FieldPath:""}): type: 'Normal' reason: 'Sync' Scheduled for sync

# ing.delete
I0523 18:06:12.340572       7 controller.go:193] "Configuration changes detected, backend reload required"
I0523 18:06:12.340697       7 controller.go:193] "Configuration changes detected, backend reload required"
I0523 18:06:12.368905       7 controller.go:213] "Backend successfully reloaded"
I0523 18:06:12.369337       7 event.go:377] Event(v1.ObjectReference{Kind:"Pod", Namespace:"app-routing-system", Name:"nginx-7f6784b4b5-5bn7s", UID:"d65eadc8-9e9b-42ad-aac8-acc2e79597ad", APIVersion:"v1", ResourceVersion:"1389", FieldPath:""}): type: 'Normal' reason: 'RELOAD' NGINX reload triggered due to a change in configuration
I0523 18:06:12.368758       7 controller.go:213] "Backend successfully reloaded"
I0523 18:06:12.369846       7 event.go:377] Event(v1.ObjectReference{Kind:"Pod", Namespace:"app-routing-system", Name:"nginx-7f6784b4b5-rjkm4", UID:"4168009c-6885-4d0d-b2ee-1e46919425a0", APIVersion:"v1", ResourceVersion:"1507", FieldPath:""}): type: 'Normal' reason: 'RELOAD' NGINX reload triggered due to a change in configuration
```

```
# ing.approuting.nginx.example

kubectl delete deploy aks-helloworld -n hello-web-app-routing
kubectl delete deploy nginx -n app-routing-system
kubectl delete ns hello-web-app-routing
kubectl create namespace hello-web-app-routing
cat << EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aks-helloworld  
  namespace: hello-web-app-routing
spec:
  replicas: 1
  selector:
    matchLabels:
      app: aks-helloworld
  template:
    metadata:
      labels:
        app: aks-helloworld
    spec:
      containers:
      - name: aks-helloworld
        image: mcr.microsoft.com/azuredocs/aks-helloworld:v1
        ports:
        - containerPort: 80
        env:
        - name: TITLE
          value: "Welcome to Azure Kubernetes Service (AKS)"
---
apiVersion: v1
kind: Service
metadata:
  name: aks-helloworld
  namespace: hello-web-app-routing
spec:
  type: ClusterIP
  ports:
  - port: 80
  selector:
    app: aks-helloworld
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: aks-helloworld
  namespace: hello-web-app-routing
spec:
  ingressClassName: webapprouting.kubernetes.azure.com
  rules:
  - host: myapp.contoso.com # Update as required
    http:
      paths:
      - backend:
          service:
            name: aks-helloworld
            port:
              number: 80
        path: /
        pathType: Prefix
EOF

kubectl get ing -A
NAMESPACE               NAME             CLASS                                HOSTS               ADDRESS         PORTS   AGE
hello-web-app-routing   aks-helloworld   webapprouting.kubernetes.azure.com   myapp.contoso.com   74.241.234.56   80      110s

kubectl get svc -A
NAMESPACE               NAME             TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)                AGE
app-routing-system      nginx            LoadBalancer   10.0.45.15     74.241.234.56   80:31507/TCP,443:31149/TCP,10254:32578/TCP   25m
hello-web-app-routing   aks-helloworld   ClusterIP      10.0.19.188    <none>          80/TCP

kubectl logs -n app-routing-system -l app=nginx
I0902 18:35:14.694841       7 store.go:440] "Found valid IngressClass" ingress="hello-web-app-routing/aks-helloworld" ingressclass="webapprouting.kubernetes.azure.com"
I0902 18:35:14.695205       7 event.go:377] Event(v1.ObjectReference{Kind:"Ingress", Namespace:"hello-web-app-routing", Name:"aks-helloworld", UID:"ade51d5c-999a-4f70-b537-5c8970bd303c", APIVersion:"networking.k8s.io/v1", ResourceVersion:"5518", FieldPath:""}): type: 'Normal' reason: 'Sync' Scheduled for sync
I0902 18:35:17.835113       7 controller.go:193] "Configuration changes detected, backend reload required"
I0902 18:35:17.893724       7 controller.go:213] "Backend successfully reloaded"
I0902 18:35:17.894233       7 event.go:377] Event(v1.ObjectReference{Kind:"Pod", Namespace:"app-routing-system", Name:"nginx-7cd7f56848-fcvv7", UID:"d1f3d035-a5d2-4792-a90e-871c26177ae5", APIVersion:"v1", ResourceVersion:"1169", FieldPath:""}): type: 'Normal' reason: 'RELOAD' NGINX reload triggered due to a change in configuration
I0902 18:35:24.059111       7 status.go:304] "updating Ingress status" namespace="hello-web-app-routing" ingress="aks-helloworld" currentValue=null newValue=[{"ip":"74.241.234.56"}]
I0902 18:35:24.064382       7 event.go:377] Event(v1.ObjectReference{Kind:"Ingress", Namespace:"hello-web-app-routing", Name:"aks-helloworld", UID:"ade51d5c-999a-4f70-b537-5c8970bd303c", APIVersion:"networking.k8s.io/v1", ResourceVersion:"5571", FieldPath:""}): type: 'Normal' reason: 'Sync' Scheduled for sync

curl -H 'Host: myapp.contoso.com' https://74.241.234.56 -kI
HTTP/2 200
date: Mon, 02 Sep 2024 18:49:49 GMT
content-type: text/html; charset=utf-8
content-length: 629
strict-transport-security: max-age=31536000; includeSubDomains

curl -H 'Host: myapp.contoso.com' https://74.241.234.56 -k
<!DOCTYPE html>

curl 74.241.234.56 -I
HTTP/1.1 404 Not Found
Date: Mon, 02 Sep 2024 18:38:17 GMT
Content-Type: text/html
Content-Length: 146
Connection: keep-alive

curl 74.241.234.56
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>

kubectl get no -owide
NAME                                STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE
   KERNEL-VERSION      CONTAINER-RUNTIME
aks-nodepool1-14217322-vmss000000   Ready    <none>   66m   v1.29.7   10.224.0.4    <none>        Ubuntu 22.04.4 LTS   5.15.0-1071-azure   containerd://1.7.20-1

kubectl dumpy capture node aks-nodepool1-14217322-vmss000000
tcpdump host 74.241.234.56 -w /tmp/tcpdump/client

kubectl dumpy export dumpy-63958099 /tmp/tcpdump
kubectl dumpy stop dumpy-63958099
kubectl dumpy delete dumpy-63958099
ls /tmp/tcpdump/dumpy*

curl -H 'Host: myapp.contoso.com' https://74.241.234.56 -kI
1	1.2.3.4	74.241.234.56	TCP	74	38778 ? 443 [SYN] Seq=0 Win=65280 Len=0 MSS=1360 SACK_PERM TSval=4196479201 TSecr=0 WS=128
2	74.241.234.56	1.2.3.4	TCP	74	443 ? 38778 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1360 SACK_PERM TSval=2525548834 TSecr=4196479201 WS=128
3	1.2.3.4	74.241.234.56	TCP	66	38778 ? 443 [ACK] Seq=1 Ack=1 Win=65280 Len=0 TSval=4196479359 TSecr=2525548834
4	1.2.3.4	74.241.234.56	TLSv1.3	583	Client Hello
5	74.241.234.56	1.2.3.4	TCP	66	443 ? 38778 [ACK] Seq=1 Ack=518 Win=64768 Len=0 TSval=2525549183 TSecr=4196479368
6	74.241.234.56	1.2.3.4	TLSv1.3	1352	Server Hello, Change Cipher Spec, Application Data, Application Data
7	1.2.3.4	74.241.234.56	TCP	66	38778 ? 443 [ACK] Seq=518 Ack=1287 Win=64256 Len=0 TSval=4196479654 TSecr=2525549185
8	74.241.234.56	1.2.3.4	TLSv1.3	229	Application Data, Application Data
9	1.2.3.4	74.241.234.56	TCP	66	38778 ? 443 [ACK] Seq=518 Ack=1450 Win=64256 Len=0 TSval=4196479696 TSecr=2525549185
10	1.2.3.4	74.241.234.56	TLSv1.3	146	Change Cipher Spec, Application Data
11	1.2.3.4	74.241.234.56	TLSv1.3	112	Application Data
12	1.2.3.4	74.241.234.56	TLSv1.3	115	Application Data
13	1.2.3.4	74.241.234.56	TLSv1.3	169	Application Data, Application Data
14	74.241.234.56	1.2.3.4	TLSv1.3	145	Application Data
15	1.2.3.4	74.241.234.56	TCP	66	38778 ? 443 [ACK] Seq=796 Ack=1529 Win=64256 Len=0 TSval=4196479806 TSecr=2525549299
16	74.241.234.56	1.2.3.4	TLSv1.3	145	Application Data
17	74.241.234.56	1.2.3.4	TLSv1.3	137	Application Data
18	74.241.234.56	1.2.3.4	TLSv1.3	193	Application Data
19	1.2.3.4	74.241.234.56	TCP	66	38778 ? 443 [ACK] Seq=796 Ack=1608 Win=64256 Len=0 TSval=4196479862 TSecr=2525549299
20	1.2.3.4	74.241.234.56	TCP	66	38778 ? 443 [ACK] Seq=796 Ack=1679 Win=64256 Len=0 TSval=4196479863 TSecr=2525549299
21	1.2.3.4	74.241.234.56	TCP	66	38778 ? 443 [ACK] Seq=796 Ack=1806 Win=64256 Len=0 TSval=4196479863 TSecr=2525549302
22	1.2.3.4	74.241.234.56	TLSv1.3	97	Application Data
23	1.2.3.4	74.241.234.56	TLSv1.3	90	Application Data
24	1.2.3.4	74.241.234.56	TCP	66	38778 ? 443 [FIN, ACK] Seq=851 Ack=1806 Win=64256 Len=0 TSval=4196479864 TSecr=2525549302
25	74.241.234.56	1.2.3.4	TCP	66	443 ? 38778 [ACK] Seq=1806 Ack=852 Win=64768 Len=0 TSval=2525549590 TSecr=4196479863
26	74.241.234.56	1.2.3.4	TCP	66	443 ? 38778 [FIN, ACK] Seq=1806 Ack=852 Win=64768 Len=0 TSval=2525549590 TSecr=4196479863
27	1.2.3.4	74.241.234.56	TCP	66	38778 ? 443 [ACK] Seq=852 Ack=1807 Win=64256 Len=0 TSval=4196480157 TSecr=2525549590
```

```
kubectl dumpy get
kubectl dumpy capture deploy aks-helloworld -n hello-web-app-routing
kubectl dumpy capture deploy nginx -n app-routing-system
kubectl dumpy capture node all
tcpdump host 74.241.234.56 -w /tmp/tcpdump/client

kubectl dumpy export dumpy-74410416 /tmp/tcpdump
kubectl dumpy export dumpy-55029686 -n app-routing-system /tmp/tcpdump
kubectl dumpy export dumpy-65044851 -n hello-web-app-routing /tmp/tcpdump
ls /tmp/tcpdump/dumpy*

kubectl dumpy stop dumpy-74410416
kubectl dumpy stop dumpy-55029686 -n app-routing-system
kubectl dumpy stop dumpy-65044851 -n hello-web-app-routing
kubectl dumpy delete dumpy-74410416
kubectl dumpy delete dumpy-55029686 -n app-routing-system
kubectl dumpy delete dumpy-65044851 -n hello-web-app-routing

kubectl get po -A -owide | grep routing
app-routing-system      nginx-7cd7f56848-rtvrv               1/1     Running   0          5m39s   10.244.1.4    aks-nodepool1-14217322-vmss000001   <none>           <none>
app-routing-system      nginx-7cd7f56848-ts5dt               1/1     Running   0          5m32s   10.244.1.5    aks-nodepool1-14217322-vmss000001   <none>           <none>
hello-web-app-routing   aks-helloworld-77fbc6b96c-n5rtq      1/1     Running   0          118s    10.244.0.20   aks-nodepool1-14217322-vmss000000   <none>           <none>
kubectl get no -owide
NAME                                STATUS   ROLES    AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
aks-nodepool1-14217322-vmss000000   Ready    <none>   5h39m   v1.29.7   10.224.0.4    <none>        Ubuntu 22.04.4 LTS   5.15.0-1071-azure   containerd://1.7.20-1
aks-nodepool1-14217322-vmss000001   Ready    <none>   4h43m   v1.29.7   10.224.0.5    <none>        Ubuntu 22.04.4 LTS   5.15.0-1071-azure   containerd://1.7.20-1
kubectl get ing -A
NAMESPACE               NAME             CLASS                                HOSTS               ADDRESS         PORTS   AGE
hello-web-app-routing   aks-helloworld   webapprouting.kubernetes.azure.com   myapp.contoso.com   74.241.234.56   80      5h23m

curl -H 'Host: myapp.contoso.com' https://74.241.234.56 -kI
1	1.2.3.4	74.241.234.56	TCP	74	35084 ? 443 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=4203449957 TSecr=0 WS=128
2	74.241.234.56	1.2.3.4	TCP	74	443 ? 35084 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1412 SACK_PERM TSval=4261195926 TSecr=4203449957 WS=128
3	1.2.3.4	74.241.234.56	TCP	66	35084 ? 443 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=4203450023 TSecr=4261195926
4	1.2.3.4	74.241.234.56	TLSv1.3	583	Client Hello
5	74.241.234.56	1.2.3.4	TCP	66	443 ? 35084 [ACK] Seq=1 Ack=518 Win=64768 Len=0 TSval=4261196003 TSecr=4203450036
6	74.241.234.56	1.2.3.4	TLSv1.3	1515	Server Hello, Change Cipher Spec, Application Data, Application Data, Application Data, Application Data
7	1.2.3.4	74.241.234.56	TCP	66	35084 ? 443 [ACK] Seq=518 Ack=1450 Win=64128 Len=0 TSval=4203450106 TSecr=4261196006
8	1.2.3.4	74.241.234.56	TLSv1.3	146	Change Cipher Spec, Application Data
9	1.2.3.4	74.241.234.56	TLSv1.3	112	Application Data
...
19	1.2.3.4	74.241.234.56	TLSv1.3	90	Application Data
20	1.2.3.4	74.241.234.56	TCP	66	35084 ? 443 [FIN, ACK] Seq=851 Ack=1828 Win=64128 Len=0 TSval=4203450189 TSecr=4261196091
21	74.241.234.56	1.2.3.4	TCP	66	443 ? 35084 [ACK] Seq=1828 Ack=852 Win=64768 Len=0 TSval=4261196157 TSecr=4203450172
22	74.241.234.56	1.2.3.4	TCP	66	443 ? 35084 [FIN, ACK] Seq=1828 Ack=852 Win=64768 Len=0 TSval=4261196157 TSecr=4203450172
23	1.2.3.4	74.241.234.56	TCP	66	35084 ? 443 [ACK] Seq=852 Ack=1829 Win=64128 Len=0 TSval=4203450253 TSecr=4261196157

kubectl logs -n app-routing-system -l app=nginx # standard logging output
I0902 19:52:29.236097       6 status.go:85] "New leader elected" identity="nginx-7cd7f56848-rtvrv"
1.2.3.5 - - [02/Sep/2024:20:02:13 +0000] "HEAD / HTTP/2.0" 200 0 "-" "curl/7.68.0" 37 0.014 [hello-web-app-routing-aks-helloworld-80] [] 10.244.0.20:80 0 0.014 200 557ffc21cbb028bcf9c6be49f796ddbb

dumpy-65044851-aks-helloworld-77fbc6b96c-n5rtq
20	32:88:d7:4c:61:bc		ARP	48	Who has 10.244.0.20? Tell 10.244.0.1
21	ae:91:4c:fd:fa:8e		ARP	48	10.244.0.20 is at ae:91:4c:fd:fa:8e
22	10.244.1.4	10.244.0.20	TCP	80	39492 ? 80 [SYN] Seq=0 Win=64240 Len=0 MSS=1418 SACK_PERM TSval=4150146873 TSecr=0 WS=128
23	10.244.0.20	10.244.1.4	TCP	80	80 ? 39492 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1460 SACK_PERM TSval=364703566 TSecr=4150146873 WS=128
24	10.244.1.4	10.244.0.20	TCP	72	39492 ? 80 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=4150146875 TSecr=364703566
25	10.244.1.4	10.244.0.20	HTTP	392	HEAD / HTTP/1.1 
26	10.244.0.20	10.244.1.4	TCP	72	80 ? 39492 [ACK] Seq=1 Ack=321 Win=64896 Len=0 TSval=364703567 TSecr=4150146875
27	10.244.0.20	10.244.1.4	HTTP	235	HTTP/1.1 200 OK 
28	10.244.1.4	10.244.0.20	TCP	72	39492 ? 80 [ACK] Seq=321 Ack=164 Win=64128 Len=0 TSval=4150146887 TSecr=364703579

dumpy-55029686-nginx-7cd7f56848-rtvrv
ip.addr==1.2.3.5
485	1.2.3.5	10.244.1.4	TCP	80	63098 ? 8443 [SYN] Seq=0 Win=64240 Len=0 MSS=1412 SACK_PERM TSval=4203449957 TSecr=0 WS=128
486	10.244.1.4	1.2.3.5	TCP	80	8443 ? 63098 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1460 SACK_PERM TSval=4261195926 TSecr=4203449957 WS=128
487	1.2.3.5	10.244.1.4	TCP	72	63098 ? 8443 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=4203450023 TSecr=4261195926
488	1.2.3.5	10.244.1.4	TLSv1.3	589	Client Hello
489	10.244.1.4	1.2.3.5	TCP	72	8443 ? 63098 [ACK] Seq=1 Ack=518 Win=64768 Len=0 TSval=4261196003 TSecr=4203450036
490	10.244.1.4	1.2.3.5	TLSv1.3	1521	Server Hello, Change Cipher Spec, Application Data, Application Data, Application Data, Application Data
491	1.2.3.5	10.244.1.4	TCP	72	63098 ? 8443 [ACK] Seq=518 Ack=1450 Win=64128 Len=0 TSval=4203450106 TSecr=4261196006
492	1.2.3.5	10.244.1.4	TLSv1.3	152	Change Cipher Spec, Application Data
493	10.244.1.4	1.2.3.5	TLSv1.3	151	Application Data
494	10.244.1.4	1.2.3.5	TLSv1.3	151	Application Data
495	10.244.1.4	1.2.3.5	TLSv1.3	134	Application Data
496	1.2.3.5	10.244.1.4	TLSv1.3	118	Application Data
497	1.2.3.5	10.244.1.4	TLSv1.3	121	Application Data
498	10.244.1.4	1.2.3.5	TCP	72	8443 ? 63098 [ACK] Seq=1670 Ack=693 Win=64768 Len=0 TSval=4261196077 TSecr=4203450110
499	10.244.1.4	1.2.3.5	TLSv1.3	103	Application Data
500	1.2.3.5	10.244.1.4	TLSv1.3	175	Application Data, Application Data
508	10.244.1.4	1.2.3.5	TLSv1.3	199	Application Data
509	1.2.3.5	10.244.1.4	TLSv1.3	103	Application Data
510	1.2.3.5	10.244.1.4	TLSv1.3	96	Application Data
511	1.2.3.5	10.244.1.4	TCP	72	63098 ? 8443 [FIN, ACK] Seq=851 Ack=1828 Win=64128 Len=0 TSval=4203450189 TSecr=4261196091
512	10.244.1.4	1.2.3.5	TCP	72	8443 ? 63098 [ACK] Seq=1828 Ack=852 Win=64768 Len=0 TSval=4261196157 TSecr=4203450172
513	10.244.1.4	1.2.3.5	TCP	72	8443 ? 63098 [FIN, ACK] Seq=1828 Ack=852 Win=64768 Len=0 TSval=4261196157 TSecr=4203450172
514	1.2.3.5	10.244.1.4	TCP	72	63098 ? 8443 [ACK] Seq=852 Ack=1829 Win=64128 Len=0 TSval=4203450253 TSecr=4261196157
ip.addr==10.244.0.20
501	10.244.1.4	10.244.0.20	TCP	80	39492 ? 80 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=4150146873 TSecr=0 WS=128
502	10.244.0.20	10.244.1.4	TCP	80	80 ? 39492 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1418 SACK_PERM TSval=364703566 TSecr=4150146873 WS=128
503	10.244.1.4	10.244.0.20	TCP	72	39492 ? 80 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=4150146875 TSecr=364703566
504	10.244.1.4	10.244.0.20	HTTP	392	HEAD / HTTP/1.1 
505	10.244.0.20	10.244.1.4	TCP	72	80 ? 39492 [ACK] Seq=1 Ack=321 Win=64896 Len=0 TSval=364703567 TSecr=4150146875
506	10.244.0.20	10.244.1.4	HTTP	235	HTTP/1.1 200 OK 
507	10.244.1.4	10.244.0.20	TCP	72	39492 ? 80 [ACK] Seq=321 Ack=164 Win=64128 Len=0 TSval=4150146887 TSecr=364703579
860	10.244.1.4	10.244.0.20	TCP	72	39492 ? 80 [FIN, ACK] Seq=321 Ack=164 Win=64128 Len=0 TSval=4150206875 TSecr=364703579
861	10.244.0.20	10.244.1.4	TCP	72	80 ? 39492 [FIN, ACK] Seq=164 Ack=322 Win=64896 Len=0 TSval=364763567 TSecr=4150206875
862	10.244.1.4	10.244.0.20	TCP	72	39492 ? 80 [ACK] Seq=322 Ack=165 Win=64128 Len=0 TSval=4150206876 TSecr=364763567

dumpy-74410416-aks-nodepool1-14217322-vmss000000
ip.addr==1.2.3.5 or (ip.addr==10.244.0.20 and ip.addr==10.244.1.4)
7877	10.244.1.4	10.244.0.20	TCP	80	39492 ? 80 [SYN] Seq=0 Win=64240 Len=0 MSS=1418 SACK_PERM TSval=4150146873 TSecr=0 WS=128
7891	10.244.0.20	10.244.1.4	TCP	80	80 ? 39492 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1460 SACK_PERM TSval=364703566 TSecr=4150146873 WS=128
7894	10.244.1.4	10.244.0.20	TCP	72	39492 ? 80 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=4150146875 TSecr=364703566
7895	10.244.1.4	10.244.0.20	HTTP	392	HEAD / HTTP/1.1 
7896	10.244.1.4	10.244.0.20	TCP	72	39492 ? 80 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=4150146875 TSecr=364703566
7897	10.244.1.4	10.244.0.20	TCP	72	39492 ? 80 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=4150146875 TSecr=364703566
7900	10.244.0.20	10.244.1.4	TCP	72	80 ? 39492 [ACK] Seq=1 Ack=321 Win=64896 Len=0 TSval=364703567 TSecr=4150146875
7903	10.244.0.20	10.244.1.4	HTTP	235	HTTP/1.1 200 OK 
7906	10.244.1.4	10.244.0.20	TCP	72	39492 ? 80 [ACK] Seq=321 Ack=164 Win=64128 Len=0 TSval=4150146887 TSecr=364703579
15972	10.244.1.4	10.244.0.20	TCP	72	39492 ? 80 [FIN, ACK] Seq=321 Ack=164 Win=64128 Len=0 TSval=4150206875 TSecr=364703579
15975	10.244.0.20	10.244.1.4	TCP	72	80 ? 39492 [FIN, ACK] Seq=164 Ack=322 Win=64896 Len=0 TSval=364763567 TSecr=4150206875
15978	10.244.1.4	10.244.0.20	TCP	72	39492 ? 80 [ACK] Seq=322 Ack=165 Win=64128 Len=0 TSval=4150206876 TSecr=364763567

dumpy-74410416-aks-nodepool1-14217322-vmss000001
ip.addr==1.2.3.5 or (ip.addr==10.244.0.20 and ip.addr==10.244.1.4)
4794	1.2.3.5	74.241.234.56	TCP	80	63098 ? 443 [SYN] Seq=0 Win=64240 Len=0 MSS=1412 SACK_PERM TSval=4203449957 TSecr=0 WS=128
4795	1.2.3.5	10.244.1.4	TCP	80	63098 ? 8443 [SYN] Seq=0 Win=64240 Len=0 MSS=1412 SACK_PERM TSval=4203449957 TSecr=0 WS=128
4797	10.244.1.4	1.2.3.5	TCP	80	8443 ? 63098 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1460 SACK_PERM TSval=4261195926 TSecr=4203449957 WS=128
4799	74.241.234.56	1.2.3.5	TCP	80	443 ? 63098 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1460 SACK_PERM TSval=4261195926 TSecr=4203449957 WS=128
4800	1.2.3.5	74.241.234.56	TCP	72	63098 ? 443 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=4203450023 TSecr=4261195926
4801	1.2.3.5	10.244.1.4	TCP	72	63098 ? 8443 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=4203450023 TSecr=4261195926
4803	1.2.3.5	74.241.234.56	TLSv1.3	589	Client Hello
4804	1.2.3.5	10.244.1.4	TLSv1.3	589	Client Hello
4806	10.244.1.4	1.2.3.5	TCP	72	8443 ? 63098 [ACK] Seq=1 Ack=518 Win=64768 Len=0 TSval=4261196003 TSecr=4203450036
4808	74.241.234.56	1.2.3.5	TCP	72	443 ? 63098 [ACK] Seq=1 Ack=518 Win=64768 Len=0 TSval=4261196003 TSecr=4203450036
4809	10.244.1.4	1.2.3.5	TLSv1.3	1521	Server Hello, Change Cipher Spec, Application Data, Application Data, Application Data, Application Data
4811	74.241.234.56	1.2.3.5	TLSv1.3	1521	Server Hello, Change Cipher Spec, Application Data, Application Data, Application Data, Application Data
4812	1.2.3.5	74.241.234.56	TCP	72	63098 ? 443 [ACK] Seq=518 Ack=1450 Win=64128 Len=0 TSval=4203450106 TSecr=4261196006
4813	1.2.3.5	10.244.1.4	TCP	72	63098 ? 8443 [ACK] Seq=518 Ack=1450 Win=64128 Len=0 TSval=4203450106 TSecr=4261196006
4815	1.2.3.5	74.241.234.56	TLSv1.3	152	Change Cipher Spec, Application Data
4816	1.2.3.5	10.244.1.4	TLSv1.3	152	Change Cipher Spec, Application Data
4818	10.244.1.4	1.2.3.5	TLSv1.3	151	Application Data
...
4831	1.2.3.5	10.244.1.4	TLSv1.3	121	Application Data
4833	10.244.1.4	1.2.3.5	TCP	72	8443 ? 63098 [ACK] Seq=1670 Ack=693 Win=64768 Len=0 TSval=4261196077 TSecr=4203450110
4835	74.241.234.56	1.2.3.5	TCP	72	443 ? 63098 [ACK] Seq=1670 Ack=693 Win=64768 Len=0 TSval=4261196077 TSecr=4203450110
4836	10.244.1.4	1.2.3.5	TLSv1.3	103	Application Data
4838	74.241.234.56	1.2.3.5	TLSv1.3	103	Application Data
4839	1.2.3.5	74.241.234.56	TLSv1.3	175	Application Data, Application Data
4840	1.2.3.5	10.244.1.4	TLSv1.3	175	Application Data, Application Data
4842	10.244.1.4	10.244.0.20	TCP	80	39492 ? 80 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=4150146873 TSecr=0 WS=128
4845	10.244.0.20	10.244.1.4	TCP	80	80 ? 39492 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1418 SACK_PERM TSval=364703566 TSecr=4150146873 WS=128
4848	10.244.1.4	10.244.0.20	TCP	72	39492 ? 80 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=4150146875 TSecr=364703566
4851	10.244.1.4	10.244.0.20	HTTP	392	HEAD / HTTP/1.1 
4854	10.244.0.20	10.244.1.4	TCP	72	80 ? 39492 [ACK] Seq=1 Ack=321 Win=64896 Len=0 TSval=364703567 TSecr=4150146875
4857	10.244.0.20	10.244.1.4	TCP	235	80 ? 39492 [PSH, ACK] Seq=1 Ack=321 Win=64896 Len=163 TSval=364703579 TSecr=4150146875
4860	10.244.1.4	10.244.0.20	TCP	72	39492 ? 80 [ACK] Seq=321 Ack=164 Win=64128 Len=0 TSval=4150146887 TSecr=364703579
4863	10.244.1.4	1.2.3.5	TLSv1.3	199	Application Data
...
4869	1.2.3.5	74.241.234.56	TLSv1.3	96	Application Data
4870	1.2.3.5	74.241.234.56	TCP	72	63098 ? 443 [FIN, ACK] Seq=851 Ack=1828 Win=64128 Len=0 TSval=4203450189 TSecr=4261196091
4871	1.2.3.5	10.244.1.4	TLSv1.3	96	Application Data
4873	1.2.3.5	10.244.1.4	TCP	72	63098 ? 8443 [FIN, ACK] Seq=851 Ack=1828 Win=64128 Len=0 TSval=4203450189 TSecr=4261196091
4875	10.244.1.4	1.2.3.5	TCP	72	8443 ? 63098 [ACK] Seq=1828 Ack=852 Win=64768 Len=0 TSval=4261196157 TSecr=4203450172
4877	74.241.234.56	1.2.3.5	TCP	72	443 ? 63098 [ACK] Seq=1828 Ack=852 Win=64768 Len=0 TSval=4261196157 TSecr=4203450172
4878	10.244.1.4	1.2.3.5	TCP	72	8443 ? 63098 [FIN, ACK] Seq=1828 Ack=852 Win=64768 Len=0 TSval=4261196157 TSecr=4203450172
4880	74.241.234.56	1.2.3.5	TCP	72	443 ? 63098 [FIN, ACK] Seq=1828 Ack=852 Win=64768 Len=0 TSval=4261196157 TSecr=4203450172
4881	1.2.3.5	74.241.234.56	TCP	72	63098 ? 443 [ACK] Seq=852 Ack=1829 Win=64128 Len=0 TSval=4203450253 TSecr=4261196157
4882	1.2.3.5	10.244.1.4	TCP	72	63098 ? 8443 [ACK] Seq=852 Ack=1829 Win=64128 Len=0 TSval=4203450253 TSecr=4261196157
9526	10.244.1.4	10.244.0.20	TCP	72	39492 ? 80 [FIN, ACK] Seq=321 Ack=164 Win=64128 Len=0 TSval=4150206875 TSecr=364703579
9529	10.244.0.20	10.244.1.4	TCP	72	80 ? 39492 [FIN, ACK] Seq=164 Ack=322 Win=64896 Len=0 TSval=364763567 TSecr=4150206875
9532	10.244.1.4	10.244.0.20	TCP	72	39492 ? 80 [ACK] Seq=322 Ack=165 Win=64128 Len=0 TSval=4150206876 TSecr=364763567
```

```
# iptable

kubectl get ing -n hello-web-app-routing
aks-helloworld   webapprouting.kubernetes.azure.com   myapp.contoso.com   74.241.234.56   80      31h
aks-nodepool1-14217322-vmss000000:/# iptables -t filter -nvL
Chain KUBE-EXTERNAL-SERVICES (2 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            74.241.234.56        /* app-routing-system/nginx:prometheus has no local endpoints */
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* app-routing-system/nginx:prometheus has no local endpoints */ ADDRTYPE match dst-type LOCAL
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            74.241.234.56        /* app-routing-system/nginx:http has no local endpoints */
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* app-routing-system/nginx:http has no local endpoints */ ADDRTYPE match dst-type LOCAL
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            74.241.234.56        /* app-routing-system/nginx:https has no local endpoints */
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* app-routing-system/nginx:https has no local endpoints */ ADDRTYPE match dst-type LOCAL
Chain KUBE-NODEPORTS (1 references)
 pkts bytes target     prot opt in     out     source               destination
  510 69003 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* app-routing-system/nginx:prometheus health check node port */
    0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* app-routing-system/nginx:http health check node port */
    0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* app-routing-system/nginx:https health check node port */
```

```
# port 10254
# The GET /healthz request is sent every five seconds.

az network nsg show -g mc_rg_aksapproute_swedencentral -n aks-agentpool-26217469-nsg --query securityRules
[
  {
    "access": "Allow",
    "destinationAddressPrefix": "74.241.234.56",
    "destinationAddressPrefixes": [],
    "destinationPortRanges": [
      "10254",
      "443",
      "80"
    ],
    "direction": "Inbound",
    "etag": "W/\"07e040ae-7715-4a21-96d4-0b77ed5327fb\"",
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aksapproute_swedencentral/providers/Microsoft.Network/networkSecurityGroups/aks-agentpool-26217469-nsg/securityRules/k8s-azure-lb_allow_IPv4_0e71c69d55927e99928ad7d522e5dd4f",
    "name": "k8s-azure-lb_allow_IPv4_0e71c69d55927e99928ad7d522e5dd4f",
    "priority": 500,
    "protocol": "Tcp",
    "provisioningState": "Succeeded",
    "resourceGroup": "mc_rg_aksapproute_swedencentral",
    "sourceAddressPrefix": "Internet",
    "sourceAddressPrefixes": [],
    "sourcePortRange": "*",
    "sourcePortRanges": [],
    "type": "Microsoft.Network/networkSecurityGroups/securityRules"
  }
]

kubectl get ing -n hello-web-app-routing
kubectl get po -n app-routing-system -l app=nginx -owide
aks-helloworld   webapprouting.kubernetes.azure.com   myapp.contoso.com   74.241.234.56   80      31h
nginx-7cd7f56848-rtvrv   1/1     Running   0          26h   10.244.1.4   aks-nodepool1-14217322-vmss000001   <none>           <none>

kubectl describe po -n app-routing-system -l app=nginx | grep 10254
Annotations:          prometheus.io/port: 10254
    Ports:         8080/TCP, 8443/TCP, 10254/TCP
    Readiness:  http-get http://:10254/healthz delay=10s timeout=1s period=5s #success=1 #failure=3
    
kubectl get svc -A
app-routing-system      nginx            LoadBalancer   10.0.45.15     74.241.234.56   80:31507/TCP,443:31149/TCP,10254:32578/TCP   32h

aks-nodepool1-14217322-vmss000001
wireshark ip.addr==10.244.1.1 and ip.addr==10.244.1.4
wireshark tcp.port==10254
40	10.244.1.1	10.244.1.4	TCP	80	42096 ? 10254 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=739098495 TSecr=0 WS=128
42	10.244.1.4	10.244.1.1	TCP	80	10254 ? 42096 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1460 SACK_PERM TSval=3320277675 TSecr=739098495 WS=128
44	10.244.1.1	10.244.1.4	TCP	72	42096 ? 10254 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=739098495 TSecr=3320277675
46	10.244.1.1	10.244.1.4	HTTP	182	GET /healthz HTTP/1.1 
48	10.244.1.4	10.244.1.1	TCP	72	10254 ? 42096 [ACK] Seq=1 Ack=111 Win=65152 Len=0 TSval=3320277675 TSecr=739098495
50	10.244.1.4	10.244.1.1	HTTP	242	HTTP/1.1 200 OK  (text/plain)
52	10.244.1.1	10.244.1.4	TCP	72	42096 ? 10254 [ACK] Seq=111 Ack=171 Win=64128 Len=0 TSval=739098496 TSecr=3320277676
54	10.244.1.4	10.244.1.1	TCP	72	10254 ? 42096 [FIN, ACK] Seq=171 Ack=111 Win=65152 Len=0 TSval=3320277676 TSecr=739098496
56	10.244.1.1	10.244.1.4	TCP	72	42096 ? 10254 [FIN, ACK] Seq=111 Ack=172 Win=64128 Len=0 TSval=739098496 TSecr=3320277676

dumpy-55029686-nginx-7cd7f56848-rtvrv
wireshark ip.addr==10.244.1.1
4	10.244.1.1	10.244.1.4	TCP	80	42054 → 10254 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=739068495 TSecr=0 WS=128
5	10.244.1.4	10.244.1.1	TCP	80	10254 → 42054 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1460 SACK_PERM TSval=3320247675 TSecr=739068495 WS=128
6	10.244.1.1	10.244.1.4	TCP	72	42054 → 10254 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=739068495 TSecr=3320247675
7	10.244.1.1	10.244.1.4	HTTP	182	GET /healthz HTTP/1.1 
8	10.244.1.4	10.244.1.1	TCP	72	10254 → 42054 [ACK] Seq=1 Ack=111 Win=65152 Len=0 TSval=3320247675 TSecr=739068495
19	10.244.1.4	10.244.1.1	HTTP	242	HTTP/1.1 200 OK  (text/plain)
20	10.244.1.1	10.244.1.4	TCP	72	42054 → 10254 [ACK] Seq=111 Ack=171 Win=64128 Len=0 TSval=739068496 TSecr=3320247676
21	10.244.1.4	10.244.1.1	TCP	72	10254 → 42054 [FIN, ACK] Seq=171 Ack=111 Win=65152 Len=0 TSval=3320247676 TSecr=739068496
22	10.244.1.1	10.244.1.4	TCP	72	42054 → 10254 [FIN, ACK] Seq=111 Ack=172 Win=64128 Len=0 TSval=739068496 TSecr=3320247676
```

- https://kubernetes.github.io/ingress-nginx/deploy/: existing rule that allows access to port 80/tcp, 443/tcp and 10254/tcp
- https://stackoverflow.com/questions/50008352/kubernetes-nginx-ingress-controller-liveness-probe-failed: Get http://10.1.1.254:10254/healthz: dial tcp 10.1.1.254:10254

```
# leader

kubectl logs -n app-routing-system -l app=nginx | grep leader
I0903 23:18:33.061405       7 leaderelection.go:250] attempting to acquire leader lease app-routing-system/nginx...
I0903 23:18:33.067023       7 status.go:85] "New leader elected" identity="nginx-7cd7f56848-rtvrv"
I0903 23:19:03.324480       7 leaderelection.go:260] successfully acquired lease app-routing-system/nginx
I0903 23:19:03.324666       7 status.go:85] "New leader elected" identity="nginx-7cd7f56848-tfjb6"
I0903 23:18:25.194896       7 leaderelection.go:250] attempting to acquire leader lease app-routing-system/nginx...
I0903 23:18:25.199755       7 status.go:85] "New leader elected" identity="nginx-7cd7f56848-rtvrv"
I0903 23:19:11.637295       7 status.go:85] "New leader elected" identity="nginx-7cd7f56848-tfjb6"
```

```
# routeingress

kubectl get svc -A
NAMESPACE               NAME             TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)	AGE
app-routing-system      nginx            LoadBalancer   10.0.199.21    4.225.209.242   80:31806/TCP,443:31010/TCP   93s
app-routing-system      nginx-metrics    ClusterIP      10.0.95.24     <none>          10254/TCP	93s
default                 kubernetes       ClusterIP      10.0.0.1       <none>          443/TCP	2m52s
hello-web-app-routing   aks-helloworld   ClusterIP      10.0.202.114   <none>          80/TCP	34s

# kubectl get ep -A
NAMESPACE               NAME             ENDPOINTS                                                         AGE
app-routing-system      nginx            10.244.0.203:8443,10.244.2.1:8443,10.244.0.203:8080 + 1 more...   2m17s
app-routing-system      nginx-metrics    10.244.0.203:10254,10.244.2.1:10254                               2m17s
hello-web-app-routing   aks-helloworld   10.244.2.177:80                                                   78s
# kubectl describe svc -A # local traffic policy
Name:                     nginx
Namespace:                app-routing-system
Labels:                   app.kubernetes.io/component=ingress-controller
                          app.kubernetes.io/managed-by=aks-app-routing-operator
                          app.kubernetes.io/name=nginx
Annotations:              <none>
Selector:                 app=nginx
Type:                     LoadBalancer
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.0.199.21
IPs:                      10.0.199.21
LoadBalancer Ingress:     4.225.209.242 (VIP)
Port:                     http  80/TCP
TargetPort:               http/TCP
NodePort:                 http  31806/TCP
Endpoints:                10.244.0.203:8080,10.244.2.1:8080
Port:                     https  443/TCP
TargetPort:               https/TCP
NodePort:                 https  31010/TCP
Endpoints:                10.244.0.203:8443,10.244.2.1:8443
Session Affinity:         None
External Traffic Policy:  Local
Internal Traffic Policy:  Cluster
HealthCheck NodePort:     31893
##
Name:                     aks-helloworld
Namespace:                hello-web-app-routing
Labels:                   <none>
Annotations:              <none>
Selector:                 app=aks-helloworld
Type:                     ClusterIP
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.0.202.114
IPs:                      10.0.202.114
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
Endpoints:                10.244.2.177:80
Session Affinity:         None
Internal Traffic Policy:  Cluster
Events:                   <none>

# kubectl get po -owide -A
NAMESPACE               NAME                                  READY   STATUS    RESTARTS   AGE     IP             NODE                                NOMINATED NODE   READINESS GATES
app-routing-system      nginx-85497484cc-bbjdz                1/1     Running   0          3m35s   10.244.0.203   aks-nodepool1-13895781-vmss000002   <none>           <none>
app-routing-system      nginx-85497484cc-dd9st                1/1     Running   0          3m39s   10.244.2.1     aks-nodepool1-13895781-vmss000001   <none>           <none>
hello-web-app-routing   aks-helloworld-868d7dbbd8-szv22       1/1     Running   0          3m36s   10.244.2.177   aks-nodepool1-13895781-vmss000001   <none>
# kubectl get no -owide
NAME                                STATUS   ROLES    AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
aks-nodepool1-13895781-vmss000000   Ready    <none>   5m19s   v1.30.6   10.224.0.5    <none>        Ubuntu 22.04.5 LTS   5.15.0-1074-azure   containerd://1.7.23-1
aks-nodepool1-13895781-vmss000001   Ready    <none>   5m      v1.30.6   10.224.0.4    <none>        Ubuntu 22.04.5 LTS   5.15.0-1074-azure   containerd://1.7.23-1
aks-nodepool1-13895781-vmss000002   Ready    <none>   5m19s   v1.30.6   10.224.0.6    <none>        Ubuntu 22.04.5 LTS   5.15.0-1074-azure   containerd://1.7.23-1

noderg=$(az aks show -g $rg -n aksapproute --query nodeResourceGroup -o tsv)
lb=kubernetes
az network lb frontend-ip list -g $noderg --lb-name $lb -o table
Name                                  PrivateIPAllocationMethod    ProvisioningState    ResourceGroup
------------------------------------  ---------------------------  -------------------  -------------------------------
c0595ecb-f0b2-441c-93ba-1a4759a1b8a6  Dynamic                      Succeeded            mc_rg_aksapproute_swedencentral
afd50e6da36c9436981b613759878f31      Dynamic                      Succeeded            mc_rg_aksapproute_swedencentral

pipid=$(az network lb frontend-ip show -g $noderg --lb-name $lb -n afd50e6da36c9436981b613759878f31 --query publicIPAddress.id -o tsv)
az network public-ip show --id $pipid --query ipAddress -o tsv
4.225.209.242

az network lb rule list -g $noderg --lb-name $lb -o table # port 443 (https)
BackendPort    DisableOutboundSnat    EnableFloatingIP    EnableTcpReset    FrontendPort    IdleTimeoutInMinutes    LoadDistribution    Name                                      Protocol    ProvisioningState    ResourceGroup
-------------  ---------------------  ------------------  ----------------  --------------  ----------------------  ------------------  ----------------------------------------  ----------  -------------------  -------------------------------
80             True                   True                True              80              4				Default             afd50e6da36c9436981b613759878f31-TCP-80   Tcp         Succeeded            mc_rg_aksapproute_swedencentral
443            True                   True                True              443             4				Default             afd50e6da36c9436981b613759878f31-TCP-443  Tcp         Succeeded            mc_rg_aksapproute_swedencentral

az network lb probe list -g $noderg --lb-name $lb -o table # probe to /healthz
IntervalInSeconds    Name                                        NumberOfProbes    Port    ProbeThreshold    Protocol    ProvisioningState    RequestPath    ResourceGroup
-------------------  ------------------------------------------  ----------------  ------  ----------------  ----------  -------------------  -------------  -------------------------------
5                    afd50e6da36c9436981b613759878f31-TCP-31893  2                 31893   2                 Http        Succeeded            /healthz       mc_rg_aksapproute_swedencentral

# nslookup

curl -H 'Host: myapp.contoso.com' https://4.225.209.242 -kIv
* Connected to 4.225.209.242 (4.225.209.242) port 443

# aks-nodepool1-13895781-vmss000001

iptables-save | grep loadbal
-A KUBE-SERVICES -d 4.225.209.242/32 -p tcp -m comment --comment "app-routing-system/nginx:http loadbalancer IP" -j KUBE-EXT-EEQNXCJLUUVUU2YK
-A KUBE-SERVICES -d 4.225.209.242/32 -p tcp -m comment --comment "app-routing-system/nginx:https loadbalancer IP" -j KUBE-EXT-RX2GVUFA32EFJN3A

-A KUBE-EXT-EEQNXCJLUUVUU2YK -i azv+ -m comment --comment "pod traffic for app-routing-system/nginx:http external destinations" -j KUBE-SVC-EEQNXCJLUUVUU2YK
-A KUBE-EXT-EEQNXCJLUUVUU2YK -m comment --comment "masquerade LOCAL traffic for app-routing-system/nginx:http external destinations" -m addrtype --src-type LOCAL -j KUBE-MARK-MASQ
-A KUBE-EXT-EEQNXCJLUUVUU2YK -m comment --comment "route LOCAL traffic for app-routing-system/nginx:http external destinations" -m addrtype --src-type LOCAL -j KUBE-SVC-EEQNXCJLUUVUU2YK
-A KUBE-EXT-EEQNXCJLUUVUU2YK -j KUBE-SVL-EEQNXCJLUUVUU2YK

-A KUBE-SVC-EEQNXCJLUUVUU2YK -d 10.0.199.21/32 ! -i azv+ -p tcp -m comment --comment "app-routing-system/nginx:http cluster IP" -j KUBE-MARK-MASQ
-A KUBE-SVC-EEQNXCJLUUVUU2YK -m comment --comment "app-routing-system/nginx:http -> 10.244.0.203:8080" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-GG5PHKGFOOREI2Y5
-A KUBE-SVC-EEQNXCJLUUVUU2YK -m comment --comment "app-routing-system/nginx:http -> 10.244.2.1:8080" -j KUBE-SEP-7PTWPOJIQ22BXKMQ

-A KUBE-SEP-GG5PHKGFOOREI2Y5 -s 10.244.0.203/32 -m comment --comment "app-routing-system/nginx:http" -j KUBE-MARK-MASQ
-A KUBE-SEP-GG5PHKGFOOREI2Y5 -p tcp -m comment --comment "app-routing-system/nginx:http" -m tcp -j DNAT --to-destination 10.244.0.203:8080

-A KUBE-SEP-7PTWPOJIQ22BXKMQ -s 10.244.2.1/32 -m comment --comment "app-routing-system/nginx:http" -j KUBE-MARK-MASQ
-A KUBE-SEP-7PTWPOJIQ22BXKMQ -p tcp -m comment --comment "app-routing-system/nginx:http" -m tcp -j DNAT --to-destination 10.244.2.1:8080

-A KUBE-SVC-EEQNXCJLUUVUU2YK -d 10.0.199.21/32 ! -i azv+ -p tcp -m comment --comment "app-routing-system/nginx:http cluster IP" -j KUBE-MARK-MASQ
-A KUBE-SVC-EEQNXCJLUUVUU2YK -m comment --comment "app-routing-system/nginx:http -> 10.244.0.203:8080" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-GG5PHKGFOOREI2Y5
-A KUBE-SVC-EEQNXCJLUUVUU2YK -m comment --comment "app-routing-system/nginx:http -> 10.244.2.1:8080" -j KUBE-SEP-7PTWPOJIQ22BXKMQ

-A KUBE-SEP-GG5PHKGFOOREI2Y5 -s 10.244.0.203/32 -m comment --comment "app-routing-system/nginx:http" -j KUBE-MARK-MASQ
-A KUBE-SEP-GG5PHKGFOOREI2Y5 -p tcp -m comment --comment "app-routing-system/nginx:http" -m tcp -j DNAT --to-destination 10.244.0.203:8080

-A KUBE-SEP-7PTWPOJIQ22BXKMQ -s 10.244.2.1/32 -m comment --comment "app-routing-system/nginx:http" -j KUBE-MARK-MASQ
-A KUBE-SEP-7PTWPOJIQ22BXKMQ -p tcp -m comment --comment "app-routing-system/nginx:http" -m tcp -j DNAT --to-destination 10.244.2.1:8080
```

> ## example

- https://learn.microsoft.com/en-us/azure/aks/azure-cni-overlay?tabs=kubectl#create-an-example-workload
