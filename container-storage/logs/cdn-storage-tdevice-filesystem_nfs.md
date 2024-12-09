## nfs

- https://lwn.net/Kernel/Index/#Filesystems-NFS
- https://lwn.net/Kernel/Index/#Network_filesystems
- http://wiki.linux-nfs.org/wiki/index.php/Main_Page
- https://wiki.archlinux.org/title/NFS
- https://debian-handbook.info/browse/en-US/stable/sect.nfs-file-server.html
- https://docs.kernel.org/admin-guide/nfs/index.html
- https://docs.kernel.org/filesystems/nfs/index.html
- https://en.wikipedia.org/wiki/Network_File_System
- https://learn.microsoft.com/en-us/azure/storage/common/nfs-comparison
- https://learn.microsoft.com/en-us/windows-server/storage/nfs/nfs-overview
- https://tldp.org/HOWTO/NFS-HOWTO/security.html
- https://ubuntu.com/server/docs/service-nfs
- https://www.howtouselinux.com/post/understanding-portmap-with-examples
- https://www.ibm.com/docs/en/storage-scale/5.1.0?topic=firewall-recommendations-protocol-access#d789583e46
- https://www.ibm.com/docs/en/zos/2.1.0?topic=introduction-nfs-version-3-version-4-tcpip-protocols
- https://learn.microsoft.com/en-us/azure/storage/files/files-nfs-protocol
- https://learn.microsoft.com/en-us/azure/storage/files/nfs-performance

NFSv3
- The NFS 3.0 protocol uses ports 111 and 2048.
  - https://learn.microsoft.com/en-us/azure/storage/blobs/network-file-system-protocol-support: The NFS 3.0 protocol uses ports 111 and 2048.
  - https://learn.microsoft.com/en-us/azure/storage/blobs/network-file-system-protocol-support-how-to#step-2-configure-network-security: The NFS 3.0 protocol uses ports 111 and 2048.

NFSv4
- The NFSv4.1 service listens on port 2049 only and does not require portmap (port 111) to operate.
  - https://learn.microsoft.com/en-us/azure/storage/files/storage-files-how-to-mount-nfs-shares: Currently, only NFS version 4.1 is supported. Open port 2049
- https://community.netapp.com/t5/Tech-ONTAP-Blogs/NFSv3-and-NFSv4-What-s-the-difference/ba-p/441316
- https://datatracker.ietf.org/doc/html/rfc5661

## nfs.mount.permission

- https://learn.microsoft.com/en-us/azure/aks/azure-csi-blob-storage-provision?tabs=mount-nfs%2Csecret: Mounting Blob storage using the NFS v3 protocol doesn't authenticate using an account key. Your AKS cluster needs to reside in the same or peered virtual network as the agent node. The only way to secure the data in your storage account is by using a virtual network and other network security settings.
- https://learn.microsoft.com/en-us/azure/storage/blobs/network-file-system-protocol-support-how-to#step-2-configure-network-security: Currently, the only way to secure the data in your storage account is by using a virtual network and other network security settings
