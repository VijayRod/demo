```
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 1 --network-plugin azure -a ingress-appgw --appgw-name myApplicationGateway --appgw-subnet-cidr "10.225.0.0/16"
az aks get-credentials -g $rg -n aks --overwrite-existing
az aks show -g $rg -n aks --query addonProfiles.ingressApplicationGateway
```

```
az aks show -n myCluster -g myResourceGroup --query addonProfiles.ingressApplicationGateway
The behavior of this command has been altered by the following extension: aks-preview
{
  "config": {
    "applicationGatewayName": "myApplicationGateway",
    "effectiveApplicationGatewayId": "/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/MC_myResourceGroup_myCluster_westus2/providers/Microsoft.Network/applicationGateways/myApplicationGateway",
    "subnetCIDR": "10.225.0.0/16"
  },
  "enabled": true,
  "identity": {
    "clientId": "dummyc-089b-41c8-a1e0-c69bb923d7d0",
    "objectId": "dummy0-3c6b-4233-b150-409f37831892",
    "resourceId": "/subscriptions/dummys-1111-1111-1111-111111111111/resourcegroups/MC_myResourceGroup_myCluster_westus2/providers/Microsoft.ManagedIdentity/userAssignedIdentities/ingressapplicationgateway-mycluster"
  }
}
```

```
# kubectl get ingressclass
NAME                        CONTROLLER                  PARAMETERS   AGE
azure-application-gateway   azure/application-gateway   <none>       14m

# kubectl get deploy -n kube-system -l app=ingress-appgw
NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
ingress-appgw-deployment   1/1     1            1           13m

# kubectl describe po -n kube-system -l app=ingress-appgw
Name:             ingress-appgw-deployment-b888bf865-bdwzp
  Normal   Pulling           12m   kubelet            Pulling image "mcr.microsoft.com/azure-application-gateway/kubernetes-ingress:1.5.3"

# kubectl logs -n kube-system -l app=ingress-appgw
I0812 04:06:44.743596       1 reflector.go:381] pkg/mod/k8s.io/client-go@v0.21.2/tools/cache/reflector.go:167: forcing resync

kubectl get cm -n kube-system -l app=ingress-appgw
```

- https://learn.microsoft.com/en-us/azure/application-gateway/ingress-controller-overview
  - https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-new
