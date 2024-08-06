

```
rg=rgagc
az aks get-credentials -g $rg -n aks --overwrite-existing

kubectl apply -f https://trafficcontrollerdocs.blob.core.windows.net/examples/https-scenario/end-to-end-ssl-with-backend-mtls/deployment.yaml
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: gateway-01
  namespace: test-infra
  annotations:
    alb.networking.azure.io/alb-namespace: alb-test-infra
    alb.networking.azure.io/alb-name: alb-test
spec:
  gatewayClassName: azure-alb-external
  listeners:
  - name: https-listener
    port: 443
    protocol: HTTPS
    allowedRoutes:
      namespaces:
        from: Same
    tls:
      mode: Terminate
      certificateRefs:
      - kind : Secret
        group: ""
        name: frontend.com
EOF
kubectl get gateway gateway-01 -n test-infra -o yaml -w # message: Application Gateway For Containers resource has been successfully updated. reason: Programmed

kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: https-route
  namespace: test-infra
spec:
  parentRefs:
  - name: gateway-01
  rules:
  - backendRefs:
    - name: mtls-app
      port: 443
EOF
kubectl get httproute https-route -n test-infra -o yaml -w # message: Application Gateway For Containers resource has been successfully updated. reason: Programmed

kubectl apply -f - <<EOF
apiVersion: alb.networking.azure.io/v1
kind: BackendTLSPolicy
metadata:
  name: mtls-app-tls-policy
  namespace: test-infra
spec:
  targetRef:
    group: ""
    kind: Service
    name: mtls-app
    namespace: test-infra
  default:
    sni: backend.com
    ports:
    - port: 443
    clientCertificateRef:
      name: gateway-client-cert
      group: ""
      kind: Secret
    verify:
      caCertificateRef:
        name: ca.bundle
        group: ""
        kind: Secret
      subjectAltName: backend.com
EOF
kubectl get backendtlspolicy -n test-infra mtls-app-tls-policy -o yaml -w # message: Valid BackendTLSPolicy

fqdn=$(kubectl get gateway gateway-01 -n test-infra -o jsonpath='{.status.addresses[0].value}') # faeqexa4e6e7h9c0.fz20.alb.azure.com
curl --insecure https://$fqdn/ # Hello World!
# curl https://$fqdn/ -kI # HTTP/2 200 server: Microsoft-Azure-Application-LB/AGC
```

```
kubectl get all -n test-infra -owide
NAME                            READY   STATUS    RESTARTS   AGE   IP           NODE
NOMINATED NODE   READINESS GATES
pod/mtls-app-8446bfdb6c-c49pb   1/1     Running   0          14h   10.244.2.5   aks-nodepool1-25551052-vmss000002   <none>           <none>
pod/mtls-app-8446bfdb6c-jcjpk   1/1     Running   0          14h   10.244.1.6   aks-nodepool1-25551052-vmss000001   <none>           <none>
NAME               TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/mtls-app   ClusterIP   10.0.155.163   <none>        443/TCP   14h   app=mtls-app
NAME                       READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES         SELECTOR
deployment.apps/mtls-app   2/2     2            2           14h   mtls-app     nginx:1.23.2   app=mtls-app
NAME                                  DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES         SELECTOR
replicaset.apps/mtls-app-8446bfdb6c   2         2         2       14h   mtls-app     nginx:1.23.2   app=mtls-app,pod-template-hash=8446bfdb6c

kubectl describe po -n test-infra mtls-app-8446bfdb6c-c49pb | grep port -i
    Port:           8443/TCP
    Host Port:      0/TCP
kubectl run nginx --image=nginx
kubectl exec -it nginx -- curl https://10.244.2.5:8443 -kI # HTTP/1.1 200 OK Server: nginx/1.23.2
kubectl exec -it nginx -- curl https://10.0.155.163:443 -kI # HTTP/1.1 200 OK Server: nginx/1.23.2

kubectl get HealthCheckPolicy -n test-infra # No resources found in test-infra namespace.

kubectl get backendtlspolicy -n test-infra -oyaml | grep port -i
      ports:
      - port: 443
```

```
kubectl get svc -n test-infra mtls-app -ojsonpath='{.spec.clusterIP}' # 10.0.155.163
kubectl get svc -n test-infra mtls-app -ojsonpath='{.spec.ports[0].port}' # 443
kubectl exec -it nginx -- curl https://10.0.155.163 -k # Hello World!

kubectl get gateway -A -o yaml -ojsonpath='{.items[0].status}'
kubectl get httproute -A -o yaml -ojsonpath='{.items[0].status}'
kubectl get applicationloadbalancer -A -o yaml -ojsonpath='{.items[0].status}'
kubectl get backendtlspolicy -A -o yaml -ojsonpath='{.items[0].status}'

kubectl logs -n azure-alb-system -l app=alb-controller

kubectl get no -owide
kubectl get po -n test-infra -owide
kubectl get HealthCheckPolicy -n test-infra # no rows
```

```
kubectl delete po -n test-infra -l app=mtls-app
kubectl delete po -n azure-alb-system -l app=alb-controller
kubectl delete ns test-infra
```

```
kubectl get po -A -owide | grep -E 'alb|test'
azure-alb-system   alb-controller-686895c84-nswh2                       1/1     Running   0          30m     10.224.0.10   aks-nodepool1-22105430-vmss000002   <none>           <none>
azure-alb-system   alb-controller-686895c84-wcrnj                       1/1     Running   0          30m     10.224.0.73   aks-nodepool1-22105430-vmss000000   <none>           <none>
azure-alb-system   alb-controller-bootstrap-7cc55b5d6d-m7wfm            1/1     Running   0          30m     10.224.0.6    aks-nodepool1-22105430-vmss000002   <none>           <none>
test-infra         mtls-app-8446bfdb6c-7krvv                            1/1     Running   0          15m     10.224.0.25   aks-nodepool1-22105430-vmss000002   <none>           <none>
test-infra         mtls-app-8446bfdb6c-p4bbg                            1/1     Running   0          15m     10.224.0.71   aks-nodepool1-22105430-vmss000000   <none>           <none>

root@aks-nodepool1-22105430-vmss000000:/# tcpdump host 10.224.0.71

18:02:34.997269 IP 10.225.0.4.47789 > 10.224.0.71.8443: Flags [P.], seq 380093306:380093418, ack 2937599036, win 63, options [nop,nop,TS val 2587064154 ecr 3376795172], length 112
18:02:34.997430 IP 10.224.0.71.8443 > 10.225.0.4.47789: Flags [P.], seq 1:204, ack 112, win 509, options [nop,nop,TS val 3376800175 ecr 2587064154], length 203
18:02:34.998205 IP 10.225.0.4.47789 > 10.224.0.71.8443: Flags [.], ack 204, win 63, options [nop,nop,TS val 2587064155 ecr 3376800175], length 0

18:02:35.497632 IP 10.225.0.5.52783 > 10.224.0.71.8443: Flags [P.], seq 398968490:398968602, ack 1506581331, win 63, options [nop,nop,TS val 4243417713 ecr 2732720613], length 112
18:02:35.497870 IP 10.224.0.71.8443 > 10.225.0.5.52783: Flags [P.], seq 1:204, ack 112, win 509, options [nop,nop,TS val 2732725616 ecr 4243417713], length 203
18:02:35.498378 IP 10.225.0.5.52783 > 10.224.0.71.8443: Flags [.], ack 204, win 63, options [nop,nop,TS val 4243417714 ecr 2732725616], length 0

18:02:39.997954 IP 10.225.0.4.47789 > 10.224.0.71.8443: Flags [P.], seq 112:224, ack 204, win 63, options [nop,nop,TS val 2587069155 ecr 3376800175], length 112
18:02:39.998108 IP 10.224.0.71.8443 > 10.225.0.4.47789: Flags [P.], seq 204:407, ack 224, win 509, options [nop,nop,TS val 3376805176 ecr 2587069155], length 203
18:02:39.999008 IP 10.225.0.4.47789 > 10.224.0.71.8443: Flags [.], ack 407, win 63, options [nop,nop,TS val 2587069155 ecr 3376805176], length 0

18:02:40.502275 IP 10.225.0.5.52783 > 10.224.0.71.8443: Flags [P.], seq 112:224, ack 204, win 63, options [nop,nop,TS val 4243422717 ecr 2732725616], length 112
18:02:40.502520 IP 10.224.0.71.8443 > 10.225.0.5.52783: Flags [P.], seq 204:407, ack 224, win 509, options [nop,nop,TS val 2732730621 ecr 4243422717], length 203
18:02:40.503471 IP 10.225.0.5.52783 > 10.224.0.71.8443: Flags [.], ack 407, win 63, options [nop,nop,TS val 4243422719 ecr 2732730621], length 0

noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
az network vnet subnet show -g $noderg --vnet-name aks-vnet-64451649 -n subnet-alb --query addressPrefix -otsv # 10.225.0.0/24
```

- https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/how-to-backend-mtls-gateway-api?tabs=alb-managed
