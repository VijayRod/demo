```
df / -h # Disk free space
Filesystem      Size  Used Avail Use% Mounted on
/dev/root       124G   21G  104G  17% /

sudo du -shx --exclude='/proc' --exclude='/sys' /* | sort -hr # Disk usage breakdown for directories
17G     /var
2.5G    /usr
...
```

```
kubectl logs # Delete the pod to remove its associated log

logrotate # Remove log files

crictl rmi -prune # Remove unused container images
Deleted: mcr.microsoft.com/azure-policy/policy-kubernetes-addon-prod:1.0.1
Deleted: mcr.microsoft.com/oss/kubernetes/azure-cloud-node-manager:v1.25.12
...
```

- https://stackoverflow.com/questions/257844/quickly-create-a-large-file-on-a-linux-system
