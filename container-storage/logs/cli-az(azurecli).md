> ## cli

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

# login
az login
subId=
az account set -s $subId
az account show -s $subId --query isDefault
# az account subscription list -otable

# login - tenant
az account tenant list
az login -t redactt-1111-1111-1111-111111111111 # --use-device-code # tenant ID
az login -t redactt-1111-1111-1111-111111111111 --debug --verbose # msal.oauth2cli.authcode: Open a browser on this device to visit: https:...

# query
az aks show -g $rg -n aks --query nodeResourceGroup -o tsv # MC_rgredis12_aks_swedencentral
az aks show -g $rg -n aks | jq .nodeResourceGroup # "MC_rgredis12_aks_swedencentral"
az aks show -g $rg -n aks | jq .agentPoolProfiles[0] # az aks show -g $rg -n aks --query agentPoolProfiles[0]
{
  "artifactStreamingProfile": null,
  "availabilityZones": null,
  "capacityReservationGroupId": null,
  "count": 2,
...
az aks show -g $rg -n aks | jq .agentPoolProfiles[0].count # az aks show -g $rg -n aks --query agentPoolProfiles[0].count # 2
az network private-link-service list -g $noderg --query "[].id" -o tsv
az network private-link-service list -g $noderg --query "[].{Name:name,Alias:alias}" -o table
az acr login -n $registry --expose-token | jq .accessToken
az aks show -g $rg -n aks | jq .accessToken

# misc
az extension remove --name aks-preview
```

- https://docs.microsoft.com/en-us/cli/azure
- https://github.com/azure/azure-cli/releases: for the most recent version of azure-cli and approximately when it became publicly available as an upgrade (in azure-cli).
- https://github.com/MicrosoftDocs/azure-docs-cli/pulls?q=is%3Apr+is%3Aopen+release+note: PR detailing the fixes that have been included for the upcoming release
- https://learn.microsoft.com/en-us/cli/azure/release-notes-azure-cli

> ## cli..dev
- https://github.com/Azure/azure-cli-dev-tools?tab=readme-ov-file: azdev extension create or azdev cli create <module-name>

> ## cli..extension
- https://github.com/Azure/azure-cli-extensions
- https://github.com/Azure/azure-cli/tree/dev/doc/extensions

> ## cli..extension.core.serviceconnector
- https://github.com/Azure/azure-cli/tree/dev/src/azure-cli/azure/cli/command_modules/serviceconnector
  
> ## cli..extension.dev
- https://github.com/Azure/azure-cli-dev-tools?tab=readme-ov-file: azdev extension create or azdev cli create <module-name>
- https://github.com/Azure/azure-cli/blob/dev/doc/extensions/authoring.md: Development of extensions have been simplified by the public release of the azdev CLI.
  
> ## cli.aks

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

- https://learn.microsoft.com/en-us/cli/azure/release-notes-azure-cli#aks
- https://github.com/Azure/AKS/blob/master/CHANGELOG.md: CLI
- https://github.com/Azure/azure-cli/tree/dev/src/azure-cli/azure/cli/command_modules/acs

> ## cli.aks.aks-preview
- https://github.com/Azure/azure-cli-extensions/tree/main/src/aks-preview
- https://github.com/Azure/azure-cli-extensions/blob/main/src/aks-preview/HISTORY.rst
- https://github.com/Azure/azure-cli-extensions/blob/main/src/aks-preview/azext_aks_preview/_help.py

> ## cli.ps

```
# Initialize Azure PowerShell (admin window)
Get-Module -ListAvailable Az # No rows if not installed
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force # -AllowClobber
Get-Module -ListAvailable Az

# connect
Import-Module Az
Connect-AzAccount

# connect.context
Set-AzContext -SubscriptionId "<subscription-id>"
Update-AzConfig -DefaultSubscriptionForLogin <subscription-id>

# list subs
Get-AzSubscription

# list resource groups
Get-AzResourceGroup | Format-Table -AutoSize
```

- https://learn.microsoft.com/en-us/powershell/azure/install-azure-powershell
