```
az aks show -g $rg -n aks --query networkProfile.networkPlugin -otsv
```

- https://learn.microsoft.com/en-us/azure/aks/configure-kubenet
- https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni?tabs=configure-networking-portal

```
# Inbound 
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connection-issues-application-hosted-aks-cluster. Additional articles in this sub-section
# Inbound to apiserver
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/troubleshoot-cluster-connection-issues-api-server. Additional articles in this sub-section
# Outbound
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/basic-troubleshooting-outbound-connections. Additional articles in this sub-section
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/welcome-azure-kubernetes

```
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 1 --no-wait
az aks get-credentials -g $rg -n aks --overwrite-existing

rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aksdns -s $vmsize -c 3  --no-wait # Two coredns pods and an extra app node
az aks get-credentials -g rg -n aksdns --overwrite-existing
kubectl get po -A -owide | grep core
# kubectl run --image=nginx nginx --overrides='{ "spec": { "template": { "spec": { "nodeSelector": { "kubernetes.io/hostname": "aks-nodepool1-11195645-vmss000003" } } } } }' # non-coredns node
kubectl exec -it nginx -- curl ifconfig.me

# https://learn.microsoft.com/en-us/azure/application-gateway/ingress-controller-overview
rg=rgnet-managed
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 1 -a ingress-appgw --appgw-subnet-cidr 10.225.0.0/16 --enable-apiserver-vnet-integration --enable-azure-service-mesh --network-plugin=azure --network-policy=calico  --outbound-type=managedNATGateway --no-wait # --enable-private-cluster
az aks get-credentials -g rgnet-managed -n aks --overwrite-existing
kubectl get po -A

# https://github.com/VijayRod/demo/blob/master/container-storage/logs/network-subnet.md
rg=rgnet
az group create -n $rg -l $loc
az network vnet create -g $rg --name vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rg --vnet-name vnet -n akssubnet --address-prefixes 10.240.0.0/16 -o none 
subnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n akssubnet --query id -otsv)
az aks create -g $rg -n aks --vnet-subnet-id $subnetId -s $vmsize -c 1 --no-wait
az aks get-credentials -g rgnet -n aks --overwrite-existing
kubectl get po -A

rg=rgnet-storage
# --enable-azure-container-storage

kubectl cluster-info
date
```

```
az group delete -n rg -y --no-wait
az group delete -n rgnet -y --no-wait
az group delete -n rgnet-managed -y --no-wait
az group list -otable | grep -E '^rg|^repro' # startswith
```
