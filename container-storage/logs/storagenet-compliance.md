## compliance.hippa

- https://www.hhs.gov/hipaa/for-professionals/privacy/laws-regulations/index.html
- https://www.hhs.gov/hipaa/index.html

## compliance.fips.aks

```
rg=rg5
az group create -n $rg -l swedencentral
az aks create -g $rg -n aks # -s Standard_B2ms -c 1
az aks nodepool add -g $rg --cluster-name aks -n fipsnp --enable-fips-image
az aks get-credentials -g $rg -n aks --overwrite-existing
az aks show -g $rg -n aks --query="agentPoolProfiles[].{Name:name enableFips:enableFips}" -o table

Name       EnableFips
---------  ------------
fipsnp     True
nodepool1  False
```

```
az aks create -g $rg -n aks2 --enable-fips-image
az aks show -g $rg -n aks2 --query="agentPoolProfiles[].{Name:name enableFips:enableFips}" -o table

Name       EnableFips
---------  ------------
nodepool1  True
```

- https://learn.microsoft.com/en-us/azure/aks/enable-fips-nodes
- https://github.com/Azure/AgentBaker/tree/master/vhdbuilder/release-notes/AKSAzureLinux/gen2fips
- https://github.com/Azure/AgentBaker/tree/master/vhdbuilder/release-notes/AKSUbuntu/gen2/2004fipscontainerd
