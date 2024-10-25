```
# Initialize CLI.
sudo apt-get update
## https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
# Initialize CLI - AKS i.e. kubectl.
## sudo -su
sudo az aks install-cli
az extension add --name aks-preview
## az extension add --source https://raw.githubusercontent.com/andyzhangx/demo/master/aks/rotate-tokens/aks_preview-0.5.0-py2.py3-none-any.whl -y

# update
sudo az aks install-cli
az extension update --name aks-preview
## extension update specific version

# Login.
az login
subId=
az account set -s $subId
az account show -s $subId --query isDefault

# query
az aks show -g $rg -n aks --query nodeResourceGroup -o tsv
az network private-link-service list -g $noderg --query "[].id" -o tsv
az network private-link-service list -g $noderg --query "[].{Name:name,Alias:alias}" -o table

# misc
az extension remove --name aks-preview
```

```
az aks install-cli
The detected architecture of current device is "x86_64", and the binary for "amd64" will be downloaded. If the detection is wrong, please download and install the binary corresponding to the appropriate architecture.
No version specified, will get the latest version of kubectl from "https://storage.googleapis.com/kubernetes-release/release/stable.txt"
Downloading client to "/usr/local/bin/kubectl" from "https://storage.googleapis.com/kubernetes-release/release/v1.31.0/bin/linux/amd64/kubectl"
Please ensure that /usr/local/bin is in your search PATH, so the `kubectl` command can be found.
No version specified, will get the latest version of kubelogin from "https://api.github.com/repos/Azure/kubelogin/releases/latest"
Downloading client to "/tmp/tmpj68fh6_s/kubelogin.zip" from "https://github.com/Azure/kubelogin/releases/download/v0.1.4/kubelogin.zip"
Moving binary to "/usr/local/bin/kubelogin" from "/tmp/tmpj68fh6_s/bin/linux_amd64/kubelogin"
Please ensure that /usr/local/bin is in your search PATH, so the `kubelogin` command can be found.

az extension update --name aks-preview
Default enabled including preview versions for extension installation now. Disabled in future release. Use '--allow-preview true' to enable it specifically if needed. Use '--allow-preview false' to install stable version only.
Latest version of 'aks-preview' is already installed.
Use --debug for more information
```

- https://docs.microsoft.com/en-us/cli/azure
