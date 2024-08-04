tbd no healthy upstream

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
curl --insecure https://$fqdn/ # no healthy upstream
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

kubectl logs -n test-infra app=mtls-app
```

```
kubectl describe po -n test-infra mtls-app-8446bfdb6c-c49pb | grep port -i
    Port:           8443/TCP
    Host Port:      0/TCP
kubectl run nginx --image=nginx
kubectl exec -it nginx -- curl https://10.244.2.5:8443 -I
curl: (60) SSL certificate problem: unable to get local issuer certificate
kubectl exec -it nginx -- curl https://10.0.155.163:443 -I
curl: (60) SSL certificate problem: unable to get local issuer certificate

kubectl get backendtlspolicy -n test-infra -oyaml | grep port -i
      ports:
      - port: 443
```      

```
tbd
kubectl delete HealthCheckPolicy -n test-infra gateway-health-check-policy
kubectl apply -f - <<EOF
apiVersion: alb.networking.azure.io/v1
kind: HealthCheckPolicy
metadata:
  name: gateway-health-check-policy
  namespace: test-infra
spec:
  targetRef:
    group: ""
    kind: Service
    name: mtls-app
    namespace: test-infra
  default:
    interval: 5s
    timeout: 3s
    healthyThreshold: 1
    unhealthyThreshold: 1
    http:
      path: /
      match:
        statusCodes: 
        - start: 200
          end: 299
EOF
```

- https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/how-to-backend-mtls-gateway-api?tabs=alb-managed
