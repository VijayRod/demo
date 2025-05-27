> ## agic

- https://learn.microsoft.com/en-us/azure/application-gateway/ingress-controller-expose-service-over-http-https
- https://learn.microsoft.com/en-us/azure/application-gateway/quick-create-cli
- https://github.com/Azure/application-gateway-kubernetes-ingress/blob/master/docs/setup/install.md
- https://github.com/Azure/application-gateway-kubernetes-ingress/tree/master/pkg/appgw
- https://azure.github.io/application-gateway-kubernetes-ingress/

```
rg=rgagic
az group create -n $rg -l $loc
az aks create -g $rg -n aks --network-plugin azure -a ingress-appgw --appgw-name myApplicationGateway --appgw-subnet-cidr 10.225.0.0/16

appGatewayId=$(az aks show -g $rg -n aks -o tsv --query addonProfiles.ingressApplicationGateway.config.effectiveApplicationGatewayId); echo $appGatewayId
appGatewaySubnetId=$(az network application-gateway show --ids $appGatewayId -o tsv --query gatewayIPConfigurations[0].subnet.id); echo $appGatewaySubnetId
agicAddonIdentity=$(az aks show -g $rg -n aks -o tsv --query addonProfiles.ingressApplicationGateway.identity.clientId); echo $agicAddonIdentity
az role assignment create --assignee $agicAddonIdentity --scope $appGatewaySubnetId --role "Network Contributor"

# appGatewayId: /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rgagic_aks_swedencentral/providers/Microsoft.Network/applicationGateways/myApplicationGateway
# appGatewaySubnetId: /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rgagic_aks_swedencentral/providers/Microsoft.Network/virtualNetworks/aks-vnet-85961757/subnets/myApplicationGateway-subnet

az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get po -A; kubectl get no
k get ing

k get ingressclass
NAME                        CONTROLLER                  PARAMETERS   AGE
azure-application-gateway   azure/application-gateway   <none>       97m

k get po -A | grep ingress
k logs -n kube-system -l app=ingress-appgw
kube-system   ingress-appgw-deployment-555fb448cd-gbnbx            1/1     Running   1 (91m ago)   93m

Name:             ingress-appgw-deployment-555fb448cd-gbnbx
Namespace:        kube-system
Priority:         0
Service Account:  ingress-appgw-sa
Node:             aks-nodepool1-12969479-vmss000001/10.224.0.4
Start Time:       Tue, 27 May 2025 18:03:56 +0000
Labels:           app=ingress-appgw
                  kubernetes.azure.com/managedby=aks
                  pod-template-hash=555fb448cd
Annotations:      checksum/config: a20a26166740b87d2ca11ef047cde69645f3040b21ba5f60763e7c03e19d4d42
                  cluster-autoscaler.kubernetes.io/safe-to-evict: true
                  kubernetes.azure.com/metrics-scrape: true
                  prometheus.io/path: /metrics
                  prometheus.io/port: 8123
                  prometheus.io/scrape: true
                  resource-id:
                    /subscriptions/efec8e52-e1ad-4ae1-8598-f243e56e2b08/resourceGroups/rgagic2/providers/Microsoft.ContainerService/managedClusters/aks
Status:           Running
IP:               10.224.0.14
IPs:
  IP:           10.224.0.14
Controlled By:  ReplicaSet/ingress-appgw-deployment-555fb448cd
Containers:
  ingress-appgw-container:
    Container ID:   containerd://a2918bdf93c0318d1bcbeda2f560f92c78efa40a1cfcf769f59e24f851077523
    Image:          mcr.microsoft.com/azure-application-gateway/kubernetes-ingress:1.8.1
    
k get deploy -n kube-system
NAME                                READY   UP-TO-DATE   AVAILABLE   AGE
ingress-appgw-deployment            1/1     1            1           95m
```

- https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-new
- https://azure.github.io/application-gateway-kubernetes-ingress/proposals/multiple-gateways-single-cluster.md

```
# ing.http
kubectl delete ing secure-ingress
kubectl delete deploy https-backend
kubectl delete svc https-backend 
kubectl create deployment https-backend \
  --image=hashicorp/http-echo \
  --port=5678 \
  -- /http-echo -text="Hello via HTTPS"
kubectl expose deployment https-backend \
  --name=https-backend \
  --port=443 \
  --target-port=5678
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: secure-ingress
spec:
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: https-backend
                port:
                  number: 443
EOF
kubectl get ing
kubectl describe ing
root@aks-nodepool1-12969479-vmss000000:/# curl 10.224.0.73:5678
Hello via HTTPS
```

```
# ing.https
# az network application-gateway: replace the resource group and name if needed
openssl req -x509 -newkey rsa:4096 -days 365 -nodes \
  -keyout rootCA.key -out rootCA.crt -subj "/CN=RootCA"
openssl req -new -newkey rsa:4096 -nodes -keyout backend.key -out backend.csr \
  -subj "/CN=backend.default.svc.cluster.local"
openssl x509 -req -in backend.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial \
  -out backend.crt -days 365
kubectl create secret tls backend-tls \
  --key backend.key \
  --cert backend.crt
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
az network application-gateway root-cert create \
  --resource-group $noderg \
  --gateway-name myApplicationGateway \
  --name my-root-cert \
  --cert-file rootCA.crt
kubectl delete ing secure-ingress
kubectl delete deploy https-backend
kubectl delete svc https-backend 
kubectl create deployment https-backend \
  --image=hashicorp/http-echo \
  --port=5678 \
  -- /http-echo -text="Hello via HTTPS"
kubectl expose deployment https-backend \
  --name=https-backend \
  --port=443 \
  --target-port=5678
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: secure-ingress
  annotations:
    appgw.ingress.kubernetes.io/backend-protocol: "https"
    appgw.ingress.kubernetes.io/appgw-trusted-root-certificate: my-root-cert
spec:
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: https-backend
                port:
                  number: 443
EOF
kubectl get ing
kubectl describe ing
root@aks-nodepool1-12969479-vmss000000:/# curl 10.224.0.73:5678
Hello via HTTPS

az network application-gateway show -g $noderg -n myApplicationGateway --query trustedRootCertificates
[
  {
    "data": "LS0tLS1CRUd..LS0tLS0K",
    "etag": "W/\"514829a0-80ba-476c-86da-7b2d714976b1\"",
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rgagic2_aks_swedencentral/providers/Microsoft.Network/applicationGateways/myApplicationGateway/trustedRootCertificates/my-root-cert",
    "name": "my-root-cert",
    "provisioningState": "Succeeded",
    "resourceGroup": "MC_rgagic2_aks_swedencentral",
    "type": "Microsoft.Network/applicationGateways/trustedRootCertificates"
  }
]
```

> ## tbd app-routing-system

```
k get all -n app-routing-system --show-labels
NAME                         READY   STATUS    RESTARTS   AGE   LABELS
pod/nginx-85497484cc-ndxdh   1/1     Running   0          34m   app.kubernetes.io/component=ingress-controller,app.kubernetes.io/managed-by=aks-app-routing-operator,app=nginx,pod-template-hash=85497484cc
pod/nginx-85497484cc-tqplw   1/1     Running   0          34m   app.kubernetes.io/component=ingress-controller,app.kubernetes.io/managed-by=aks-app-routing-operator,app=nginx,pod-template-hash=85497484cc

NAME                    TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE   LABELS
service/nginx           LoadBalancer   10.0.126.43    9.223.4.162   80:31711/TCP,443:30682/TCP   34m   app.kubernetes.io/component=ingress-controller,app.kubernetes.io/managed-by=aks-app-routing-operator,app.kubernetes.io/name=nginx
service/nginx-metrics   ClusterIP      10.0.157.141   <none>        10254/TCP                    34m   app.kubernetes.io/component=ingress-controller,app.kubernetes.io/managed-by=aks-app-routing-operator,app.kubernetes.io/name=nginx

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE   LABELS
deployment.apps/nginx   2/2     2            2           34m   app.kubernetes.io/component=ingress-controller,app.kubernetes.io/managed-by=aks-app-routing-operator,app.kubernetes.io/name=nginx

NAME                               DESIRED   CURRENT   READY   AGE   LABELS
replicaset.apps/nginx-85497484cc   2         2         2       34m   app.kubernetes.io/component=ingress-controller,app.kubernetes.io/managed-by=aks-app-routing-operator,app=nginx,pod-template-hash=85497484cc

NAME                                        REFERENCE          TARGETS       MINPODS   MAXPODS   REPLICAS   AGE   LABELS
horizontalpodautoscaler.autoscaling/nginx   Deployment/nginx   cpu: 0%/70%   2         100       2          34m   app.kubernetes.io/component=ingress-controller,app.kubernetes.io/managed-by=aks-app-routing-operator,app.kubernetes.io/name=nginx

k describe -n app-routing-system deployment.apps/nginx
Pod Template:
  Labels:           app=nginx
                    app.kubernetes.io/component=ingress-controller
                    app.kubernetes.io/managed-by=aks-app-routing-operator
  Annotations:      prometheus.io/port: 10254
                    prometheus.io/scrape: true
  Service Account:  nginx
  Containers:
   controller:
    Image:           mcr.microsoft.com/oss/kubernetes/ingress/nginx-ingress-controller:v1.11.2
    Ports:           8080/TCP, 8443/TCP, 10254/TCP
    Host Ports:      0/TCP, 0/TCP, 0/TCP
    SeccompProfile:  RuntimeDefault
    Args:
      /nginx-ingress-controller
      --ingress-class=webapprouting.kubernetes.azure.com
      --controller-class=webapprouting.kubernetes.azure.com/nginx
      
k get ingressclass
NAME                                 CONTROLLER                                 PARAMETERS   AGE
webapprouting.kubernetes.azure.com   webapprouting.kubernetes.azure.com/nginx   <none>       55m

k describe ingressclass
Name:         webapprouting.kubernetes.azure.com
Labels:       app.kubernetes.io/managed-by=aks-app-routing-operator
              app.kubernetes.io/name=nginx
Annotations:  <none>
Controller:   webapprouting.kubernetes.azure.com/nginx
Events:       <none>
```

```
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no; kubectl get po -A

# kube-system   ingress-appgw-deployment-c77b7c6bc-2nfvj        1/1     Running   1 (20m ago)   22m
k describe po -n kube-system -l app=ingress-appgw
k logs -n kube-system -l app=ingress-appgw

kubectl apply -f https://raw.githubusercontent.com/Azure/application-gateway-kubernetes-ingress/master/docs/examples/aspnetapp.yaml
kubectl get ingress

curl 9.223.58.10 -I # ing.ADDRESS. HTTP/1.1 404 Not Found. Server: Microsoft-Azure-Application-Gateway/v2
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>Microsoft-Azure-Application-Gateway/v2</center>
</body>
</html>

az network application-gateway show -g MC_rg_aks_swedencentral -n myApplicationGateway --query httpListeners
```

> ## agic.cluster-existing

```
# agic.cluster-existing.azure-cni

rg=rgagic
az group create -n $rg -l $loc
## deploy the cluster (simulate existing)
az aks create -g $rg -n aks --network-plugin azure -s $vmsize
## deploy the application gateway (simulate existing)
az network public-ip create -g $rg -n myPublicIp --allocation-method Static --sku Standard
az network vnet create -g $rg -n myVnet --address-prefix 10.0.0.0/16 --subnet-name mySubnet --subnet-prefix 10.0.0.0/24 
az network application-gateway create -g $rg -n myApplicationGateway --sku Standard_v2 --public-ip-address myPublicIp --vnet-name myVnet --subnet mySubnet --priority 100
appgwId=$(az network application-gateway show -g $rg -n myApplicationGateway -o tsv --query id); echo $appgwId
### /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rgagic/providers/Microsoft.Network/applicationGateways/myApplicationGateway
## enable agic
az aks enable-addons -g $rg -n aks --addon ingress-appgw --appgw-id $appgwId
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no; kubectl get po -A

az aks show -g $rg -n aks --query addonProfiles.ingressApplicationGateway
{
  "config": {
    "applicationGatewayId": "/subscriptions/efec8e52-e1ad-4ae1-8598-f243e56e2b08/resourceGroups/rgagic/providers/Microsoft.Network/applicationGateways/myApplicationGateway",
    "effectiveApplicationGatewayId": "/subscriptions/efec8e52-e1ad-4ae1-8598-f243e56e2b08/resourceGroups/rgagic/providers/Microsoft.Network/applicationGateways/myApplicationGateway"
  },
  "enabled": true,
  "identity": {
    "clientId": "bf0ef0cf-9ca0-42a0-8249-181ed7b973f1",
    "objectId": "82f52c5b-0974-461d-9376-122b4f1a0253",
    "resourceId": "/subscriptions/efec8e52-e1ad-4ae1-8598-f243e56e2b08/resourcegroups/MC_rgagic_aks_swedencentral/providers/Microsoft.ManagedIdentity/userAssignedIdentities/ingressapplicationgateway-aks"
  }
}

az resource list -g MC_rgagic_aks_swedencentral -otable
Name                                  ResourceGroup                Location       Type                                              Status
------------------------------------  ---------------------------  -------------  ------------------------------------------------  --------
ingressapplicationgateway-aks         MC_rgagic_aks_swedencentral  swedencentral  Microsoft.ManagedIdentity/userAssignedIdentities
```
- https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-existing

```
# agic.cluster-existing.azure-cni.overlay

(tbd due to IngressAppGwAddonConfigCannotUseSubnet)
rg=rgagicoverlay
az group create -n $rg -l $loc
## deploy the cluster (simulate existing)
az aks create -g $rg -n aks --network-plugin azure --network-plugin-mode overlay --pod-cidr 192.168.0.0/16 -s $vmsize
## deploy the application gateway (simulate existing)
az network public-ip create -g $rg -n myPublicIp --allocation-method Static --sku Standard
az network vnet create -g $rg -n myVnet --address-prefix 10.0.0.0/16 --subnet-name mySubnet --subnet-prefix 10.0.0.0/24 
az network application-gateway create -g $rg -n myApplicationGateway --sku Standard_v2 --public-ip-address myPublicIp --vnet-name myVnet --subnet mySubnet --priority 100
appgwId=$(az network application-gateway show -g $rg -n myApplicationGateway -o tsv --query id); echo $appgwId
### /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rgagic/providers/Microsoft.Network/applicationGateways/myApplicationGateway
## enable agic
az aks enable-addons -g $rg -n aks --addon ingress-appgw --appgw-id $appgwId --aks-custom-headers AKSHTTPCustomFeatures=Microsoft.ContainerService/AppGatewayWithOverlayPreview
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no; kubectl get po -A
```
- https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-existing: If you are planning on using AGIC with an AKS cluster using CNI Overlay, specify the parameter --aks-custom-headers AKSHTTPCustomFeatures=Microsoft.ContainerService/AppGatewayWithOverlayPreview to configure AGIC to handle connectivity to the CNI Overlay enabled cluster.
- https://github.com/Azure/AKS/issues/3641: [Feature] Azure CNI Overlay with AGIC Support

```
# agic.cluster-existing.azure-cni.overlay.error.IngressAppGwAddonConfigCannotUseSubnet

rg=rgagicoverlay
az aks create -g $rg -n aks --network-plugin azure --network-plugin-mode overlay --pod-cidr 192.168.0.0/16 -s $vmsize
az network public-ip create -g $rg -n myPublicIp --allocation-method Static --sku Standard
az network vnet create -g $rg -n myVnet --address-prefix 10.0.0.0/16 --subnet-name mySubnet --subnet-prefix 10.0.0.0/24 
az network application-gateway create -g $rg -n myApplicationGateway --sku Standard_v2 --public-ip-address myPublicIp --vnet-name myVnet --subnet mySubnet --priority 100
appgwId=$(az network application-gateway show -g $rg -n myApplicationGateway -o tsv --query id); echo $appgwId
az aks enable-addons -g $rg -n aks --addon ingress-appgw --appgw-id $appgwId --aks-custom-headers AKSHTTPCustomFeatures=Microsoft.ContainerService/AppGatewayWithOverlayPreview

(IngressAppGwAddonConfigCannotUseSubnet) In Azure CNI Overlay clusters with AGIC cluster node subnet and AGIC subnet must be on the same VNET. AGIC VNET id: /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rgagicoverlay/providers/Microsoft.Network/virtualNetworks/myVnet, cluster node VNET id: /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rgagicoverlay_aks_swedencentral/providers/Microsoft.Network/virtualNetworks/aks-vnet-36589243
```
