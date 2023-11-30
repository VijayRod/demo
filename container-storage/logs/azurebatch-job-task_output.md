```
az batch task file list --job-id job1 --task-id task1 --output table
az batch task file download --job-id job1 --task-id task1 --file-path stdout.txt --destination /tmp/batch/stdout.txt
# az batch task file download --job-id job1 --task-id task1 --file-path stdout.txt --destination ./stdout.txt
```
    
- https://learn.microsoft.com/en-us/azure/batch/quick-create-cli#view-task-output
