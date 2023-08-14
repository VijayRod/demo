These steps in https://learn.microsoft.com/en-us/azure/aks/learn/quick-windows-container-deploy-cli are used to create a cluster with a Windows node pool.

```
# Replace values in the below.
WINDOWS_USERNAME=azureuser
WINDOWS_PASSWORD=
rgname=testshack
clustername=akswin
```

```
# Create the cluster and the node pool.
az group create -n $rgname -l swedencentral
az aks create -g $rgname -n $clustername --windows-admin-username $WINDOWS_USERNAME --windows-admin-password $WINDOWS_PASSWORD --network-plugin azure
az aks nodepool add -g $rgname --cluster-name $clustername --name npwin --os-type Windows --mode user # --os-sku Windows2019
```

```
az aks get-credentials -g $rgname -n $clustername --overwrite-existing

kubectl get no --selector kubernetes.io/os=windows -owide

# Here is a sample output below.
# NAME             STATUS   ROLES   AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION    CONTAINER-RUNTIME
# aksnpwin000000   Ready    agent   30h   v1.25.6   10.224.0.153   <none>        Windows Server 2022 Datacenter   10.0.20348.1726   containerd://1.6.21+azure
# aksnpwin000001   Ready    agent   30h   v1.25.6   10.224.0.91    <none>        Windows Server 2022 Datacenter   10.0.20348.1726   containerd://1.6.21+azure
# aksnpwin000002   Ready    agent   30h   v1.25.6   10.224.0.122   <none>        Windows Server 2022 Datacenter   10.0.20348.1726   containerd://1.6.21+azure

kubectl get no --selector kubernetes.io/os=windows

# Here is a sample output below.
# NAME             STATUS   ROLES   AGE   VERSION
# aksnpwin000000   Ready    agent   29h   v1.25.6
# aksnpwin000001   Ready    agent   29h   v1.25.6
# aksnpwin000002   Ready    agent   29h   v1.25.6
```

```
# To cleanup
az group delete -n $rgname -y --no-wait
```

Here are some related links:
- [aks/node-access#create-the-ssh-connection-to-a-windows-node](https://learn.microsoft.com/en-us/azure/aks/node-access#create-the-ssh-connection-to-a-windows-node)
- [aks/windows-faq](https://learn.microsoft.com/en-us/azure/aks/windows-faq)
- [troubleshoot/azure/azure-kubernetes/capture-tcp-dump-windows-node-aks](https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/capture-tcp-dump-windows-node-aks).
