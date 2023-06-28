The WindowsAzureGuestAgent reports this, and it can be seen through commonly available system commands. To resolve this issue, you need to find the disk consumer causing excessive disk consumption. The following commands were attempted in a command prompt on a Windows 2022 node.

```
find "space" C:\WindowsAzure\Logs\WaAppAgent.log

rem Here is a sample output below.
rem ---------- C:\WINDOWSAZURE\LOGS\WAAPPAGENT.LOG
rem [00000014] 2023-06-16T18:10:18.966Z [WARN]  Failed to serialize aggregate status: There is not enough space on the disk.
rem [00000014] 2023-06-16T18:10:18.966Z [WARN]  Writing the aggregate status to file failed with error: There is not enough space on the disk.

rem type C:\WindowsAzure\Logs\WaAppAgent.log
```

Here are commands to find available disk space.

```
# Run in a cmd terminal:
powershell Get-WmiObject -Class Win32_LogicalDisk -ComputerName localhost

# Here is a sample output that includes 'FreeSpace'.
# DeviceID     : C:
# DriveType    : 3
# ProviderName :
# FreeSpace    : 0
# Size         : 136912564224
# VolumeName   : Windows
```

```
# Run in a cmd terminal:
fsutil volume diskfree c:

# Here is a sample output that includes 'Total free bytes'.
# Total free bytes                :         -61,440 (279496122328931?)
# Total bytes                     : 136,912,564,224 (          127.5 GB)
# Total quota free bytes          :         -61,440 (279496122328931?)
# Unavailable pool bytes          :               0 (            0.0 KB)
# Quota unavailable pool bytes    :               0 (            0.0 KB)
# Used bytes                      : 136,891,854,848 (          127.5 GB)
# Total Reserved bytes            :      20,770,816 (           19.8 MB)
# Volume storage reserved bytes   :               0 (            0.0 KB)
# Available committed bytes       :               0 (            0.0 KB)
# Pool available bytes            :               0 (            0.0 KB)
```

```
# Run in a cmd terminal:
dir

# Here is a sample output that includes 'bytes free'.
#  Volume in drive C is Windows
#  Volume Serial Number is 2CCA-295F
#  Directory of C:\
# 06/15/2023  01:34 PM    <DIR>          AzureData
# ...
# 06/15/2023  01:34 PM    <DIR>          WindowsAzure
#                3 File(s)        130,618 bytes
#               28 Dir(s)               0 bytes free
```

```
# Run in a cmd terminal:
powershell Get-CimInstance -Class CIM_LogicalDisk

# Here is a sample output that includes 'FreeSpace'.
# DeviceID DriveType ProviderName VolumeName        Size         FreeSpace
# -------- --------- ------------ ----------        ----         ---------
# C:       3                      Windows           136912564224 404848640
# D:       3                      Temporary Storage 17177767936  15081549824
```

```
# Run in a PowerShell terminal (Credits: Abel Hu):
Get-CimInstance -Class CIM_LogicalDisk | Select-Object @{Name="Size(GB)";Expression={$_.size/1gb}}, @{Name="Free Space(GB)";Expression={$_.freespace/1gb}}, @{Name="Free (%)";Expression={"{0,6:P0}" -f(($_.freespace/1gb) / ($_.size/1gb))}}, DeviceID, DriveType | Where-Object DeviceID -EQ 'C:'

# Here is a sample output that includes 'Free Space(GB)'.
# Size(GB)       : 127.509761810303
# Free Space(GB) : 0.000690460205078125
# Free (%)       :     0%
# DeviceID       : C:
# DriveType      : 3
```

Run the following command in the required folder or in C:\ to get the top space consumers. 

```
# Run in a cmd terminal:
powershell -command "$fso = new-object -com Scripting.FileSystemObject; gci -Directory | select @{l='Size'; e={$fso.GetFolder($_.FullName).Size}},FullName | sort Size -Descending | ft @{l='Size [MB]'; e={'{0:N2}    ' -f ($_.Size / 1MB)}},FullName"

# Here is a sample output below.
# Size [MB]    FullName
# ---------    --------
# 8,560.87     C:\windows3
# 8,559.87     C:\windows10
# ...
```

```
rem Run in a cmd terminal:
curl https://download.sysinternals.com/files/DU.zip --output du.zip

rem Here is a sample output below.
rem   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
rem                                  Dload  Upload   Total   Spent    Left  Speed
rem 100  524k  100  524k    0     0  2316k      0 --:--:-- --:--:-- --:--:-- 2332k

rem Run in a cmd terminal:
powershell -command "Expand-Archive du.zip C:\du"

rem Run in a cmd terminal:
C:\du\du.exe /accepteula -nobanner -l 1 -q -c c:\

rem Here is a sample output below.
Path,CurrentFileCount,CurrentFileSize,FileCount,DirectoryCount,DirectorySize,DirectorySizeOnDisk
"c:\Users",1,174,109,90,4904729,5898240
"c:\var",0,0,42,59,21592,512000
"c:\Windows",12,919968,48412,16311,5664178485,5962715136
"c:\windows1",10,851714,64553,16973,8975670313,9327292960
"c:\windows10",10,851714,64553,16973,8975670313,9327292960

rem You can copy or save the above output as a text or CSV file. Open Excel, go to the "Data" tab, and select "From Text/CSV" to import the file. This selects "Delimited" as the file type, "Comma" as the delimiter, and selects the option for headers. "Load" the data into Excel and sort it by the "DirectorySize" column to identify the highest space consumer's Path values.

rem To demonstrate a different directory, you can use the following example: C:\du\du.exe /accepteula -nobanner -l 1 -q -c c:\var\log\pods.
```

Here are HPC daemonsets to monitor disk usage on every Windows 2022 and 2019 node (Credits: Abel Hu). It's expected for these pods to later be in CrashLoopBackOff since they only run the command once and then exit.

```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: monitor-diskspace-ws2022
  labels:
    app: monitor-diskspace-ws2022 # privileged-daemonset
spec:
  selector:
    matchLabels:
      app: monitor-diskspace-ws2022
  template:
    metadata:
      labels:
        app: monitor-diskspace-ws2022
    spec:
      nodeSelector:
        kubernetes.azure.com/os-sku: Windows2022
      containers:
        - name: powershell
          image: mcr.microsoft.com/windows/servercore:ltsc2022
          securityContext:
            windowsOptions:
              hostProcess: true
              runAsUserName: "NT AUTHORITY\\SYSTEM"
          command:
            - C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
            - -command
            - |
              Get-CimInstance -Class CIM_LogicalDisk | Select-Object @{Name="Size(GB)";Expression={$_.size/1gb}}, @{Name="Free Space(GB)";Expression={$_.freespace/1gb}}, @{Name="Free (%)";Expression={"{0,6:P0}" -f(($_.freespace/1gb) / ($_.size/1gb))}}, DeviceID, DriveType | Where-Object DeviceID -EQ 'C:'
              'GMT time: ' + $(Get-Date ([datetime]::UtcNow)) + '. Node name: ' + $env:computername
              '##########'
          resources:
            limits:
              cpu: 0.3
              memory: 200M              
      hostNetwork: true
      terminationGracePeriodSeconds: 0
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: monitor-diskspace-ws2019
  labels:
    app: monitor-diskspace-ws2019 # privileged-daemonset
spec:
  selector:
    matchLabels:
      app: monitor-diskspace-ws2019
  template:
    metadata:
      labels:
        app: monitor-diskspace-ws2019
    spec:
      nodeSelector:
        kubernetes.azure.com/os-sku: Windows2019
      containers:
        - name: powershell
          image: mcr.microsoft.com/windows/servercore:1809
          securityContext:
            windowsOptions:
              hostProcess: true
              runAsUserName: "NT AUTHORITY\\SYSTEM"
          command:
            - C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
            - -command
            - |
              Get-CimInstance -Class CIM_LogicalDisk | Select-Object @{Name="Size(GB)";Expression={$_.size/1gb}}, @{Name="Free Space(GB)";Expression={$_.freespace/1gb}}, @{Name="Free (%)";Expression={"{0,6:P0}" -f(($_.freespace/1gb) / ($_.size/1gb))}}, DeviceID, DriveType | Where-Object DeviceID -EQ 'C:'
              'GMT time: ' + $(Get-Date ([datetime]::UtcNow)) + '. Node name: ' + $env:computername
              '##########'
          resources:
            limits:
              cpu: 0.3
              memory: 200M              
      hostNetwork: true
      terminationGracePeriodSeconds: 0
```

```
kubectl logs monitor-diskspace-ws2022-r4qxx

# Here is a sample output below.
# Size(GB)       : 127.509761810303
# Free Space(GB) : 95.2361755371094
# Free (%)       :    75%
# DeviceID       : C:
# DriveType      : 3
# GMT time: 06/20/2023 11:16:34. Node name: aksnpwin000001
# ##########
```

The following information shows the disk space before the disk consumption:

```
DeviceID     : C:
DriveType    : 3
ProviderName :
FreeSpace    : 107389853696	// 100G
Size         : 136912564224	// 128G
VolumeName   : Windows
```

Here is a sample script to reproduce this issue. Please only run it in a test node/environment since low disk space in the node can result in system instability.

```
rem Run the below cmd script after SSH'ing to the node.
set dest="c:\windows2"
xcopy /E /I /C /Y /H /J C:\Windows %dest%
FOR /L %i IN (3,1,10) DO ( set dest2=%dest% && xcopy /E /I /C /Y /H /J /Q %dest2% c:\windows%i && echo c:\windows%i )
```

```
# An alternative, quicker script in PowerShell to generate large files on the OS disk of a Windows node. This script should be run through RDP, as running it through the debugger pod may lead to System.OutOfMemoryException errors. 
# (Credits: Abel Hu)
# https://github.com/kubernetes/kubernetes/issues/103032

for($i=0; $i -lt 70; $i++) {
 Write-Host "Create file $i"
 $out = new-object byte[] 2000048576; (new-Object Random).NextBytes($out);[IO.File]::WriteAllBytes("c:\,ypowerfile51-$i.txt", $out)
}

# Here is a sample output below.
# Create file 0
# Create file 1
# Create file 2
# Create file 3
# ...
```
Here are some related links:
- [Azure/azure-diskinspect-service/diskinfo.md](https://github.com/Azure/azure-diskinspect-service/blob/master/docs/diskinfo.md). This link contains information on the disk inspection capability in the Azure Disk Inspect Service.
- [kubernetes/issues/103032](https://github.com/kubernetes/kubernetes/issues/103032): No enough disk space in the os disk but there is no alert in node's DiskPressure.
- [kubernetes/issues/116020](https://github.com/kubernetes/kubernetes/issues/116020): [BUG] Windows disk usage getting reported larger than disk size and may prevent GC from running
  - [microsoft/Windows-Containers/issues/358](https://github.com/microsoft/Windows-Containers/issues/358): Access is denied during removal of snapshots in containerd.
