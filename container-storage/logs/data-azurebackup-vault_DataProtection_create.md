```
az dataprotection backup-vault create -g $rg --vault-name vaultdp --type SystemAssigned --storage-settings datastore-type="VaultStore" type="LocallyRedundant"
# /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.DataProtection/backupVaults/vaultdp
```

```
az dataprotection backup-vault list -g $rg -otable
az dataprotection backup-vault show -g $rg --vault-name vaultdp
```

- https://learn.microsoft.com/en-us/answers/questions/405915/what-is-difference-between-recovery-services-vault
- https://harvestingclouds.com/post/azure-recovery-services-vaults-vs-backup-vaults/
