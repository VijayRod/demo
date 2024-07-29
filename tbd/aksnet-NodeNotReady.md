tbd This is for a node that does not have coredns.
```
iptables -A INPUT -p tcp --dport 10250 -j DROP

kubectl get no # aks-nodepool1-14945448-vmss000001   NotReady   agent   26m   v1.28.10

noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)  
az vmss run-command invoke -g $noderg -n aks-nodepool1-14945448-vmss000001 --command-id RunShellScript --instance-id 0 --scripts "iptables -D INPUT -p tcp --dport 10250 -j DROP" # ParentResourceNotFound due to node NotReady. 

# Tbd One mitigation strategy is to allow a few minutes for the remediator to take action.
```
