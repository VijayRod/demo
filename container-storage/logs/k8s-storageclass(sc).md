# sc.parameters.update

- If the storage account parameter has been changed: the existing pvc would still use old storage class config, should remove that pvc and try again (by creating a new pvc)
