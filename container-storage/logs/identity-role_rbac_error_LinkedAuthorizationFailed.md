To resolve the LinkedAuthorizationFailed error, ensure that the user or the object ID mentioned in the error is granted the necessary access permissions. For example, you can use the following command to grant the required permissions and then retry the previous operation.

```
az role assignment create --assignee-object-id dummyo-61de-4329-91e9-42073b8363bc  --role "Contributor" --scope "/subscriptions/dummys11-1111-1111-1111-111111111111/resourceGroups/resourceGroupName"
```

- https://learn.microsoft.com/en-us/azure/role-based-access-control/troubleshooting?tabs=bicep#symptom---unable-to-assign-a-role

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-code-linkedauthorizationfailed
