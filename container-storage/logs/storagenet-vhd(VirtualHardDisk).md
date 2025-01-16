- https://www.microsoft.com/en-us/download/details.aspx?id=23850: VHD Specifications. This file contains the specifications for the .VHD format for Virtual Hard Disks
- https://github.com/libyal/libvhdi/blob/main/documentation/Virtual%20Hard%20Disk%20%28VHD%29%20image%20format.asciidoc: Virtual Hard Disk (VHD) image format. A commonly image format used in Microsoft virtualization products is the Virtual Hard Disk (VHD) Image format. It is both used the store hard disk images and snapshots.
- https://veeams.com/vhd-to-azure-the-ultimate-integration-tutorial/: Azure primarily supports fixed-size VHD files for VM disk images, meaning any dynamically expanding VHDs need to be converted beforehand. Before uploading, it’s wise to clean up your VHD files. This includes defragmenting the disk, removing unnecessary files, and truncating any sensitive data.
- https://docs.oracle.com/en/virtualization/virtualbox/7.1/user/storage.html#virtual-media-manager: Disk Image Files (VDI, VMDK, VHD, HDD). VHD format used by Microsoft.

## storagenet-vhd.vhd2(vhdx)

- https://github.com/libyal/libvhdi/blob/main/documentation/Virtual%20Hard%20Disk%20version%202%20(VHDX)%20image%20format.asciidoc: Virtual Hard Disk version 2 (VHDX) image format
- https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-vhdx/83e061f8-f6e2-4de1-91bd-5d518a43d477: [MS-VHDX]: Virtual Hard Disk v2 (VHDX) File Format

## storagenet-vhd.os.linux

- https://learn.microsoft.com/en-us/azure/virtual-machines/linux/download-vhd
- https://learn.microsoft.com/en-us/azure/virtual-machines/linux/disks-upload-vhd-to-managed-disk-cli: --blob-type PageBlob
- https://learn.microsoft.com/en-us/azure/virtual-machines/managed-disk-from-image-version
- https://learn.microsoft.com/en-us/azure/virtual-machines/linux/expand-disks?tabs=ubuntu

## storagenet-vhd.os.windows

- https://learn.microsoft.com/en-us/azure/virtual-desktop/set-up-customize-master-image: Prepare and customize a VHD image for Azure Virtual Desktop
- https://learn.microsoft.com/en-us/azure/virtual-machines/windows/download-vhd
- https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/get-started/create-a-virtual-machine-in-hyper-v?tabs=hyper-v-manager: Connect Virtual Hard Disk
- https://learn.microsoft.com/en-us/azure/virtual-machines/windows/expand-disks

## storagenet-vhd.manageddisk(azuredisk)

- https://www.lucidity.cloud/blog/azure-managed-disk
- https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-managed-disks

## storagenet-vhd.storagepool

- https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/hyper-v-storage-architecture#hyperconverged-hyper-v-and-storage-spaces-direct
- https://learn.microsoft.com/en-us/windows-server/storage/storage-spaces/deploy-standalone-storage-spaces
- https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-managed-disks: apiVersion: containerstorage.azure.com/v1 kind: StoragePool
- https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-elastic-san: kind: StoragePool
