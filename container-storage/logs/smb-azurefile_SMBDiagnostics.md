```
apt-get update && apt-get install trace-cmd zip -y

rm /tmp/SMBDiagnostics -r
mkdir /tmp/SMBDiagnostics
cd /tmp/SMBDiagnostics
wget https://raw.githubusercontent.com/Azure-Samples/azure-files-samples/master/SMBDiagnostics/smbclientlogs.sh
wget https://raw.githubusercontent.com/Azure-Samples/azure-files-samples/master/SMBDiagnostics/trace-cifsbpf
chmod +x ./smbclientlogs.sh
ls
```

```
./smbclientlogs.sh start # This is async. Now repro the issue
./smbclientlogs.sh stop
ls output.zip
ls ./output
# cifs_diag.txt  cifs_dmesg  cifs_trace  os_details.txt
```

- https://github.com/Azure-Samples/azure-files-samples/tree/master/SMBDiagnostics
