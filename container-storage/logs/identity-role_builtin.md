```
# role.cli

az role definition list -otable
Name                                                                                 Type                                     Description
-----------------------------------------------------------------------------------  ---------------------------------------  
AzureCleanerRole                                                                     Microsoft.Authorization/roleDefinitions  Specialised role for the 'My Azure Cleaner'service (8007b451-87a2-4a52-8982-71e870a740b2) to ensure PoLP. Allows the service to read and delete resource groups, read permissions, and manage resource locks.
...

az role definition list -n AzureCleanerRole
[
  {
    "assignableScopes": [
      "/providers/Microsoft.Management/managementGroups/11111111-bb70-4cd2-b6f4-375247f0f163"
    ],
    "createdBy": "0bc12465-ad34-4ee9-9d73-d6b23dfc78b8",
    "createdOn": "2024-06-25T15:13:13.649815+00:00",
    "description": "Specialised role for the 'My Azure Cleaner'service (8007b451-87a2-4a52-8982-71e870a740b2) to ensure PoLP. Allows the service to read and delete resource groups, read permissions, and manage resource locks.",
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/providers/Microsoft.Authorization/roleDefinitions/8d6215ee-6df1-47a2-8883-11a8aadcc964",
    "name": "8d6215ee-6df1-47a2-8883-11a8aadcc964",
    "permissions": [
      {
        "actions": [
          "Microsoft.Resources/subscriptions/resourceGroups/read",
          "Microsoft.Resources/subscriptions/resourceGroups/delete",
          "Microsoft.Authorization/*/read",
          "Microsoft.Authorization/locks/write",
          "Microsoft.Authorization/locks/delete"
        ],
        "condition": null,
        "conditionVersion": null,
        "dataActions": [],
        "notActions": [],
        "notDataActions": []
      }
    ],
    "roleName": "AzureCleanerRole",
    "roleType": "CustomRole",
    "type": "Microsoft.Authorization/roleDefinitions",
    "updatedBy": "11111111-ad34-4ee9-9d73-d6b23dfc78b8",
    "updatedOn": "2024-06-25T15:13:13.649815+00:00"
  }
]
```

```
# role.ps

Get-AzRoleDefinition | % {"$($PSItem.Name -replace '[^\w]',''): '$($PSItem.ID)'"}
AzureCleanerRole: '8d6215ee-6df1-47a2-8883-11a8aadcc964'
...
```

- The list of built-in roles can be found at https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles.
