In my cluster with a Windows node pool, my OS disk has a capacity of 128 GB, with a Windows partition occupying 127 GB.

```
# Change to the cmd prompt.
PS C:\> cmd

Microsoft Windows [Version 10.0.20348.1787]
(c) Microsoft Corporation. All rights reserved.

# Run diskpart.
C:\>diskpart

Microsoft DiskPart version 10.0.20348.1
Copyright (C) Microsoft Corporation.
On computer: aksnpwin000002

# List the disks in diskpart.
DISKPART> list disk

  Disk ###  Status         Size     Free     Dyn  Gpt
  --------  -------------  -------  -------  ---  ---
  Disk 0    Online          128 GB      0 B
  Disk 1    Online           16 GB      0 B

# Select the disk in diskpart.
DISKPART> select disk 0

Disk 0 is now the selected disk.

# List the partitions on the selected disk in diskpart.
DISKPART> list partition

  Partition ###  Type              Size     Offset
  -------------  ----------------  -------  -------
  Partition 1    Primary            500 MB  1024 KB
  Partition 2    Primary            127 GB   501 MB

# List the volumes on the selected partition in diskpart.
DISKPART> list volume

  Volume ###  Ltr  Label        Fs     Type        Size     Status     Info
  ----------  ---  -----------  -----  ----------  -------  ---------  --------
  Volume 0     E                       DVD-ROM         0 B  No Media
  Volume 1         System Rese  NTFS   Partition    500 MB  Healthy    System
  Volume 2     C   Windows      NTFS   Partition    127 GB  Healthy    Boot
  Volume 3     D   Temporary S  NTFS   Partition     15 GB  Healthy    Pagefile
  
# Exit diskpart.
DISKPART> exit

Leaving DiskPart...
```

Here are logs from the same Windows node. 

```
# View the log entry for "Resize OS drive if possible".
C:\>type C:\AzureData\CustomDataSetupScript.log

2023-06-20T09:24:15.6593103+00:00: Apply telemetry data setting
2023-06-20T09:24:15.6749374+00:00: Resize os drive if possible
2023-06-20T09:25:20.3053956+00:00: Initialize data disks
2023-06-20T09:25:20.5241776+00:00: Create required data directories as needed

# View the script for "Resize OS drive if possible".
C:\>type C:\AzureData\CustomDataSetupScript.ps1

        - ProvisioningScriptsPackage contains scripts to start kubelet, kubeproxy, etc. The source is https://github.com/Azure/aks-engine/tree/master/staging/provisioning/windows
...
    Write-Log "Resize os drive if possible"
    Resize-OSDrive
```

The Resize-OSDrive function can be viewed [here](https://github.com/Azure/aks-engine/blob/master/parts/k8s/windowsconfigfunc.ps1), and the Resize-Partition PowerShell command reference can be found [here](https://learn.microsoft.com/en-us/powershell/module/storage/resize-partition).

```
# View the below associated funtion in a browser - https://github.com/Azure/aks-engine/blob/master/parts/k8s/windowsconfigfunc.ps1

## Resize the system partition to the max available size. Azure can resize a managed disk, but the VM still needs to extend the partition boundary
function Resize-OSDrive
{
    $osDrive = ((Get-WmiObject Win32_OperatingSystem).SystemDrive).TrimEnd(":")
    $size = (Get-Partition -DriveLetter $osDrive).Size
    $maxSize = (Get-PartitionSupportedSize -DriveLetter $osDrive).SizeMax
    if ($size -lt $maxSize)
    {
        Resize-Partition -DriveLetter $osDrive -Size $maxSize
    }
}
```
