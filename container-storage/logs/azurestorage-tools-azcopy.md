```
tar -xzvf /tmp/azcopy_linux_amd64_10.20.1.tar.gz
mv /tmp/azcopy_linux_amd64_10.20.1/azcopy /usr/local/bin/azcopy
azcopy -v
```

```
ACCOUNT_NAME=
CONTAINER_NAME=
SRC_FILE=
SAS_TOKEN="se=2023-09-25&sp=...
azcopy cp "https://$ACCOUNT_NAME.blob.core.windows.net/$CONTAINER_NAME/${SRC_FILE}?$SAS_TOKEN" "/tmp/${SRC_FILE}"

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

```
cat /root/.azcopy/69b966cc-56a4-964e-70d2-9e30fcfd1087.log | tail
2023/09/20 20:51:30 PERF: primary performance constraint is Unknown. States: C:  0, R:  1, W: 383, F:  0, H:  1, B: 191, S:  0, P:  1, Q:  0, D:  0, E:  0, T: 577, GRs: 192
2023/09/20 20:51:30 0.1 %, 0 Done, 0 Failed, 1 Pending, 0 Skipped, 1 Total,
2023/09/20 20:51:30 ==> REQUEST/RESPONSE (Try=1/392.089388ms, OpTime=392.159982ms) -- RESPONSE SUCCESSFULLY RECEIVED
   GET https://redacted.blob.core.windows.net/test/redacted.pcap?se=...&timeout=901
   X-Ms-Request-Id: [36513e4c-c01e-00f5-3c79-ecd815000000]
...
```

- https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10
