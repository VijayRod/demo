```
root@aks-nodepool1-16663898-vmss000001:/# cat /etc/kubernetes/azure.json
{
    "cloud": "AzurePublicCloud",
    "tenantId": "redactt-1111-1111-1111-111111111111",
    "subscriptionId": "redacts-1111-1111-1111-111111111111",
    "aadClientId": "msi",
...

kubectl exec -it -n kube-system csi-azuredisk-node-grlf2 -c azuredisk -- cat /etc/kubernetes/azure.json # On Windows, use "type c:\k\azure.json"
{
    "cloud": "AzurePublicCloud",
...
```

- https://cloud-provider-azure.sigs.k8s.io/install/configs/: This doc describes cloud provider config file...
- https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure.md: The azure provider will reference a configuration file called azure.json
- https://learn.microsoft.com/en-us/azure-stack/user/azure-stack-kubernetes-aks-engine-deploy-cluster#update-each-node-manually: Use the new credentials provided by your cloud operator to update /etc/kubernetes/azure.json on each node. After making the update, restart both kubele and kube-controller-manager.
- https://learn.microsoft.com/en-us/azure/aks/kubernetes-service-principal?tabs=azure-cli#other-considerations: On the agent node VMs in the Kubernetes cluster, the service principal credentials are stored in the /etc/kubernetes/azure.json file.
- https://stackoverflow.com/questions/47350353/where-to-find-kubernetes-api-credentials-with-aks: When your Kubernetes cluster is created by ACS, a file named /etc/kubernetes/azure.json is created to store the Azure credentials for API access. Kubernetes uses this file for the Azure cloud provider.
- https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/docs/csi-debug.md#case2-volume-mountunmount-failed: get cloud config file(azure.json)
