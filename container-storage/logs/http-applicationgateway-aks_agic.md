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
```

- https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-new
- https://azure.github.io/application-gateway-kubernetes-ingress/proposals/multiple-gateways-single-cluster.md

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
