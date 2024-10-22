```
az aks command invoke -g $rg -n aks --command "kubectl get pods -n kube-system" # public/private cluster
command started at 2023-11-22 19:35:19+00:00, finished at 2023-11-22 19:35:19+00:00 with exitcode=0
NAME                                  READY   STATUS    RESTARTS   AGE
azure-ip-masq-agent-894qx             1/1     Running   0          3h30m
...

az aks command invoke -g $rg -n aks --command "kubectl get ns"
```
  
- https://azure.microsoft.com/en-us/updates/public-preview-of-azure-kubernetes-service-aks-runcommand-feature/
- https://learn.microsoft.com/en-us/azure/aks/access-private-cluster?tabs=azure-cli#run-commands-on-your-aks-cluster
