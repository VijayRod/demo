```
# Miscellaneous
ssh-keygen -f "/root/.ssh/known_hosts" -R "[127.0.0.1]:2022" ## To optionally remove a saved ECDSA key
ssh-keygen -f "/root/.ssh/known_hosts" -R "10.224.0.91" ## To optionally remove a saved fingerprint for the ECDSA key sent by a remote host
```

- https://learn.microsoft.com/en-us/azure/aks/node-access
