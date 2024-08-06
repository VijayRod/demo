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
```

- https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/overview

```
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
