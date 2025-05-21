> ## image.k8s.pod

```
kubectl delete po --all
sleep 10; kubectl get po

kubectl delete po --all -A
sleep 10; kubectl get po -A
```


```
# all

# distro.alpine
apk update && apk upgrade
apk update && apk add bind-tools
apk add tcpdump nano nmap


# distro.alpine.container
alpine: kubectl run debug -it --image=alpine -- sh
nicolaka/netshoot: kubectl run netshoot --rm -it --image=nicolaka/netshoot -- bash # https://github.com/nicolaka/netshoot

# distro.debian
apt-get update -y && apt-get install net-tools strace -y # install multiple packages
apt-get update -y && apt-get install iputils-ping -y # includes ping, not netstat. ping 10.224.0.4
apt-get update -y && apt-get install net-tools -y # includes netstat, tbd ping. netstat -atunp | grep -E "10.224.0.4|10.224.0.5"
apt-get update -y && apt-get install strace -y # strace -s 99 -ffp 8302
apt update -y && apt install bind9-dnsutils -y # nslookup
apt update -y && apt install inetutils-telnet -y # telnet
apt update && apt install dnsutils

# distro.debian.container
debian: kubectl run -it --rm aks-ssh --image=debian:stable # apt-get update -y && apt-get install dnsutils -y && apt-get install curl -y
nginx: kubectl exec -it nginx -- /bin/bash # -- curl google.com -I # apt-get update -y && apt-get install dnsutils -y
nginx: kubectl run nginx --image=nginx

# distro.distroless
busybox: kubectl run -it --rm busybox --image=busybox -- wget -qO- google.com
busybox: kubectl run busybox --image=busybox --command -- sh -c 'sleep 1d' # https://busybox.net/about.html. Lightweight 1 MB image, without /etc/os-release
dnsutils: kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml # k8s e2e, https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/ # commands: /agnhost --help, /agnhost serve-hostname, /agnhost connect --protocol HTTP --port 80, /agnhost netexec, /agnhost pause, /agnhost crash
pause: kubectl run pause --image=registry.k8s.io/pause:3.1 --restart=Never # static image from scratch, without a shell or libc

# more

```

- https://kubernetes.io/docs/concepts/containers/images/
- https://kubernetes.io/docs/tasks/access-application-cluster/list-all-running-container-images/

```
# busybox
kubectl run busybox --image=busybox --command -it --rm -- wget https://www.example.com
kubectl run busybox --image=busybox --command -it --rm -- wget https://www.example.com
kubectl run -it --rm --restart=Never busybox --image=busybox sh
kubectl run -it --rm --restart=Never busybox --image=gcr.io/google-containers/busybox sh
kubectl run -it --rm nginx --image=nginx -- curl -I https://openai.com
```

- https://stackoverflow.com/questions/62847331/is-it-possible-to-install-curl-into-busybox-in-kubernetes-pod: The short answer, is you cannot.

```
# dnsutils
kubectl run dnsutils --image=registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3 --command -- sh -c 'sleep infinity' # kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml
kubectl run dnsutils --image=registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3 --command -- sh -c 'sleep infinity' -l run=dnsutils
kubectl exec -it dnsutils -- /bin/bash

kubectl debug node/aks-nodepool1-37663765-vmss000000 -it --image=ubuntu # or kubectl node-shell <NodeName>
apt update && apt install dnsutils -y
```

- https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/

```
kubectl create deploy hostnames --image=registry.k8s.io/serve_hostname # From another pod, use curl $hostnamesPodIp:9376
```

```
# other
```
- https://docs.dynatrace.com/docs/ingest-from/setup-on-container-platforms/docker/set-up-dynatrace-oneagent-as-docker-container: dynatrace/oneagent
- https://github.com/prometheus/node_exporter: quay.io/prometheus/node-exporter

> ## image.vhd (VirtualHardDisk)

- https://learn.microsoft.com/en-us/windows/win32/vstor/about-vhd: An example of how VHD files are used is the Hyper-V feature in Windows 7, Windows Server 2008, Virtual Server, and Windows Virtual PC. These products use the VHD API to contain the Windows operating system image utilized by a virtual machine as its system boot disk.
- https://www.microsoft.com/en-us/download/details.aspx?id=23850: VHD Specifications. This file contains the specifications for the .VHD format for Virtual Hard Disks
- https://github.com/libyal/libvhdi/blob/main/documentation/Virtual%20Hard%20Disk%20%28VHD%29%20image%20format.asciidoc: Virtual Hard Disk (VHD) image format. A commonly image format used in Microsoft virtualization products is the Virtual Hard Disk (VHD) Image format. It is both used the store hard disk images and snapshots.
- https://veeams.com/vhd-to-azure-the-ultimate-integration-tutorial/: Azure primarily supports fixed-size VHD files for VM disk images, meaning any dynamically expanding VHDs need to be converted beforehand. Before uploading, it’s wise to clean up your VHD files. This includes defragmenting the disk, removing unnecessary files, and truncating any sensitive data.
- https://docs.oracle.com/en/virtualization/virtualbox/7.1/user/storage.html#virtual-media-manager: Disk Image Files (VDI, VMDK, VHD, HDD). VHD format used by Microsoft.

> ## image.vhd.vhd2(vhdx)

- https://github.com/libyal/libvhdi/blob/main/documentation/Virtual%20Hard%20Disk%20version%202%20(VHDX)%20image%20format.asciidoc: Virtual Hard Disk version 2 (VHDX) image format
- https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-vhdx/83e061f8-f6e2-4de1-91bd-5d518a43d477: [MS-VHDX]: Virtual Hard Disk v2 (VHDX) File Format

> ## image.vhd.os.linux

- https://learn.microsoft.com/en-us/azure/virtual-machines/linux/download-vhd
- https://learn.microsoft.com/en-us/azure/virtual-machines/linux/disks-upload-vhd-to-managed-disk-cli: --blob-type PageBlob
- https://learn.microsoft.com/en-us/azure/virtual-machines/managed-disk-from-image-version
- https://learn.microsoft.com/en-us/azure/virtual-machines/linux/expand-disks?tabs=ubuntu

> ## image.vhd.os.windows

- https://learn.microsoft.com/en-us/azure/virtual-desktop/set-up-customize-master-image: Prepare and customize a VHD image for Azure Virtual Desktop
- https://learn.microsoft.com/en-us/azure/virtual-machines/windows/download-vhd
- https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/get-started/create-a-virtual-machine-in-hyper-v?tabs=hyper-v-manager: Connect Virtual Hard Disk
- https://learn.microsoft.com/en-us/azure/virtual-machines/windows/expand-disks
- https://learn.microsoft.com/en-us/windows-server/storage/disk-management/manage-virtual-hard-disks

> ## image.vhd.manageddisk(azuredisk)

- https://www.lucidity.cloud/blog/azure-managed-disk
- https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-managed-disks

> ## image.vhd.storagepool

- https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/hyper-v-storage-architecture#hyperconverged-hyper-v-and-storage-spaces-direct
- https://learn.microsoft.com/en-us/windows-server/storage/storage-spaces/deploy-standalone-storage-spaces
- https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-managed-disks: apiVersion: containerstorage.azure.com/v1 kind: StoragePool
- https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-elastic-san: kind: StoragePool
