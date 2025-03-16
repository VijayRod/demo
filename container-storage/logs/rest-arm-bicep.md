# bicep

- https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/quickstart-create-bicep-use-visual-studio-code?tabs=CLI
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-cli#deploy-resources-by-using-an-arm-template-or-bicep-file
- https://azure.github.io/bicep/: Bicep Playground
- https://github.com/Azure/bicep

```
# Visual Studio code: Add the Bicep extension
# To check it out: Create a .bicep file. VSCode will show color-coded lines. Right-click the file to deploy or to Open Bicep Visualizer.
# Create a file named `file.bicep` in Visual Studio code, and then type `res-aks` or `res-` to get started.
```

- https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/quickstart-create-bicep-use-visual-studio-code?tabs=azure-cli
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/visual-studio-code?tabs=azure-cli

# bicep.sample

```
# Deploy a Bicep file without a parameter file to set up a resource group. Keep an eye on the targetScope


## VSCode file: foo.Subscription0.bicep
## Right-click the file, Deploy Bicep File... (the parameter file is None).

targetScope = 'subscription'

@description('Parameters')
param location string = deployment().location // 'eastus2'
param resourceGroupName string = 'rg'

@description('Create Resource Group')
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}
```

- https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/file
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/scenarios-rbac: Common scenarios
- https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep#usage-examples: Usage examples on some pages
- https://learn.microsoft.com/en-us/samples/browse/?expanded=azure&products=azure-resource-manager&languages=bicep
- https://github.com/Azure/azure-quickstart-templates/blob/master/modules/Microsoft.ManagedIdentity/user-assigned-identity-role-assignment/1.0/main.bicep

```
# Deploy a Bicep file with a parameter file to set up a resource group. Keep an eye on the targetScope


## VSCode file: foo.Subscription.bicep
## Right-click the file, Deploy Bicep File... (the parameter file is foo.Subscription.bicep).

targetScope = 'subscription'

@description('Parameters')
param location string = deployment().location
param projectResourceGroupName string

@description('Create Resource Group')
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: projectResourceGroupName
  location: location
}


## VSCode file: foo.Subscription.bicepparam
## The 'using' indicates the location of the previous bicep file

using '../vscode/foo.Subscription.bicep'

param projectResourceGroupName = 'xxx-CoreServices'
```

- https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/parameter-files?tabs=Bicep

```
# Deploy several Bicep files together in one go. The targetScope is only used for subscription-level resources


## VSCode file: foo.Subscription.bicep
## The Subscription.bicep file, which has targetScope = 'subscription', includes a module named after the other bicep file. 
## Right-click the file, Deploy Bicep File... (the parameter file is foo.Subscription.bicep). This deployment creates an NSG named MyServiceName-MyResourceGroup in the resource group.

targetScope = 'subscription'

@description('Parameters')
param location string = deployment().location
param projectResourceGroupName string

@description('Create Resource Group')
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: projectResourceGroupName
  location: location
}

@description('This module will set up resources in the resource group.')
module resourceGroupResources 'foo.rg-xxx-CoreServices.bicep' = {
  name: 'foo.rg-xxx-CoreServices.bicep'
  scope: resourceGroup
  params: {
    shortName: 'MyServiceName'
  }
}

## VSCode file: foo.Subscription.bicepparam
## The 'using' indicates the location of the previous bicep file

using '../vscode/foo.Subscription.bicep'

param projectResourceGroupName = 'xxx-CoreServices'


## VSCode file: foo.rg-xxx-CoreServices.bicep

param shortName string
param location string = resourceGroup().location

@description('Here is a sample resource')
#disable-next-line BCP081 // Disabling NoTypesAvailable warning
resource exampleResource 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: '${shortName}-MyResourceGroup'
  location: location
  properties: {
    securityRules: []
  }
}

```

- https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/modules
