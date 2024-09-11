```
az aks show -g $rg -n aks --query networkProfile.loadBalancerProfile

az network lb show -g MC_rg_aks_swedencentral -n kubernetes
```

```
# load-balancer-backend-pool-type=nodeIP (tbd lb service provisioning with a higher node count)

rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aksnodeip --load-balancer-backend-pool-type=nodeIP -s $vmsize -c 1
az aks get-credentials -g $rg -n aksnodeip --overwrite-existing
az aks create -g $rg -n aksnodeipconfig --load-balancer-backend-pool-type=nodeIPConfiguration -s $vmsize -c 1
az aks get-credentials -g $rg -n aksnodeipconfig --overwrite-existing


az aks show -g $rg -n aksnodeip --query networkProfile.loadBalancerProfile.backendPoolType -otsv # nodeIP
az aks show -g $rg -n aksnodeipconfig --query networkProfile.loadBalancerProfile.backendPoolType -otsv # nodeIPConfiguration

az network lb address-pool show -g MC_rg_aksnodeip_swedencentral --lb-name kubernetes -n aksOutboundBackendPool
az network lb address-pool show -g MC_rg_aksnodeipconfig_swedencentral --lb-name kubernetes -n aksOutboundBackendPool # same
 
 
date
az aks scale -g $rg -n aksnodeip -c 10
date # 03:13 minutes
az aks scale -g $rg -n aksnodeipconfig -c 10
date # 03:13 minutes (same)
az aks scale -g $rg -n aksnodeip -c 1
az aks scale -g $rg -n aksnodeipconfig -c 1


kubectl delete po nginx
kubectl delete svc nginx
kubectl run nginx --image=nginx --port=80
sleep 5
kubectl get po nginx
date
kubectl expose po nginx --type=LoadBalancer
date # 1 second

az aks scale -g $rg -n aksnodeip -c 10
az aks scale -g $rg -n aksnodeipconfig -c 10

az aks get-credentials -g $rg -n aksnodeip --overwrite-existing
# az aks get-credentials -g $rg -n aksnodeipconfig --overwrite-existing
kubectl delete svc --all=true
kubectl delete po --all=true
kubectl run nginx --image=nginx --port=80
kubectl run nginx2 --image=nginx --port=80
kubectl run nginx3 --image=nginx --port=80
sleep 10
kubectl get po
kubectl expose po nginx --type=LoadBalancer
kubectl expose po nginx2 --type=LoadBalancer
kubectl expose po nginx3 --type=LoadBalancer
kubectl get svc -w

aksnodeip 27s
nginx        LoadBalancer   10.0.147.49   <pending>     80:32393/TCP   1s
nginx2       LoadBalancer   10.0.225.5    <pending>     80:31479/TCP   1s
nginx3       LoadBalancer   10.0.195.24   <pending>     80:31364/TCP   0s
nginx        LoadBalancer   10.0.147.49   74.241.233.125   80:32393/TCP   11s
nginx2       LoadBalancer   10.0.225.5    74.241.233.127   80:31479/TCP   19s
nginx3       LoadBalancer   10.0.195.24   74.241.233.165   80:31364/TCP   27s

aksnodeipconfig 25s (~same)
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
nginx        LoadBalancer   10.0.154.116   <pending>     80:31246/TCP   2s
nginx2       LoadBalancer   10.0.103.178   <pending>     80:32714/TCP   1s
nginx3       LoadBalancer   10.0.57.147    <pending>     80:31452/TCP   1s
nginx        LoadBalancer   10.0.154.116   74.241.216.83   80:31246/TCP   9s
nginx2       LoadBalancer   10.0.103.178   74.241.161.23   80:32714/TCP   17s
nginx3       LoadBalancer   10.0.57.147    74.241.167.112   80:31452/TCP   25s
```

```
# load-balancer-backend-pool-type=nodeIPConfiguration (legacy)

rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aksnodeipconfig --load-balancer-backend-pool-type=nodeIPConfiguration -s $vmsize -c 1
az aks get-credentials -g $rg -n aksnodeipconfig --overwrite-existing

az aks show -g $rg -n aksnodeipconfig --query networkProfile.loadBalancerProfile.backendPoolType -otsv # nodeIPConfiguration
# az network lb address-pool show -g MC_rg_aksnodeip_swedencentral --lb-name kubernetes -n aksOutboundBackendPool
```

- https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard#change-the-inbound-pool-type
