```
folder=/tmp/AzFileDiagnostics # Run in node
mkdir $folder
wget -P $folder https://raw.githubusercontent.com/Azure-Samples/azure-files-samples/master/AzFileDiagnostics/Linux/AzFileDiagnostics.sh
chmod +x $folder/AzFileDiagnostics.sh

cd $folder
# ./AzFileDiagnostics.sh
./AzFileDiagnostics.sh  -u //f534ad32e8f9e448faa0438.file.core.windows.net/pvc-cf7a66ac-eede-45a4-8d60-ef14f31f1a3a # //storageaccountname.file.core.windows.net/sharename

echo $folder
ls $folder
TBD cat ./output.txt
```
- https://github.com/Azure-Samples/azure-files-samples/tree/master/AzFileDiagnostics/Linux
