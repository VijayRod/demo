Unfortunately, there are no foolproof ways to determine the reasons for disk corruption, but there are likely some error messages in the kernel logs.

- https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-machines/linux-recovery-cannot-start-file-system-errors#identify-which-disk-is-corrupted: fsck
- https://askubuntu.com/questions/506519/problem-in-accessing-ntfs-drive-the-disk-contains-an-unclean-file-system: "The disk contains an unclean file system (0, 0).
Metadata kept in Windows cache, refused to mount. Failed to mount '/dev/sda2': Operation not permitted. The NTFS partition is in an unsafe state. Please resume and shutdown
Windows fully (no hibernation or fast restarting), or mount the volume read-only with the 'ro' mount option." You can run in Windows chkdsk /f
