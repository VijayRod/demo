## az-policy.builtin

```
# https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Kubernetes/AKS_CSI.json
  "id": "/providers/Microsoft.Authorization/policyDefinitions/c5110b6e-5272-4989-9935-59ad06fdf341",
  "name": "c5110b6e-5272-4989-9935-59ad06fdf341"

az policy assignment list -otable | grep c5110b6e # No rows
az policy assignment create -n TEST-AKS_CSI --policy c5110b6e-5272-4989-9935-59ad06fdf341 # -p /tmp/param-values.json
az policy assignment list -otable | grep c5110b6e # success

                                                         Default            TEST-AKS_CSI
               /providers/Microsoft.Authorization/policyDefinitions/c5110b6e-5272-4989-9935-59ad06fdf341
                                   /subscriptions/redacts-1111-1111-1111-111111111111
                                   
# az policy assignment delete -n TEST-AKS_CSI
```

- https://github.com/Azure/azure-policy/tree/master/built-in-policies/policyDefinitions

## az-policy.builtin.DINE (DeployIfNotExists)

```
# DeployIfNotExists (DINE) policies
# Look for DINE files here: https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions
# e.g. https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Kubernetes/AKS_AzurePolicyAddOn_DINE.json

# az policy assignment create -n TEST-AKS_AzurePolicyAddOn_DINE --policy a8eff44f-8c92-45c3-a3fb-9880802d67a7 # -p /tmp/param-values.json # ResourceIdentityRequired. Policy assignments must include a 'managed identity' when assigning 'DeployIfNotExists' policy definitions or policy definitions that contain a deployment in the effect details
az policy assignment create -n TEST-AKS_AzurePolicyAddOn_DINE --policy a8eff44f-8c92-45c3-a3fb-9880802d67a7 --mi-system-assigned -l swedencentral
```
- https://jloudon.com/cloud/Azure-Spring-Clean-DINE-to-Automate-your-Monitoring-Governance-with-Azure-Monitor-Metric-Alerts/
- https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions
- https://learn.microsoft.com/en-us/azure/governance/policy/concepts/effect-deploy-if-not-exists: Search for filenames that contain the word DINE
- https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/dine-guidance#why-use-dine-and-modify-policies
- https://techcommunity.microsoft.com/t5/azure-governance-and-management/azure-policy-introduces-user-assigned-msi-support-faster-dine/ba-p/2661073: DeployIfNotExist Latency Time
- https://www.azurecitadel.com/policy/basics/dine/

### az-policy.builtin.DINE.aks

```
az policy assignment create -n TEST-AKS_AzurePolicyAddOn_DINE --policy a8eff44f-8c92-45c3-a3fb-9880802d67a7 --mi-system-assigned -l swedencentral
az policy assignment list -otable | grep AKS_AzurePolicyAddOn_DINE

                                                         Default            TEST-AKS_AzurePolicyAddOn_DINE
               /providers/Microsoft.Authorization/policyDefinitions/a8eff44f-8c92-45c3-a3fb-9880802d67a7     /subscriptions/redacts-1111-1111-1111-111111111111  swedencentral
```

- https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Kubernetes/AKS_AzurePolicyAddOn_DINE.json

## az-policy.custom.example

- https://github.com/Azure/azure-policy/blob/master/samples/ResourceGroup/audit-resourceGroup-resourceLocks/azurepolicy.json

### az-policy.custom.example.aks

```
cat <<EOF > /tmp/params.json
{
            "effect": {
                "type": "String",
                "metadata": {
                    "description": "Enable or disable the execution of the policy",
                    "displayName": "Effect"
                },
                "allowedValues": [
                    "Audit",
                    "Deny",
                    "Disabled"
                ],
                "defaultValue": "Audit"
            }
        }
EOF
cat <<EOF > /tmp/rules.json
{
            "if": {
                "allOf": [
                    {
                        "field": "type",
                        "equals": "Microsoft.ContainerService/managedClusters"
                    },
                    {
                        "anyOf": [
                            {
                                "field": "Microsoft.ContainerService/managedClusters/addonProfiles.azurePolicy.enabled",
                                "exists": false
                            },
                            {
                                "field": "Microsoft.ContainerService/managedClusters/addonProfiles.azurePolicy.enabled",
                                "equals": false
                            }
                        ]
                    }
                ]
            },
            "then": {
                "effect": "[parameters('effect')]"
            }
        }
EOF
az policy definition create -n TEST-DenyAKSWithoutPolicyAddon --mode Indexed --rules /tmp/rules.json --param /tmp/params.json

cat <<EOF > /tmp/param-values.json
{
    "effect":{
        "value":"Deny"
    }
}
EOF
az policy assignment create -n TEST-DenyAKSWithoutPolicyAddon --policy TEST-DenyAKSWithoutPolicyAddon -p /tmp/param-values.json

az policy definition list -otable | grep TEST
az policy assignment list -otable | grep TEST
# az policy assignment delete -n TEST-DenyAKSWithoutPolicyAddon; az policy definition delete -n TEST-DenyAKSWithoutPolicyAddon

rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n akspolicy -s $vmsize -c 1 # RequestDisallowedByPolicy

(RequestDisallowedByPolicy) Resource 'akspolicy' was disallowed by policy. Policy identifiers: '[{"policyAssignment":{"name":"TEST-DenyAKSWithoutPolicyAddon","id":"/subscriptions/redacts-1111-1111-1111-111111111111/providers/Microsoft.Authorization/policyAssignments/TEST-DenyAKSWithoutPolicyAddon"},"policyDefinition":{"name":"TEST-DenyAKSWithoutPolicyAddon","id":"/subscriptions/redacts-1111-1111-1111-111111111111/providers/Microsoft.Authorization/policyDefinitions/TEST-DenyAKSWithoutPolicyAddon"}}]'.
Code: RequestDisallowedByPolicy
Message: Resource 'akspolicy' was disallowed by policy. Policy identifiers: '[{"policyAssignment":{"name":"TEST-DenyAKSWithoutPolicyAddon","id":"/subscriptions/redacts-1111-1111-1111-111111111111/providers/Microsoft.Authorization/policyAssignments/TEST-DenyAKSWithoutPolicyAddon"},"policyDefinition":{"name":"TEST-DenyAKSWithoutPolicyAddon","id":"/subscriptions/redacts-1111-1111-1111-111111111111/providers/Microsoft.Authorization/policyDefinitions/TEST-DenyAKSWithoutPolicyAddon"}}]'.
Target: akspolicy
Additional Information:Type: PolicyViolation
Info: {
    "evaluationDetails": {
        "evaluatedExpressions": [
            {
                "result": "True",
                "expressionKind": "Field",
                "expression": "type",
                "path": "type",
                "expressionValue": "Microsoft.ContainerService/managedClusters",
                "targetValue": "Microsoft.ContainerService/managedClusters",
                "operator": "Equals"
            },
            {
                "result": "True",
                "expressionKind": "Field",
                "expression": "Microsoft.ContainerService/managedClusters/addonProfiles.azurePolicy.enabled",
                "path": "properties.addonProfiles.azurePolicy.enabled",
                "targetValue": "False",
                "operator": "Exists"
            }
        ]
    },
    "policyDefinitionId": "/subscriptions/redacts-1111-1111-1111-111111111111/providers/Microsoft.Authorization/policyDefinitions/TEST-DenyAKSWithoutPolicyAddon",
    "policyDefinitionName": "TEST-DenyAKSWithoutPolicyAddon",
    "policyDefinitionDisplayName": "TEST-DenyAKSWithoutPolicyAddon",
    "policyDefinitionEffect": "Deny",
    "policyAssignmentId": "/subscriptions/redacts-1111-1111-1111-111111111111/providers/Microsoft.Authorization/policyAssignments/TEST-DenyAKSWithoutPolicyAddon",
    "policyAssignmentName": "TEST-DenyAKSWithoutPolicyAddon",
    "policyAssignmentScope": "/subscriptions/redacts-1111-1111-1111-111111111111",
    "policyAssignmentParameters": {
        "effect": "Deny"
    },
    "policyExemptionIds": []
}
```

## az-policy.scan

```
az policy state trigger-scan # Trigger a policy compliance evaluation at the current subscription scope
az policy state trigger-scan -g $rg --no-wait
```
