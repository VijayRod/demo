```
# ddos.azure-ddos

rg=rg
az group create -n $rg -l $loc
az network ddos-protection create -g $rg -n MyDdosProtectionPlan

az network ddos-protection show -g $rg -n MyDdosProtectionPlan --query id -otsv
/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.Network/ddosProtectionPlans/MyDdosProtectionPlan
```

- https://learn.microsoft.com/en-us/azure/ddos-protection/manage-ddos-protection-cli
- https://learn.microsoft.com/en-us/azure/ddos-protection/ddos-protection-overview: Azure DDoS Protection protects at layer 3 and layer 4 network layers. For web applications protection at layer 7, you need to add protection at the application layer using a WAF offering. 
