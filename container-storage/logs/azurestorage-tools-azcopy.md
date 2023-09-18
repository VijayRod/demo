```
tar -xzvf /tmp/azcopy_linux_amd64_10.20.1.tar.gz
azcopy_linux_amd64_10.20.1/azcopy -v
```

```
ACCOUNT_NAME=
CONTAINER_NAME=
SRC_FILE=
SAS_TOKEN="se=2023-09-25&sp=...
./azcopy cp "https://$ACCOUNT_NAME.blob.core.windows.net/$CONTAINER_NAME/${SRC_FILE}?$SAS_TOKEN" "/tmp/${SRC_FILE}"

INFO: Scanning...
INFO: Any empty folders will not be processed, because source and/or destination doesn't have full folder support
Job 8fe3af5d-bc74-9240-7ed4-aa085a064fd1 has started
Log file is located at: /root/.azcopy/8fe3af5d-bc74-9240-7ed4-aa085a064fd1.log
100.0 %, 1 Done, 0 Failed, 0 Pending, 0 Skipped, 1 Total,
Job 8fe3af5d-bc74-9240-7ed4-aa085a064fd1 summary
Elapsed Time (Minutes): 18.0395
Number of File Transfers: 1
Number of Folder Property Transfers: 0
Number of Symlink Transfers: 0
Total Number of Transfers: 1
Number of File Transfers Completed: 1
Number of Folder Transfers Completed: 0
Number of File Transfers Failed: 0
Number of Folder Transfers Failed: 0
Number of File Transfers Skipped: 0
Number of Folder Transfers Skipped: 0
TotalBytesTransferred: 14733760505
Final Job Status: Completed
```

- https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10
