## smb

- https://learn.microsoft.com/en-us/windows/win32/fileio/microsoft-smb-protocol-and-cifs-protocol-overview
- https://stackoverflow.com/questions/tagged/SMB
- https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-smb/f210069c-7086-4dc2-885e-861d837df688: [MS-SMB]: Server Message Block (SMB) Protocol
- https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-smb2/5606ad47-5ee0-437a-817e-70c366052962: [MS-SMB2]: Server Message Block (SMB) Protocol Versions 2 and 3
- https://github.com/TalAloni/SMBLibrary/tree/master
- https://learn.microsoft.com/en-us/windows-server/storage/file-server/troubleshoot/troubleshooting-smb
- https://learn.microsoft.com/en-us/windows-server/storage/file-server/troubleshoot/smb-known-issues
<br>

- https://github.com/torvalds/linux/tree/master/fs/smb
- https://github.com/multipath-tcp/mptcp/blob/mptcp_v0.96/fs/cifs

## smb.client

- https://github.com/TalAloni/SMBLibrary/blob/master/SMBLibrary/Client/SMB2Client.cs

## smb.credit

- https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-smb2/b1b7cc8a-4d24-4701-bc3f-220b543ceef8#gt_99b28556-d321-4a40-a062-65b5a49870e3: credit: A value that is granted to an SMB 2 Protocol client by an SMB 2 Protocol server that limits the number of outstanding requests that a client can send to a server.
- https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-smb2/46256e72-b361-4d73-ac7d-d47c04b32e4b: 3.3.4.1.2 Granting Credits to the Client
- https://wiki.samba.org/index.php/SMB2_Credits
- https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-smb2/2e366edb-b006-47e7-aa94-ef6f71043ced: 3.3.1.2 Algorithm for the Granting of Credits
- https://community.netapp.com/t5/Network-and-Storage-Protocols/How-does-SMB-Credits-actually-work-on-ONTAP/m-p/153113: I see that similar option was available in SMB_1 as well (max sessions per tcp connection) and in SMB_2, the word 'credit' is coined...
- https://learn.microsoft.com/en-us/windows-server/administration/performance-tuning/role/file-server/smb-file-server#tuning-parameters-for-smb-file-servers: credit
- https://github.com/multipath-tcp/mptcp/blob/mptcp_v0.96/fs/cifs/transport.c: wait_for_free_credits
  
## smb.credit_zero (error_not_enough_credits)

- https://github.com/TalAloni/SMBLibrary/issues/42: Is there a proper way to handle Not Enough Credits as a client?
- https://stackoverflow.com/questions/44299856/what-happens-when-a-client-reaches-zero-credits-in-smb2

## smb.ioctl

```
TBD: Sample kubelet error in syslog: CIFS VFS: error -95 on ioctl to get interface list

TBD - Sample kernel errors:
Nov 22 19:45:19 Tower kernel: CIFS: VFS: \\192.168.12.152 has not responded in 180 seconds. Reconnecting...
Nov 22 19:45:19 Tower kernel: CIFS: VFS: Send error in read = -11
```

- https://man7.org/linux/man-pages/man2/ioctl.2.html
- https://bugs.launchpad.net/ubuntu/+source/linux-azure/+bug/1864131: SMB3_request_interfaces. SMB2_ioctl. EOPNOTSUPP
- https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-cifs/0d8f5f17-16af-499d-a192-a5fd85fbb7e1: 2.2.4.35 SMB_COM_IOCTL (0x27). the functions supported are not defined by the protocol, but by the systems on which the CIFS implementations execute.
- https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-cifs/bec8c29e-ec9a-456e-b90e-d90c07e5c7fc: 3.2.4.22 Application Requests Sending an IOCTL to a File or Device
- https://github.com/multipath-tcp/mptcp/blob/mptcp_v0.96/fs/cifs/smb2ops.c: Has the errors in cifs_dbg statements for example "malformed interface info"
  
## smb.other.perf

- https://learn.microsoft.com/en-us/windows-server/administration/performance-tuning/role/file-server/smb-file-server

## smb.rdma

- https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-smbd/1ca5f4ae-e5b1-493d-b87d-f4464325e6e3: [MS-SMBD]: SMB2 Remote Direct Memory Access (RDMA) Transport Protocol

## smb.samples

C#:
- https://github.com/TalAloni/SMBLibrary/blob/master/ClientExamples.md
- https://github.com/TalAloni/SMBLibrary/issues/9#issuecomment-376813149
