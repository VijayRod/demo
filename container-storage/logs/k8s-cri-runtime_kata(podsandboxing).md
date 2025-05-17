## kata-containers

- https://katacontainers.io/
- https://github.com/kata-containers/kata-containers/tree/main: Kata Containers is an open source project and community working to build a standard implementation of lightweight Virtual Machines (VMs) that feel and perform like containers, but provide the workload isolation and security advantages of VMs.

## kata-containers..kata-runtime (CLI)

- https://github.com/kata-containers/kata-containers/tree/main?tab=readme-ov-file#hardware-requirements: kata-runtime check

## kata-containers..cloud.azure

- https://github.com/kata-containers/kata-containers/blob/main/docs/install/azure-installation-guide.md
- https://techcommunity.microsoft.com/blog/appsonazureblog/preview-support-for-kata-vm-isolated-containers-on-aks-for-pod-sandboxing/3751557

## kata-containers..cloud.azure.kata-cc-isolation

- https://learn.microsoft.com/en-us/azure/aks/deploy-confidential-containers-default-policy

## kata-containers..cloud.azure.kata-mshv-vm-isolation

```
rg=rgkata
az group create -n $rg -l $loc
az aks create -g $rg -n aks --os-sku AzureLinux --workload-runtime KataMshvVmIsolation --node-vm-size Standard_D4s_v3 -c 1 # -s $vmsize -c 2 # generation 2 VM and supports nested virtualization
# az aks nodepool add -g $rg --cluster-name akscal -n npkata --workload-runtime KataMshvVmIsolation --os-sku AzureLinux --node-vm-size Standard_D4s_v3
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no; kubectl get po -A

k get runtimeclasses
NAME                     HANDLER   AGE
kata-mshv-vm-isolation   kata      69m
runc                     runc      69m

k describe runtimeclasses kata-mshv-vm-isolation
Name:         kata-mshv-vm-isolation
Namespace:
Labels:       addonmanager.kubernetes.io/mode=Reconcile
              kubernetes.io/cluster-service=true
Annotations:  <none>
API Version:  node.k8s.io/v1
Handler:      kata
Kind:         RuntimeClass
Metadata:
  Creation Timestamp:  2025-04-01T18:04:31Z
  Resource Version:    623
  UID:                 b18661c1-0733-4a19-8351-069eac338366
Scheduling:
  Node Selector:
    kubernetes.azure.com/kata-mshv-vm-isolation:  true
Events:                                           <none>

# Refer to the image section
k describe no
Name:               aks-nodepool1-34487422-vmss000000
Roles:              <none>
Labels:             agentpool=nodepool1
                    kubernetes.azure.com/kata-mshv-vm-isolation=true
                    kubernetes.azure.com/node-image-version=AKSCBLMariner-V2katagen2-202503.13.0

az aks show -g $rg -n aks
  "agentPoolProfiles": [
    {
      "nodeImageVersion": "AKSCBLMariner-V2katagen2-202503.13.0",
      "workloadRuntime": "KataMshvVmIsolation"

cat << EOF | kubectl create -f -
kind: Pod
apiVersion: v1
metadata:
  name: trusted
spec:
  containers:
  - name: trusted
    image: mcr.microsoft.com/aks/fundamental/base-ubuntu:v0.0.11
    command: ["/bin/sh", "-ec", "while :; do echo '.'; sleep 5 ; done"]
---
kind: Pod
apiVersion: v1
metadata:
  name: untrusted
spec:
  runtimeClassName: kata-mshv-vm-isolation
  containers:
  - name: untrusted
    image: mcr.microsoft.com/aks/fundamental/base-ubuntu:v0.0.11
    command: ["/bin/sh", "-ec", "while :; do echo '.'; sleep 5 ; done"]
EOF
kubectl get po -owide -w

trusted     1/1     Running             0          5s    10.244.0.142   aks-nodepool1-34487422-vmss000000   <none>           <none>
untrusted   1/1     Running             0          8s    10.244.0.3     aks-nodepool1-34487422-vmss000000   <none>           <none>

kubectl exec -it trusted -- /bin/bash # uname -r # 5.15.157.mshv1-2.cm2
kubectl exec -it untrusted -- /bin/bash # 6.1.58.mshv4
```

```
tbd
root@aks-nodepool1-34487422-vmss000000 [ / ]# kata-runtime check
WARN[0000] Not running network checks as super user      arch=amd64 name=kata-runtime pid=83602 source=runtime
ERRO[0000] CPU property not found                        arch=amd64 description="Virtualization support" name=vmx pid=83602 source=runtime type=flag
WARN[0000] modprobe insert module failed                 arch=amd64 error="exit status 1" module=kvm_intel name=kata-runtime output="modprobe: FATAL: Module kvm_intel not found in directory /lib/modules/5.15.157.mshv1-2.cm2\n" pid=83602 source=runtime
ERRO[0000] kernel property kvm_intel not found           arch=amd64 description="Intel KVM" name=kvm_intel pid=83602 source=runtime type=module
WARN[0000] modprobe insert module failed                 arch=amd64 error="exit status 1" module=kvm name=kata-runtime output="modprobe: FATAL: Module kvm not found in directory /lib/modules/5.15.157.mshv1-2.cm2\n" pid=83602 source=runtime
ERRO[0000] kernel property kvm not found                 arch=amd64 description="Kernel-based Virtual Machine" name=kvm pid=83602 source=runtime type=module
ERRO[0000] ERROR: System is not capable of running Kata Containers  arch=amd64 name=kata-runtime pid=83602 source=runtime
ERROR: System is not capable of running Kata Containers

root@aks-nodepool1-34487422-vmss000000 [ / ]# kata-runtime env
[Kernel]
  Path = "/usr/share/cloud-hypervisor/vmlinux.bin"
  Parameters = "systemd.unit=kata-containers.target systemd.mask=systemd-networkd.service systemd.mask=systemd-networkd.socket systemd.legacy_systemd_cgroup_controller=yes systemd.unified_cgroup_hierarchy=0"

[Meta]
  Version = "1.0.27"

[Image]
  Path = ""

[Initrd]
  Path = "/var/cache/kata-containers/osbuilder-images/kernel-uvm/kata-containers-initrd.img"

[Hypervisor]
  MachineType = "q35"
  Version = "cloud-hypervisor v38.0.0"
  Path = "/usr/bin/cloud-hypervisor"
  BlockDeviceDriver = "virtio-blk"
  EntropySource = "/dev/urandom"
  SharedFS = "virtio-fs"
  VirtioFSDaemon = "/usr/libexec/virtiofsd-rs"
  SocketPath = "{ID}/clh.sock"
  Msize9p = 8192
  MemorySlots = 10
  HotPlugVFIO = "no-port"
  ColdPlugVFIO = "no-port"
  Debug = false
  [Hypervisor.SecurityInfo]
    Rootless = false
    DisableSeccomp = false
    GuestHookPath = ""
    EnableAnnotations = ["enable_iommu", "virtio_fs_extra_args", "kernel_params"]
    ConfidentialGuest = false

[Runtime]
  Path = "/usr/bin/kata-runtime"
  GuestSeLinuxLabel = ""
  Debug = false
  Trace = false
  DisableGuestSeccomp = true
  DisableNewNetNs = false
  SandboxCgroupOnly = false
  [Runtime.Config]
    Path = "/usr/share/defaults/kata-containers/configuration-clh.toml"
  [Runtime.Version]
    OCI = "1.1.0-rc.1"
    [Runtime.Version.Version]
      Semver = "3.3.0-alpha0"
      Commit = "f46f3f68609a68891dab34894846b69cbac12a62"
      Major = 3
      Minor = 3
      Patch = 0

[Host]
  Kernel = "5.15.157.mshv1-2.cm2"
  Architecture = "amd64"
  VMContainerCapable = false
  SupportVSocks = true
  [Host.Distro]
    Name = "Common Base Linux Mariner"
    Version = "2.0"
  [Host.CPU]
    Vendor = "GenuineIntel"
    Model = "Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz"
    CPUs = 4
  [Host.Memory]
    Total = 15858032
    Free = 10365404
    Available = 12566468

[Agent]
  Debug = false
  Trace = false
```

- https://learn.microsoft.com/en-us/azure/aks/use-pod-sandboxing#how-it-works

> ## error

```
# error.InvalidWorkloadRuntimeSettingError

az aks create -g $rg -n aks --os-sku AzureLinux --workload-runtime KataMshvVmIsolation --node-vm-size Standard_D2ls_v5
(InvalidWorkloadRuntimeSettingError) Kata: "KataMshvVmIsolation" has to be used with vm size that supports nested virtualization. See https://aka.ms/aks/podsandbox for details.
Code: InvalidWorkloadRuntimeSettingError
Message: Kata: "KataMshvVmIsolation" has to be used with vm size that supports nested virtualization. See https://aka.ms/aks/podsandbox for details.
```

> ## image

```
root@aks-nodepool1-34487422-vmss000001 [ / ]# tdnf list installed | grep kata
kata-containers.x86_64                       3.2.0.azl2-5.cm2          @System
kata-containers-cc.x86_64                    3.2.0.azl2-5.cm2          @System
kata-packages-host.x86_64                    1.0.0-5.cm2               @System

root@aks-nodepool1-34487422-vmss000001 [ / ]# ls -l /usr/bin/ | grep kata
-rwxr-xr-x   1 root root 49406552 Dec  3 20:17 containerd-shim-kata-v2
-rwxr-xr-x   1 root root    16689 Dec  3 20:17 kata-collect-data.sh
-rwxr-xr-x   1 root root 38880600 Dec  3 20:17 kata-monitor
-rwxr-xr-x   1 root root  1340392 Dec  3 20:19 kata-overlay
-rwxr-xr-x   1 root root 48252200 Dec  3 20:17 kata-runtime
```

- https://github.com/Azure/AgentBaker/blob/master/vhdbuilder/release-notes/AKSAzureLinux/gen2kata/latest.txt

> ## sku.nestedvirtualization

- https://azure.microsoft.com/en-us/blog/nested-virtualization-in-azure/
- https://learn.microsoft.com/en-us/answers/questions/813416/how-do-i-know-what-size-azure-vm-supports-nested-v
- https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/nested-virtualization
