Make sure it's an Azure CNI cluster.

```
curl --insecure https://faeqexa4e6e7h9c0.fz20.alb.azure.com/
no healthy upstream
```

- https://github.com/MicrosoftDocs/azure-docs/issues/119401: this issue typically means the backend service isn't online, or there's connectivity issues between AGC and the backend. It's also possible you have defined the incorrect namespaces in the httproute or gateway resources.
