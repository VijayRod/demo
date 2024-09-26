## sc
- https://stackoverflow.com/questions/74741993/0-1-nodes-are-available-1-pod-has-unbound-immediate-persistentvolumeclaims: If you want the PVs automatically created from PVC claims you need a Provisioner installed in your Cluster.
  
## sc.parameters.update

- If the storage account parameter has been changed: the existing pvc would still use old storage class config, should remove that pvc and try again (by creating a new pvc)
