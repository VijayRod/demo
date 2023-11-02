```
# Go to the portal, browse to the resource, and click on 'Export template'. This action will display the resource properties, which are used to define the policy
az provider show --namespace Microsoft.Storage --expand "resourceTypes/aliases" --query "resourceTypes[].aliases[].name" | grep Http
# "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly",

# Portal - Policy | Definitions | + Policy Definition | Save. This definition is used to create a policy assignment, which takes 5-15 minutes to take effect.
{
  "displayName": "Deny storage accounts not using only HTTPS",
  "description": "Deny storage accounts not using only HTTPS. Checks the supportsHttpsTrafficOnly property on StorageAccounts.",
  "mode": "all",
  "parameters": {
    "effectType": {
      "type": "string",
      "defaultValue": "Deny",
      "allowedValues": [
        "Deny",
        "Disabled"
       ],
      "metadata": {
        "displayName": "Effect",
        "description": "Enable or disable the execution of the policy"
      }
    }
  },
  "policyRule": {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Storage/storageAccounts"
        },
        {
          "field": "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly",
          "notEquals": "true"
        }
      ]
    },
    "then": {
      "effect": "[parameters('effectType')]"
    }
  }
}

az storage account create -g $rg -n "storage$RANDOM$RANDOM" # RequestDisallowedByPolicy since no --https-only
```
