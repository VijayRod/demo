## cpu.gpu

- https://lwn.net/Kernel/Index/#Device_drivers-Accelerators
- https://learn.microsoft.com/en-us/azure/virtual-machines/sizes-gpu

## cpu.gpu.app.aks

```
# To create a cluster
clustername=aksgpu
rgname=$rg
az group create -n $rgname -l $loc # eastus
az aks create -g $rgname -n $clustername

# To add a node pool
az aks nodepool add -g $rgname --cluster-name $clustername -n gpunp --node-vm-size Standard_NC6s_v3 --node-taints sku=gpu:NoSchedule --aks-custom-headers UseGPUDedicatedVHD=true -c 1 --mode user

# To deploy a pod
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx14
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  tolerations:
  - key: "sku"
    operator: "Equal"
    value: "gpu"
    effect: "NoSchedule"
  nodeSelector:
    "kubernetes.azure.com/agentpool": gpunp
EOF
```

```
# az aks nodepool show -g $rgname --cluster-name $clustername -n gpunp --query gpuInstanceProfile
(null)

# az aks nodepool show -g $rgname --cluster-name $clustername -n gpunp --query nodeTaints
[
  "sku=gpu:NoSchedule"
]

# az aks nodepool show -g $rgname --cluster-name $clustername -n gpunp --query nodeImageVersion
"AKSUbuntu-1804gen2gpucontainerd-202307.27.0"

# az aks nodepool show -g $rgname --cluster-name $clustername -n gpunp --query vmSize
"Standard_NC6s_v3"

# kubectl describe node aks-gpunp-10282168-vmss000000
Name:               aks-gpunp-10282168-vmss000000
Roles:              agent
Labels:             accelerator=nvidia
                    agentpool=gpunp
                    beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/instance-type=Standard_NC6s_v3
                    beta.kubernetes.io/os=linux
                    failure-domain.beta.kubernetes.io/region=eastus
                    failure-domain.beta.kubernetes.io/zone=0
                    kubernetes.azure.com/accelerator=nvidia
                    kubernetes.azure.com/agentpool=gpunp
                    kubernetes.azure.com/cluster=MC_testshack_aksgpu_eastus
                    kubernetes.azure.com/consolidated-additional-properties=02eb9584-3773-11ee-af08-321fa34b746b
                    kubernetes.azure.com/kubelet-identity-client-id=dummyk-0638-4e6d-a36b-2f78538a95f0
                    kubernetes.azure.com/mode=user
                    kubernetes.azure.com/node-image-version=AKSUbuntu-1804gen2gpucontainerd-202307.27.0
                    kubernetes.azure.com/nodepool-type=VirtualMachineScaleSets
                    kubernetes.azure.com/os-sku=Ubuntu
                    kubernetes.azure.com/role=agent
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=aks-gpunp-10282168-vmss000000
                    kubernetes.io/os=linux
                    kubernetes.io/role=agent
                    node-role.kubernetes.io/agent=
                    node.kubernetes.io/instance-type=Standard_NC6s_v3
                    topology.disk.csi.azure.com/zone=
                    topology.kubernetes.io/region=eastus
                    topology.kubernetes.io/zone=0
Annotations:        csi.volume.kubernetes.io/nodeid: {"disk.csi.azure.com":"aks-gpunp-10282168-vmss000000","file.csi.azure.com":"aks-gpunp-10282168-vmss000000"}
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Thu, 10 Aug 2023 11:45:24 +0000
Taints:             sku=gpu:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  aks-gpunp-10282168-vmss000000
  AcquireTime:     <unset>
  RenewTime:       Thu, 10 Aug 2023 11:47:37 +0000
Conditions:
  Type                 Status  LastHeartbeatTime                 LastTransitionTime                Reason
            Message
  ----                 ------  -----------------                 ------------------                ------
            -------
  NetworkUnavailable   False   Thu, 10 Aug 2023 11:46:33 +0000   Thu, 10 Aug 2023 11:46:33 +0000   RouteCreated                 RouteController created a route
  MemoryPressure       False   Thu, 10 Aug 2023 11:45:27 +0000   Thu, 10 Aug 2023 11:45:24 +0000   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure         False   Thu, 10 Aug 2023 11:45:27 +0000   Thu, 10 Aug 2023 11:45:24 +0000   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure          False   Thu, 10 Aug 2023 11:45:27 +0000   Thu, 10 Aug 2023 11:45:24 +0000   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready                True    Thu, 10 Aug 2023 11:45:27 +0000   Thu, 10 Aug 2023 11:45:27 +0000   KubeletReady                 kubelet is posting ready status. AppArmor enabled
Addresses:
  InternalIP:  10.224.0.7
  Hostname:    aks-gpunp-10282168-vmss000000
Capacity:
  cpu:                6
  ephemeral-storage:  129886128Ki
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  memory:             115397144Ki
  nvidia.com/gpu:     1
  pods:               110
Allocatable:
  cpu:                5840m
  ephemeral-storage:  119703055367
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  memory:             105863704Ki
  nvidia.com/gpu:     1
  pods:               110
System Info:
  Machine ID:                 c63ae820bf2b4b379414308772c4523b
  System UUID:                e3d2e4cf-93b9-43b5-a8cc-04c20d7505de
  Boot ID:                    ef9c0bf4-4f11-4b21-8184-90823390f8c1
  Kernel Version:             5.4.0-1112-azure
  OS Image:                   Ubuntu 18.04.6 LTS
  Operating System:           linux
  Architecture:               amd64
  Container Runtime Version:  containerd://1.7.1+azure-1
  Kubelet Version:            v1.26.6
  Kube-Proxy Version:         v1.26.6
PodCIDR:                      10.244.3.0/24
PodCIDRs:                     10.244.3.0/24
ProviderID:                   azure:///subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_testshack_aksgpu_eastus/providers/Microsoft.Compute/virtualMachineScaleSets/aks-gpunp-10282168-vmss/virtualMachines/0
Non-terminated Pods:          (5 in total)
  Namespace                   Name                         CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                         ------------  ----------  ---------------  -------------  ---
  kube-system                 azure-ip-masq-agent-cldc8    100m (1%)     500m (8%)   50Mi (0%)        250Mi (0%)     2m20s
  kube-system                 cloud-node-manager-vj4s4     50m (0%)      0 (0%)      50Mi (0%)        512Mi (0%)     2m20s
  kube-system                 csi-azuredisk-node-sqfkh     30m (0%)      0 (0%)      60Mi (0%)        400Mi (0%)     2m20s
  kube-system                 csi-azurefile-node-rc7tk     30m (0%)      0 (0%)      60Mi (0%)        600Mi (0%)     2m20s
  kube-system                 kube-proxy-lnkd9             100m (1%)     0 (0%)      0 (0%)           0 (0%)         2m20s
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests    Limits
  --------           --------    ------
  cpu                310m (5%)   500m (8%)
  memory             220Mi (0%)  1762Mi (1%)
  ephemeral-storage  0 (0%)      0 (0%)
  hugepages-1Gi      0 (0%)      0 (0%)
  hugepages-2Mi      0 (0%)      0 (0%)
  nvidia.com/gpu     0           0
```

```
# To cleanup
az aks get-credentials -g $rgname -n $clustername
az group delete -n $rgname -y --no-wait
```

- https://learn.microsoft.com/en-us/azure/aks/gpu-cluster
- https://learn.microsoft.com/en-us/azure/aks/gpu-multi-instance
- https://github.com/Azure/aks-gpu
- https://learn.microsoft.com/en-us/azure/azure-linux/intro-azure-linux#azure-linux-container-host-supported-gpu-virtual-machine-sizes
- https://github.com/Azure/AgentBaker/blob/master/vhdbuilder/release-notes/AKSUbuntu/gen2/2204containerd/202412.04.0.txt: nvidia-driver=550.90.12-20241021235610, which means the nvidia driver version 550.90.

## cpu.gpu.driver.amd

- https://learn.microsoft.com/en-us/azure/virtual-machines/windows/n-series-amd-driver-setup

## cpu.gpu.driver.nvidia.cuda

- https://developer.nvidia.com/blog/cuda-refresher-cuda-programming-model/
- https://stackoverflow.com/questions/2392250/understanding-cuda-grid-dimensions-block-dimensions-and-threads-organization-s
- http://thebeardsage.com/cuda-threads-blocks-grids-and-synchronization/
- https://www.reddit.com/r/CUDA/comments/kvhd62/noob_question_what_is_the_purpose_of_the/: [Noob question] What is the purpose of the multidimensional blocks/grids?
- https://www.reddit.com/r/CUDA/comments/s6ullc/how_to_choose_the_grid_size_and_block_size_for_a/: How to Choose the Grid Size and Block Size for a CUDA Kernel?
- https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/gpu-accelerated/nc-series?tabs=sizebasic: NC-series VMs are powered by the NVIDIA Tesla K80 card and the Intel Xeon E5-2690 v3 (Haswell) processor.
- https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/gpu-accelerated/nd-series?tabs=sizebasic: ND instances are powered by NVIDIA Tesla P40 GPUs and Intel Xeon E5-2690 v4 (Broadwell) CPUs.

## cpu.gpu.driver.nvidia.cuda.version

- *https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/index.html#id5: Table 3 CUDA Toolkit and Corresponding Driver Versions
- *https://github.com/Azure/azhpc-extensions/blob/master/NvidiaGPU/resources.json: Latest driver version is at top of the list
- https://developer.nvidia.com/cuda-downloads?target_os=Windows&target_arch=x86_64&target_version=Server2022&target_type=exe_local: Installation Instructions: Double click cuda_12.6.3_561.17_windows.exe (CUDA version 561.17 for Windows)
- https://learn.microsoft.com/en-us/azure/aks/use-windows-gpu#using-windows-gpu-with-automatic-driver-installation: For NC and ND series VM sizes, the CUDA driver is installed.
- https://learn.microsoft.com/en-us/azure/virtual-machines/windows/n-series-driver-setup#nvidia-tesla-cuda-drivers
- https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview#gpu-accelerated

## cpu.gpu.driver.nvidia.grid (vGPU)

- https://docs.nvidia.com/vgpu/latest/grid-vgpu-user-guide/index.html: NVIDIA vGPU software is a graphics virtualization platform that provides virtual machines (VMs) access to NVIDIA GPU technology. 
  - NVIDIA Virtual GPU (vGPU) enables multiple virtual machines (VMs) to have simultaneous, direct access to a single physical GPU, using the same
https://images.nvidia.com/content/pdf/grid/guides/GRID-vGPU-User-Guide.pdf: Under the control of NVIDIA’s GRID Virtual GPU Manager running under the hypervisor, GRID physical GPUs are capable of supporting multiple virtual GPU devices (vGPUs) that can be assigned directly to guest VMs.
  - Guest VMs use GRID virtual GPUs in the same manner as a physical GPU that has been passed through by the hypervisor
https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/gpu-accelerated/nv-series?tabs=sizebasic: The NV-series virtual machines are powered by NVIDIA Tesla M60 GPUs and NVIDIA GRID technology

## cpu.gpu.driver.nvidia.grid.version

- https://github.com/Azure/azhpc-extensions/blob/master/NvidiaGPU/resources.json: Latest driver version is at top of the list
- https://www.nvidia.com/en-us/drivers/virtual-gpu-software-driver/: NVIDIA vGPU Software (Quadro vDWS, GRID vPC, GRID vApps). Customers who have purchased NVIDIA vGPU software can download the drivers from the NVIDIA Licensing Portal. 
- https://www.nvidia.com/en-us/drivers/: Product Category = GRID, Product Series = GRID series, select the Product and Operating System.
- https://learn.microsoft.com/en-us/azure/virtual-machines/windows/n-series-driver-setup#nvidia-gridvgpu-drivers: Microsoft redistributes NVIDIA GRID driver installers for NV, NVv3 and NVads A10 v5-series VMs used as virtual workstations or for virtual applications. Install only these GRID drivers on Azure NV-series VMs, only on the operating systems listed in the following table. These drivers include licensing for GRID Virtual GPU Software in Azure. You don't need to set up a NVIDIA vGPU software license server.
- https://learn.microsoft.com/en-us/azure/aks/use-windows-gpu#using-windows-gpu-with-automatic-driver-installation: For NV series VM sizes, the GRID driver is installed.

## cpu.gpu.driver.OS.linux

- https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/hpccompute-gpu-linux

## cpu.gpu.driver.OS.windows

```
# swedencentral - NCasT4v3 - Standard_NC4as_T4_v3 - https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/gpu-accelerated/ncast4v3-series?tabs=sizebasic
# swedencentral - NCA100v4 - Standard_NC24ads_A100_v4 - https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/gpu-accelerated/nca100v4-series?tabs=sizebasic
WINDOWS_USERNAME=azureuser
rgname=$rg
az group create -n $rg -l $loc
az aks create -g $rg -n akswin --windows-admin-username $WINDOWS_USERNAME --windows-admin-password $WINDOWS_PASSWORD

# Install - Using Windows GPU with automatic driver installation
az aks nodepool add -g $rg --cluster-name akswin -n gpunp -c 1 --os-type Windows --node-vm-size Standard_NC6s_v3 --no-wait

# Install - Specify GPU Driver Type
az aks nodepool add -g $rg --cluster-name akswin -n npgrid -c 2 --os-type Windows --node-vm-size Standard_NC6s_v3 --driver-type GRID --no-wait
az aks nodepool add -g $rg --cluster-name akswin -n npcuda -c 2 --os-type Windows --node-vm-size Standard_NC6s_v3 --driver-type CUDA --no-wait

# Test
cd "C:\Program Files\NVIDIA Corporation\NVSMI"
.\nvidia-smi.exe
```

- https://learn.microsoft.com/en-us/azure/aks/use-windows-gpu: Using NVIDIA GPUs involves the installation of various NVIDIA software components such as the DirectX device plugin for Kubernetes, GPU driver installation, and more
  - For NC and ND series VM sizes, the CUDA driver is installed. For NV series VM sizes, the GRID driver is installed.
  - Because workload and driver compatibility are important for functioning GPU workloads, you can specify the driver type for your Windows GPU node.
- https://github.com/aarnaud/k8s-directx-device-plugin
- https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/hpccompute-gpu-windows
- https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/hpccompute-amd-gpu-windows

## cpu.gpu.driver.OS.windows.containers

- https://learn.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/gpu-acceleration#requirements

## cpu.gpu.sku (HPC)

- https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview#high-performance-compute
  
## cpu.gpu.tools.nvidia-smi

- https://docs.nvidia.com/vgpu/4.5/grid-vgpu-user-guide/index.html#performance-monitoring-gpu: From any supported hypervisor, and from a guest VM that is running a 64-bit edition of Windows or Linux, you can use NVIDIA System Management Interface, nvidia-smi.

## cpu.gpu.workloads

- https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks-gpu/gpu-aks
