## agc

## agc.debug.install.1of3.alb-controller

```
rg=rgagc
az group create -n $rg -l westus # $loc
az aks create -g $rg -n aks -s $vmsize --network-plugin azure --enable-oidc-issuer --enable-workload-identity

RESOURCE_GROUP=$rg
AKS_NAME='aks'
IDENTITY_RESOURCE_NAME='azure-alb-identity'
mcResourceGroup=$(az aks show --resource-group $RESOURCE_GROUP --name $AKS_NAME --query "nodeResourceGroup" -o tsv)
mcResourceGroupId=$(az group show --name $mcResourceGroup --query id -otsv)
echo "Creating identity $IDENTITY_RESOURCE_NAME in resource group $RESOURCE_GROUP"
az identity create --resource-group $RESOURCE_GROUP --name $IDENTITY_RESOURCE_NAME
principalId="$(az identity show -g $RESOURCE_GROUP -n $IDENTITY_RESOURCE_NAME --query principalId -otsv)"
echo "Waiting 60 seconds to allow for replication of the identity..."
sleep 60
echo "Apply Reader role to the AKS managed cluster resource group for the newly provisioned identity"
az role assignment create --assignee-object-id $principalId --assignee-principal-type ServicePrincipal --scope $mcResourceGroupId --role "acdd72a7-3385-48ef-bd42-f606fba81ae7" # Reader role
echo "Set up federation with AKS OIDC issuer"
AKS_OIDC_ISSUER="$(az aks show -n "$AKS_NAME" -g "$RESOURCE_GROUP" --query "oidcIssuerProfile.issuerUrl" -o tsv)"
az identity federated-credential create --name "azure-alb-identity" --identity-name "$IDENTITY_RESOURCE_NAME" --resource-group $RESOURCE_GROUP --issuer "$AKS_OIDC_ISSUER" --subject "system:serviceaccount:azure-alb-system:alb-controller-sa"
sleep 60

# alb-controller install
HELM_NAMESPACE='default'
CONTROLLER_NAMESPACE='azure-alb-system'
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --overwrite-existing
helm install alb-controller oci://mcr.microsoft.com/application-lb/charts/alb-controller --namespace $HELM_NAMESPACE --version 1.0.2 --set albController.namespace=$CONTROLLER_NAMESPACE --set albController.podIdentity.clientID=$(az identity show -g $RESOURCE_GROUP -n azure-alb-identity --query clientId -o tsv)

az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get pods -n azure-alb-system
# kubectl logs -n azure-alb-system -l app=alb-controller
kubectl get gatewayclass azure-alb-external -o yaml -w # | grep message # status.conditions.message
```

```
alb-controller-7f78465797-cfhtw             1/1     Running   0          65s   app=alb-controller,azure.workload.identity/use=true,pod-template-hash=7f78465797
alb-controller-7f78465797-qzb8j             1/1     Running   0          65s   app=alb-controller,azure.workload.identity/use=true,pod-template-hash=7f78465797
alb-controller-bootstrap-7cc55b5d6d-tb586   1/1     Running   0          65s   app=alb-controller-bootstrap,pod-template-hash=7cc55b5d6d
    message: Valid GatewayClass

k get all -n azure-alb-system
NAME                                            READY   STATUS    RESTARTS   AGE
pod/alb-controller-76bfdcc5f4-4jq47             1/1     Running   0          37m
pod/alb-controller-76bfdcc5f4-n6v4f             1/1     Running   0          37m
pod/alb-controller-bootstrap-5684ffb8d7-zvszp   1/1     Running   0          37m

NAME                               TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)             AGE
service/alb-controller             ClusterIP   10.0.4.40      <none>        8000/TCP,8001/TCP   37m
service/alb-controller-bootstrap   ClusterIP   10.0.200.249   <none>        9005/TCP            37m

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/alb-controller             2/2     2            2           37m
deployment.apps/alb-controller-bootstrap   1/1     1            1           37m

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/alb-controller-76bfdcc5f4             2         2         2       37m
replicaset.apps/alb-controller-bootstrap-5684ffb8d7   1         1         1       37m
```

- https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/overview

## agc.debug.install.2of3.AGC

```
# AGC setup. The alb-controller manages the AGC

AKS_NAME='aks'
RESOURCE_GROUP=$rg
MC_RESOURCE_GROUP=$(az aks show --name $AKS_NAME --resource-group $RESOURCE_GROUP --query "nodeResourceGroup" -o tsv)
CLUSTER_SUBNET_ID=$(az vmss list --resource-group $MC_RESOURCE_GROUP --query '[0].virtualMachineProfile.networkProfile.networkInterfaceConfigurations[0].ipConfigurations[0].subnet.id' -o tsv)
read -d '' VNET_NAME VNET_RESOURCE_GROUP VNET_ID <<< $(az network vnet show --ids $CLUSTER_SUBNET_ID --query '[name, resourceGroup, id]' -o tsv)
SUBNET_ADDRESS_PREFIX='10.225.0.0/24' # <network address and prefix for an address space under the vnet that has at least 250 available addresses (/24 or larger subnet)>
ALB_SUBNET_NAME='subnet-alb' # subnet name can be any non-reserved subnet name (i.e. GatewaySubnet, AzureFirewallSubnet, AzureBastionSubnet would all be invalid)
az network vnet subnet create --resource-group $VNET_RESOURCE_GROUP --vnet-name $VNET_NAME --name $ALB_SUBNET_NAME --address-prefixes $SUBNET_ADDRESS_PREFIX --delegations 'Microsoft.ServiceNetworking/trafficControllers'
ALB_SUBNET_ID=$(az network vnet subnet show --name $ALB_SUBNET_NAME --resource-group $VNET_RESOURCE_GROUP --vnet-name $VNET_NAME --query '[id]' --output tsv)

IDENTITY_RESOURCE_NAME='azure-alb-identity'
MC_RESOURCE_GROUP=$(az aks show --name $AKS_NAME --resource-group $RESOURCE_GROUP --query "nodeResourceGroup" -otsv | tr -d '\r')
mcResourceGroupId=$(az group show --name $MC_RESOURCE_GROUP --query id -otsv)
principalId=$(az identity show -g $RESOURCE_GROUP -n $IDENTITY_RESOURCE_NAME --query principalId -otsv)
# Delegate AppGw for Containers Configuration Manager role to AKS Managed Cluster RG
az role assignment create --assignee-object-id $principalId --assignee-principal-type ServicePrincipal --scope $mcResourceGroupId --role "fbc52c3f-28ad-4303-a892-8a056630b8f1"
# Delegate Network Contributor permission for join to association subnet
az role assignment create --assignee-object-id $principalId --assignee-principal-type ServicePrincipal --scope $ALB_SUBNET_ID --role "4d97b98b-1d4f-4787-a291-c67834d212e7"

kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: alb-test-infra
EOF
kubectl apply -f - <<EOF
apiVersion: alb.networking.azure.io/v1
kind: ApplicationLoadBalancer
metadata:
  name: alb-test
  namespace: alb-test-infra
spec:
  associations:
  - $ALB_SUBNET_ID
EOF

kubectl get applicationloadbalancer alb-test -n alb-test-infra -o yaml -w # | grep "reason: Ready"
```

```
status:
  conditions:
  - lastTransitionTime: "2024-08-03T21:16:15Z"
    message: Valid Application Gateway for Containers resource
    observedGeneration: 1
    reason: Accepted
    status: "True"
    type: Accepted
  - lastTransitionTime: "2024-08-03T21:16:15Z"
    message: alb-id=/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rgagc_aks_westus/providers/Microsoft.ServiceNetworking/trafficControllers/alb-b4aa9f12
    observedGeneration: 1
    reason: Ready
    status: "True"
    type: Deployment
```

- https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/quickstart-create-application-gateway-for-containers-managed-by-alb-controller?tabs=new-subnet-aks-vnet

## agc.debug.install.3of3.nginx

```
# conn

noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
az network alb list -g $noderg -otable
agc=alb-b4aa9f12

albId=$(az network alb show -g $noderg -n $agc --query id -otsv); echo $albId
/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rgagc_aks_westus/providers/Microsoft.ServiceNetworking/trafficControllers/alb-b4aa9f12

albUrl=$(az network alb show -g $noderg -n $agc --query configurationEndpoints[0] -otsv); echo $albUrl
f989246f5c8f43179b0bd73c36268aaf.alb.azure.com

curl https://$albUrl # no rows

curl -v https://$albUrl

openssl s_client -connect $albUrl:443 -showcerts

echo $albId
kubectl delete ingress nginx-hello-ingress
kubectl delete svc nginx-hello-service
kubectl delete deploy nginx-hello
cat << EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
 name: nginx-hello
spec:
 replicas: 3
 selector:
   matchLabels:
     app: nginx-hello
 template:
   metadata:
     labels:
       app: nginx-hello
   spec:
     containers:
     - name: nginx-hello
       image: nginxdemos/hello
       ports:
       - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
 name: nginx-hello-service
spec:
 type: ClusterIP
 selector:
   app: nginx-hello
 ports:
   - protocol: TCP
     port: 80
     targetPort: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
 name: nginx-hello-ingress
 annotations:
   alb.networking.azure.io/alb-id: $albId
   #alb.networking.azure.io/alb-frontend: test-frontend
spec:
 ingressClassName: azure-alb-external
 rules:  
 - http:
     paths:
     - path: /
       pathType: Prefix
       backend:
         service:
           name: nginx-hello-service
           port:
             number: 80
EOF
sleep 10
kubectl get svc,po
kubectl get ing -w
# kubectl describe ing

NAME                  TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
kubernetes            ClusterIP   10.0.0.1       <none>        443/TCP   19h
nginx-hello-service   ClusterIP   10.0.192.131   <none>        80/TCP    30s

NAME                  CLASS                HOSTS   ADDRESS                               PORTS   AGE
nginx-hello-ingress   azure-alb-external   *       ftb9cteuexe9fphs.fz07.alb.azure.com   80      2m49s

k describe ingress
Name:             nginx-hello-ingress
Labels:           <none>
Namespace:        default
Address:          ftb9cteuexe9fphs.fz07.alb.azure.com
Ingress Class:    azure-alb-external
Default backend:  <default>
Rules:
  Host        Path  Backends
  ----        ----  --------
  *
              /   nginx-hello-service:80 (10.224.0.16:80,10.224.0.13:80,10.224.0.50:80)
Annotations:  alb.networking.azure.io/alb-id:
                /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rgagc_aks_westus/providers/Microsoft.ServiceNetworking/trafficContro...
Events:
  Type    Reason        Age                From                                Message
  ----    ------        ----               ----                                -------
  Normal  Accepted      10m (x2 over 10m)  Application Gateway for Containers
  Normal  ValidIngress  9m38s              Application Gateway for Containers  Ingress validated successfully
  
kubectl get ingress -oyaml
apiVersion: v1
items:
- apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    annotations:
      alb.networking.azure.io/alb-id: /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rgagc_aks_westus/providers/Microsoft.ServiceNetworking/trafficControllers/alb-b4aa9f12
    creationTimestamp: "2024-11-28T18:00:22Z"
    generation: 1
    name: nginx-hello-ingress
    namespace: default
    resourceVersion: "235307"
    uid: 8fa1155c-667c-41c3-8f42-e3b5f4d23516
  spec:
    ingressClassName: azure-alb-external
    rules:
    - http:
        paths:
        - backend:
            service:
              name: nginx-hello-service
              port:
                number: 80
          path: /
          pathType: Prefix
  status:
    loadBalancer:
      ingress:
      - hostname: ftb9cteuexe9fphs.fz07.alb.azure.com
        ports:
        - port: 80
          protocol: TCP
kind: List
metadata:
  resourceVersion: ""
  
k describe ingressclass
Name:         azure-alb-external
Labels:       <none>
Annotations:  <none>
Controller:   alb.networking.azure.io/alb-controller
Events:       <none>

url=ftb9cteuexe9fphs.fz07.alb.azure.com; curl http://$url

# on my desktop
curl -I http://ftb9cteuexe9fphs.fz07.alb.azure.com
HTTP/1.1 200 OK
server: Microsoft-Azure-Application-LB/AGC
date: Thu, 28 Nov 2024 18:13:42 GMT
content-type: text/html
expires: Thu, 28 Nov 2024 18:13:41 GMT
cache-control: no-cache
transfer-encoding: chunked

kubectl logs -n azure-alb-system -l app=alb-controller
Defaulted container "alb-controller" out of: alb-controller, init-alb-controller (init)
{"level":"info","version":"1.0.2","Timestamp":"2024-11-28T18:59:07.971458728Z","message":"Starting alb-controller"}
{"level":"info","version":"1.0.2","Timestamp":"2024-11-28T18:59:07.974446656Z","message":"Starting alb-controller version 1.0.2"}
{"level":"info","version":"1.0.2","Timestamp":"2024-11-28T18:59:08.914649347Z","message":"attempting to acquire leader lease azure-alb-system/alb-controller-leader-election...\n"}
... add ingress with the alb annotation
{"level":"info","version":"1.0.2","AGC":"alb-b4aa9f12","operationID":"ddc4b63b-3b27-41c9-883b-d38a80b8ce9e","Timestamp":"2024-11-28T19:01:04.885523248Z","message":"Building service routing config for Gateway API resources"}
{"level":"info","version":"1.0.2","AGC":"alb-b4aa9f12","operationID":"ddc4b63b-3b27-41c9-883b-d38a80b8ce9e","Timestamp":"2024-11-28T19:01:04.885532248Z","message":"Gateway API resources managed are : 0 Gateways, 0 HTTPRoutes, 0 BackendTLSPolicies, 0 FrontendTLSPolicies, 0 RoutePolicies"}
{"level":"info","version":"1.0.2","AGC":"alb-b4aa9f12","operationID":"ddc4b63b-3b27-41c9-883b-d38a80b8ce9e","Timestamp":"2024-11-28T19:01:04.885534948Z","message":"Successfully built service routing config for Gateway API resources"}
{"level":"info","version":"1.0.2","AGC":"alb-b4aa9f12","operationID":"ddc4b63b-3b27-41c9-883b-d38a80b8ce9e","Timestamp":"2024-11-28T19:01:04.885539348Z","message":"Building service routing config for Ingress resources"}
{"level":"info","version":"1.0.2","AGC":"alb-b4aa9f12","operationID":"ddc4b63b-3b27-41c9-883b-d38a80b8ce9e","Timestamp":"2024-11-28T19:01:04.885542048Z","message":"1 ingresses managed"}
{"level":"info","version":"1.0.2","AGC":"alb-b4aa9f12","operationID":"ddc4b63b-3b27-41c9-883b-d38a80b8ce9e","Timestamp":"2024-11-28T19:01:04.885870752Z","message":"Successfully built service routing config for Ingress resources"}
{"level":"info","version":"1.0.2","name":"events","type":"Normal","object":{"kind":"Ingress","namespace":"default","name":"nginx-hello-ingress","uid":"8fa1155c-667c-41c3-8f42-e3b5f4d23516","apiVersion":"networking.k8s.io/v1","resourceVersion":"235091"},"reason":"ValidIngress","Timestamp":"2024-11-28T19:01:04.885987753Z","message":"Ingress validated successfully"}
{"level":"info","version":"1.0.2","AGC":"alb-b4aa9f12","operationID":"ddc4b63b-3b27-41c9-883b-d38a80b8ce9e","Timestamp":"2024-11-28T19:01:04.886839463Z","message":"Sending config update to Application Gateway for Containers resource /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rgagc_aks_westus/providers/Microsoft.ServiceNetworking/trafficControllers/alb-b4aa9f12 with operation ID ddc4b63b-3b27-41c9-883b-d38a80b8ce9e"}
{"level":"info","version":"1.0.2","operationID":"ddc4b63b-3b27-41c9-883b-d38a80b8ce9e","Timestamp":"2024-11-28T19:01:04.887343768Z","message":"Successfully sent config update request"}
{"level":"info","version":"1.0.2","AGC":"alb-b4aa9f12","alb-resource-id":"/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rgagc_aks_westus/providers/Microsoft.ServiceNetworking/trafficControllers/alb-b4aa9f12","operationID":"ddc4b63b-3b27-41c9-883b-d38a80b8ce9e","Timestamp":"2024-11-28T19:01:05.124736051Z","message":"Application Gateway for Containers resource config update OPERATION_STATUS_SUCCESS with operation ID ddc4b63b-3b27-41c9-883b-d38a80b8ce9e"}
```
