```
$file="C:\Windows\TEMP\vnet.out"
hostname > $file
date >> $file
C:\k\azurecni\bin\azure-vnet.exe >> $file
type C:\k\azurecni\netconf\10-azure.conflist >> $file
type C:\k\azure-vnet.json >> $file
# cat $file
dir $file

C:\k\debug\collect-windows-logs.ps1
# TBD dir C:\Windows\TEMP\*.zip
```

```
v1.5.6.1
CNI protocol versions supported: 0.1.0, 0.2.0, 0.3.0, 0.3.1, 0.4.0
{
    "cniVersion":  "0.3.0",
    "name":  "azure",
    "adapterName":  "",
    "plugins":  [
...
{
  "Network": {
   "Version": "v1.5.6.1",
   "TimeStamp": "2023-10-06T11:16:43.7941114Z",
   "ExternalInterfaces": {
...
```
