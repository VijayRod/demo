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
fsutil volume diskfree c:

rem Here is a sample output that includes 'Total free bytes'.
rem Total free bytes                :         -61,440 (279496122328931?)
rem Total bytes                     : 136,912,564,224 (          127.5 GB)
rem Total quota free bytes          :         -61,440 (279496122328931?)
rem Unavailable pool bytes          :               0 (            0.0 KB)
rem Quota unavailable pool bytes    :               0 (            0.0 KB)
rem Used bytes                      : 136,891,854,848 (          127.5 GB)
rem Total Reserved bytes            :      20,770,816 (           19.8 MB)
rem Volume storage reserved bytes   :               0 (            0.0 KB)
rem Available committed bytes       :               0 (            0.0 KB)
rem Pool available bytes            :               0 (            0.0 KB)
```

```
dir

rem Here is a sample output that includes 'bytes free'.
rem  Volume in drive C is Windows
rem  Volume Serial Number is 2CCA-295F
rem  Directory of C:\
rem 06/15/2023  01:34 PM    <DIR>          AzureData
rem ...
rem 06/15/2023  01:34 PM    <DIR>          WindowsAzure
rem                3 File(s)        130,618 bytes
rem               28 Dir(s)               0 bytes free
```

Run the following command in the required folder or in C:\ to get the top space consumers. 

```
powershell -command "$fso = new-object -com Scripting.FileSystemObject; gci -Directory | select @{l='Size'; e={$fso.GetFolder($_.FullName).Size}},FullName | sort Size -Descending | ft @{l='Size [MB]'; e={'{0:N2}    ' -f ($_.Size / 1MB)}},FullName"

# Here is a sample output below.
# Size [MB]    FullName
# ---------    --------
# 8,560.87     C:\windows3
# 8,559.87     C:\windows10
# ...
```

```
curl https://download.sysinternals.com/files/DU.zip --output du.zip

rem Here is a sample output below.
rem   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
rem                                  Dload  Upload   Total   Spent    Left  Speed
rem 100  524k  100  524k    0     0  2316k      0 --:--:-- --:--:-- --:--:-- 2332k

powershell -command "Expand-Archive du.zip C:\du"

C:\du\du.exe /accepteula -nobanner -l 1 -q -c c:\

# Here is a sample output below.
Path,CurrentFileCount,CurrentFileSize,FileCount,DirectoryCount,DirectorySize,DirectorySizeOnDisk
"c:\Users",1,174,109,90,4904729,5898240
"c:\var",0,0,42,59,21592,512000
"c:\Windows",12,919968,48412,16311,5664178485,5962715136
"c:\windows1",10,851714,64553,16973,8975670313,9327292960
"c:\windows10",10,851714,64553,16973,8975670313,9327292960

# You can copy or save the above output as a text or CSV file. Open Excel, go to the "Data" tab, and select "From Text/CSV" to import the file. This selects "Delimited" as the file type, "Comma" as the delimiter, and selects the option for headers. "Load" the data into Excel and sort it by the "DirectorySize" column to identify the highest space consumer's Path values.

# To demonstrate a different directory, you can use the following example: C:\du\du.exe /accepteula -nobanner -l 1 -q -c c:\var\log\pods.
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

Here is a sample cmd script to reproduce this issue. Please only run it in a test node/environment since low disk space in the node can result in system instability.

```
rem Run it after SSH'ing to the node.
set dest="c:\windows2"
xcopy /E /I /C /Y /H /J C:\Windows %dest%
FOR /L %i IN (3,1,10) DO ( set dest2=%dest% && xcopy /E /I /C /Y /H /J /Q %dest2% c:\windows%i && echo c:\windows%i )
```
