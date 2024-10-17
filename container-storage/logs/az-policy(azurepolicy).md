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

- https://learn.microsoft.com/en-us/azure/governance/policy/concepts/effect-deploy-if-not-exists

## az-policy.builtin.DINE (DeployIfNotExists)

```
# DeployIfNotExists (DINE) policies
# Look for DINE files here: https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions
# e.g. https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Kubernetes/AKS_AzurePolicyAddOn_DINE.json

tbd az policy assignment create -n "TEST-AKS_AzurePolicyAddOn_DINE" --policy a8eff44f-8c92-45c3-a3fb-9880802d67a7 # -p /tmp/param-values.json # ResourceIdentityRequired. Policy assignments must include a 'managed identity' when assigning 'DeployIfNotExists' policy definitions or policy definitions that contain a deployment in the effect details
```
- https://jloudon.com/cloud/Azure-Spring-Clean-DINE-to-Automate-your-Monitoring-Governance-with-Azure-Monitor-Metric-Alerts/
- https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions
- https://learn.microsoft.com/en-us/azure/governance/policy/concepts/effect-deploy-if-not-exists

## az-policy.example.aks

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
