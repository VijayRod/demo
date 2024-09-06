```
# Initialize CLI.
sudo apt-get update
## https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
# Initialize CLI - AKS i.e. kubectl.
## sudo -su
sudo az aks install-cli
az extension add --name aks-preview
az extension update --name aks-preview
## extension update specific version
az extension remove --name aks-preview
## az extension add --source https://raw.githubusercontent.com/andyzhangx/demo/master/aks/rotate-tokens/aks_preview-0.5.0-py2.py3-none-any.whl -y

# Login.
az login
subId=
az account set -s $subId
az account show -s $subId --query isDefault

# query
az network private-link-service list -g $noderg --query "[].{Name:name,Alias:alias}" -o table
```

- https://docs.microsoft.com/en-us/cli/azure
