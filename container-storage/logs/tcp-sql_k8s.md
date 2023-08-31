This pod can be created independently from the application to simulate the SQL connections. This PowerShell script will perform connectivity checks from this machine to the server and database.

```
# linux
kubectl run -it sqlconncheckerpowershellinstance --image=mcr.microsoft.com/powershell:lts-alpine-3.10

# windows
kubectl run -it sqlconncheckerpowershellinstance --image=mcr.microsoft.com/windows/servercore:ltsc2022 --overrides='{ "spec": { "template": { "spec": { "nodeSelector": { "kubernetes.azure.com/agentpool": "npwin" } } } } }' -- powershell
```

- https://github.com/Azure/SQL-Connectivity-Checker#kubernetes
