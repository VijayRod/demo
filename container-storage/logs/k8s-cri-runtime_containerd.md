## k8s.cri.containerd

```
# See the section on storage-device-filesystem_overlayfs
# apt install containerd

root@aks-nodepool1-24666711-vmss000002:/# containerd --version
containerd github.com/containerd/containerd 1.7.22-1 7f7fdf5fed64eb6a7caf99b3e12efcf9d60e311c

kubectl get no -owide
NAME                                STATUS   ROLES   AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION      CONTAINER-RUNTIME
aks-nodepool1-11303738-vmss00000w   Ready    agent   124m   v1.25.6   10.224.0.217   <none>        Ubuntu 22.04.2 LTS               5.15.0-1039-azure   containerd://1.7.1+azure-1
aksnp201900000o                     Ready    agent   121m   v1.25.6   10.224.0.66    <none>        Windows Server 2019 Datacenter   10.0.17763.4499     containerd://1.6.21+azure

journalctl -u kubelet > /tmp/kubelet.log && journal -u containerd > /tmp/containerd.log

root@aks-nodepool1-74128781-vmss000000:/# systemctl status containerd
? containerd.service - containerd container runtime
     Loaded: loaded (/lib/systemd/system/containerd.service; enabled; vendor preset: enabled)
    Drop-In: /etc/systemd/system/containerd.service.d
             +-exec_start.conf
     Active: active (running) since Tue 2024-10-22 19:44:20 UTC; 23h ago
       Docs: https://containerd.io
   Main PID: 2707 (containerd)
      Tasks: 172
     Memory: 503.3M
        CPU: 14min 4.184s
     CGroup: /system.slice/containerd.service
             +-   2707 /usr/bin/containerd
             +-   4074 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id e5eee94578058c89a111d0404068ee7b038e3>
             +-   4075 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id 6505aaeb42f1a6e7978887be9b0023d94de6b>
             +-   4076 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id d2f1d96289d0ff7b9cddc2974ad4ad1f0c800>
             +-   4077 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id fdc189f8e3213442bc60a78a4294593683dca>
             +-   4078 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id 37b80840be414b18b96e0ac592e334185421f>
             +-   5874 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id 080e846f519dea600ac80fe0c692930f0a348>
             +-   6033 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id 6c637c02f18482010cf3b8f26ce6644b3262b>
             +-   6098 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id 5be69dd9d1d75b3fde55a346c418f43259a10>
             +-  19343 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id 5eeb8c271960c1e86cd16a6d245b215136f50>
             +- 190889 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id 16750360f18f6ed74d8b6191bdaff61657213>
             +-1427453 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id e5e0764cfc5ce9f6a30a18b5e578d80da0992>
             +-1441158 /usr/bin/containerd-shim-runc-v2 -namespace k8s.io -id 5fff0416fb4622634597df719a3d7b63dd9f4>
Oct 23 19:25:39 aks-nodepool1-74128781-vmss000000 containerd[2707]: time="2024-10-23T19:25:39.019784818Z" level=inf>
Oct 23 19:25:39 aks-nodepool1-74128781-vmss000000 containerd[2707]: time="2024-10-23T19:25:39.031172634Z" level=inf>
Oct 23 19:25:39 aks-nodepool1-74128781-vmss000000 containerd[2707]: time="2024-10-23T19:25:39.037074691Z" level=inf>
Oct 23 19:25:39 aks-nodepool1-74128781-vmss000000 containerd[2707]: time="2024-10-23T19:25:39.042521651Z" level=inf>
...
```

```
systemctl restart containerd
```

- https://kubernetes.io/docs/setup/production-environment/container-runtimes/
- https://azure.microsoft.com/en-us/updates/azure-kubernetes-service-aks-support-for-containerd-runtime-is-in-preview/
- https://learn.microsoft.com/en-us/azure/aks/cluster-configuration#container-runtime-configuration
- https://learn.microsoft.com/en-us/azure/aks/learn/quick-windows-container-deploy-cli#connect-to-the-cluster
- https://docs.docker.com/desktop/features/containerd/#what-is-containerd
- https://cloud.google.com/kubernetes-engine/docs/troubleshooting/container-runtime
  
## k8s.cri.containerd.containerd-shim

```
root@aks-nodepool1-33178142-vmss000000:/# df -h
shm              64M     0   64M   0% /run/containerd/io.containerd.grpc.v1.cri/sandboxes/2a1be93f6966eb4a720ccadb38c09d4d773302f6d153faf92b131803e41989e0/shm
shm              64M     0   64M   0% /run/containerd/io.containerd.grpc.v1.cri/sandboxes/2a19e574f2fb1960534b43dc64437f1ec9f941d494103c2018592838a5ae1a0b/shm
```

- https://github.com/containerd/containerd/issues/370: Can containerd be restarted and recover all running containers? yes. Every container has a containerd-shim to supervise the container, even if the containerd stop, the container can keep on running, and once containerd restart, it can recover all running contaners by restore the /run/docker/libcontainerd
