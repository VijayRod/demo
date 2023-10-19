```
az dataprotection backup-vault delete -g $rg --vault-name vaultdp -y
```

- https://learn.microsoft.com/en-us/answers/questions/599385/cannot-delete-backup-vault: We just need to change "data source" and you would see existing backup instance & policy
