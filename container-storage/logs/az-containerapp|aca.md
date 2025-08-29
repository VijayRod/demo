- https://docs.azure.cn/en-us/container-apps/faq: Does Azure Container Apps provide direct access to the underlying Kubernetes API? No, Azure Container Apps doesn't provide direct access to the Kubernetes API.
- https://learn.microsoft.com/en-us/azure/well-architected/service-guides/azure-container-apps: Container Apps integrates with Azure Kubernetes Service (AKS) for advanced networking and monitoring
- https://azure.microsoft.com/en-us/products/category/containers: Frequently asked questions

```
# aca

rg=rgaca
# env=my-container-env; app=my-containerapp
az group create -g $rg -l $loc
az containerapp env create -g $rg -n env -l $loc # the default location is west us
az containerapp create -g $rg -n aca --environment env \
  --image mcr.microsoft.com/k8se/quickstart:latest \
  --target-port 80 --ingress external
  
# Microsoft.App/managedEnvironments
az containerapp env show -g $rg -n env --debug
domain=$(az containerapp env show -g $rg -n env --query properties.defaultDomain -otsv); echo $domain # mangoplant-02b6c085.swedencentral.azurecontainerapps.io
ip=$(az containerapp env show -g $rg -n env --query properties.staticIp -otsv); echo $ip
az containerapp env list --query "[?location=='Sweden Central']" -otable
az containerapp env delete -g $rg -n env -y

# Microsoft.App/containerApps
id=$(az containerapp show -g $rg -n aca --query id -otsv); echo $id
fqdn=$(az containerapp show -g $rg -n aca --query properties.configuration.ingress.fqdn -otsv); echo $fqdn # aca.amangoplant-02b6c085.swedencentral.azurecontainerapps.io
fqdn2=$(az containerapp show -g $rg -n aca --query properties.latestRevisionFqdn -otsv); echo $fqdn2 # aca--cwv16io.amangoplant-02b6c085.swedencentral.azurecontainerapps.io
```

```
# aca.network


```
- https://learn.microsoft.com/en-us/azure/container-apps/networking: Azure Container Apps operate in the context of an environment, which runs its own virtual network. 
- https://learn.microsoft.com/en-us/azure/well-architected/service-guides/azure-container-apps: Container Apps integrates with Azure Kubernetes Service (AKS) for advanced networking and monitoring


```
# aca.network.ingress

curl -v $fqdn # < HTTP/1.1 301 Moved Permanently
curl -v $fqdn2 # < HTTP/1.1 301 Moved Permanently
browser $fqdn or $fqdn2: Your container app is running with a Hello World image
```
