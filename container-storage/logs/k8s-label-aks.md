```
az aks nodepool update -g $rg --cluster-name aks -n nodepool1 --labels dept=ACCT costcenter=6000 --no-wait

az aks nodepool show -g $rg --cluster-name aks -n nodepool1 --query nodeLabels
The behavior of this command has been altered by the following extension: aks-preview
{
  "costcenter": "6000",
  "dept": "ACCT"
}

az aks show -g $rg -n aks --query agentPoolProfiles[0].nodeLabels
The behavior of this command has been altered by the following extension: aks-preview
{
  "costcenter": "6000",
  "dept": "ACCT"
}

kubectl get nodes --show-labels | grep -e "costcenter=6000" -e "dept=ACCT"

kubectl describe no
Name:               aks-nodepool1-41806358-vmss000000
Roles:              agent
Labels:             agentpool=nodepool1
                    beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    costcenter=6000
                    dept=ACCT
```
                    
- https://learn.microsoft.com/en-us/azure/aks/use-labels
