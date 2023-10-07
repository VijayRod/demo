```
rg=rgwin
az group create -n $rg -l $loc
az aks create -g $rg -n aks --windows-admin-username azureuser --network-plugin azure -s $vmsize --node-count 1 # Password - Required length: [14, 123].
az aks nodepool add -g $rg --cluster-name aks -n npwin --os-type Windows --node-count 1 -s $vmsize # --no-wait
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no
```

- https://github.com/Azure/AKS/tree/master/vhd-notes/AKSWindows
- https://learn.microsoft.com/en-us/azure/aks/learn/quick-windows-container-deploy-cli
- https://learn.microsoft.com/en-us/azure/aks/windows-faq
- https://learn.microsoft.com/en-us/azure/aks/node-access#create-the-ssh-connection-to-a-windows-node
