```
rgname=testshack
loc=swedencentral
apim="myapim$RANDOM"

az group create -n $rgname -l $loc
az apim create -g $rgname -n $apim \
  --publisher-name Contoso --publisher-email admin@contoso.com \
  --no-wait ## 40 minutes to create and activate
az apim show -g $rgname -n $apim -o table

az aks create -g $rgname -n aksapim
az aks get-credentials -g $rgname -n aksapim --overwrite-existing

# https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-provision-self-hosted-gateway

# https://learn.microsoft.com/en-us/azure/api-management/how-to-deploy-self-hosted-gateway-kubernetes
```

```
kubectl get all
NAME                      READY   STATUS    RESTARTS   AGE
pod/aks-fdccfcfb9-hsxb7   1/1     Running   0          28s
NAME                             TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE
service/aks-instance-discovery   ClusterIP      None           <none>           4290/UDP,4291/UDP            29s
service/aks-live-traffic         LoadBalancer   10.0.104.175   20.240.173.132   80:31036/TCP,443:32034/TCP   29s
service/kubernetes               ClusterIP      10.0.0.1       <none>           443/TCP                      69m
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/aks   1/1     1            1           30s
NAME                            DESIRED   CURRENT   READY   AGE
replicaset.apps/aks-fdccfcfb9   1         1         1       30s

kubectl describe service/aks-live-traffic
Name:                     aks-live-traffic
Namespace:                default
Labels:                   app=aks
Annotations:              <none>
Selector:                 app=aks
Type:                     LoadBalancer
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.0.104.175
IPs:                      10.0.104.175
LoadBalancer Ingress:     20.240.173.132
Port:                     http  80/TCP
TargetPort:               8080/TCP
NodePort:                 http  31036/TCP
Endpoints:                10.244.1.3:8080
Port:                     https  443/TCP
TargetPort:               8081/TCP
NodePort:                 https  32034/TCP
Endpoints:                10.244.1.3:8081
Session Affinity:         None
External Traffic Policy:  Local
HealthCheck NodePort:     30461

curl 20.240.173.132
{ "statusCode": 404, "message": "Resource not found" }

kubectl logs -l app=aks | grep tail
[Info] 2023-08-25T10:56:03.147 [GatewayLogs], isRequestSuccess: False, totalTime: 210, category: GatewayLogs, callerIpAddress: 148.redacted.redacted.redacted, timeGenerated: 2023-08-25T10:56:03.147, region: swedencentral, correlationId: 078cebd2-b788-4352-bca8-29737450d984, method: GET, url: http://20.240.173.132/, responseCode: 404, responseSize: 130, cache: none, clientProtocol: HTTP/1.1, lastError: {
  "elapsed": 168,
  "source": "configuration",
  "reason": "OperationNotFound",
  "message": "Unable to match incoming request to an operation.",
  "section": "backend"
}, correlationId: 078cebd2-b788-4352-bca8-29737450d984

az group delete -n $rgname -y --no-wait
```

- https://learn.microsoft.com/en-us/azure/api-management/how-to-deploy-self-hosted-gateway-kubernetes
- https://learn.microsoft.com/en-us/azure/api-management/self-hosted-gateway-overview
