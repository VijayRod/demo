```
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)  
az vmss run-command invoke -g $noderg -n aks-nodepool1-40004829-vmss --command-id RunShellScript --instance-id 0 --scripts "cat /etc/kubernetes/azure.json"
```

- https://learn.microsoft.com/en-us/azure/virtual-machines/windows/run-command
