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
