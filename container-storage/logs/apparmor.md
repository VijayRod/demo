```
root@aks-nodepool1-24666711-vmss000002:/# cat /sys/module/apparmor/parameters/enabled
Y

root@aks-nodepool1-24666711-vmss000002:/# cat /sys/kernel/security/apparmor/profiles | sort
/usr/bin/man (enforce)
/usr/lib/NetworkManager/nm-dhcp-client.action (enforce)
/usr/lib/NetworkManager/nm-dhcp-helper (enforce)
/usr/lib/connman/scripts/dhclient-script (enforce)
/usr/sbin/chronyd (enforce)
/{,usr/}sbin/dhclient (enforce)
cri-containerd.apparmor.d (enforce)
lsb_release (enforce)
man_filter (enforce)
man_groff (enforce)
nvidia_modprobe (enforce)
nvidia_modprobe//kmod (enforce)
tcpdump (enforce)
ubuntu_pro_apt_news (enforce)
ubuntu_pro_esm_cache (enforce)
ubuntu_pro_esm_cache//apt_methods (enforce)
ubuntu_pro_esm_cache//apt_methods_gpgv (enforce)
ubuntu_pro_esm_cache//cloud_id (enforce)
ubuntu_pro_esm_cache//dpkg (enforce)
ubuntu_pro_esm_cache//ps (enforce)
ubuntu_pro_esm_cache//ubuntu_distro_info (enforce)
ubuntu_pro_esm_cache_systemctl (enforce)
ubuntu_pro_esm_cache_systemd_detect_virt (enforce)

root@aks-nodepool1-24666711-vmss000002:/# apparmor_status
# root@aks-nodepool1-24666711-vmss000002:/# aa-status
apparmor module is loaded.
23 profiles are loaded.
23 profiles are in enforce mode.
   /usr/bin/man
   /usr/lib/NetworkManager/nm-dhcp-client.action
   /usr/lib/NetworkManager/nm-dhcp-helper
   /usr/lib/connman/scripts/dhclient-script
   /usr/sbin/chronyd
   /{,usr/}sbin/dhclient
   cri-containerd.apparmor.d
   lsb_release
   man_filter
   man_groff
   nvidia_modprobe
   nvidia_modprobe//kmod
   tcpdump
   ubuntu_pro_apt_news
   ubuntu_pro_esm_cache
   ubuntu_pro_esm_cache//apt_methods
   ubuntu_pro_esm_cache//apt_methods_gpgv
   ubuntu_pro_esm_cache//cloud_id
   ubuntu_pro_esm_cache//dpkg
   ubuntu_pro_esm_cache//ps
   ubuntu_pro_esm_cache//ubuntu_distro_info
   ubuntu_pro_esm_cache_systemctl
   ubuntu_pro_esm_cache_systemd_detect_virt
0 profiles are in complain mode.
0 profiles are in kill mode.
0 profiles are in unconfined mode.
17 processes have profiles defined.
17 processes are in enforce mode.
   /usr/sbin/chronyd (823)
   /usr/sbin/chronyd (824)
   /ip-masq-agent-v2 (5139) cri-containerd.apparmor.d
   /livenessprobe (5179) cri-containerd.apparmor.d
   /livenessprobe (5195) cri-containerd.apparmor.d
   /usr/local/bin/cloud-node-manager (5226) cri-containerd.apparmor.d
   /csi-node-driver-registrar (5363) cri-containerd.apparmor.d
   /csi-node-driver-registrar (5414) cri-containerd.apparmor.d
   /pod_nanny (7060) cri-containerd.apparmor.d
   /coredns (7107) cri-containerd.apparmor.d
   /coredns (7127) cri-containerd.apparmor.d
   /pod_nanny (7143) cri-containerd.apparmor.d
   /proxy-agent (7153) cri-containerd.apparmor.d
   /proxy-agent (7155) cri-containerd.apparmor.d
   /cluster-proportional-autoscaler (7327) cri-containerd.apparmor.d
   /metrics-server (7427) cri-containerd.apparmor.d
   /metrics-server (7452) cri-containerd.apparmor.d
0 processes are in complain mode.
0 processes are unconfined but have a profile defined.
0 processes are in mixed mode.
0 processes are in kill mode.

root@aks-nodepool1-24666711-vmss000002:/# cat /var/log/syslog | grep audit | grep apparmor
Nov 13 18:01:53 aks-nodepool1-24666711-vmss000002 kernel: [ 1239.698543] audit: type=1400 audit(1731492113.325:28): apparmor="STATUS" operation="profile_load" profile="unconfined" name="cri-containerd.apparmor.d" pid=5106 comm="apparmor_parser"
```

- https://lwn.net/Kernel/Index/#AppArmor

## apparmor.k8s

```
k describe no
Conditions:
  Type                          Status  LastHeartbeatTime                 LastTransitionTime                Reason                          Message
  ----                          ------  -----------------                 ------------------                ------                          -------
  Ready                         True    Wed, 13 Nov 2024 19:00:43 +0000   Wed, 13 Nov 2024 18:01:46 +0000   KubeletReady                    kubelet is posting ready status. AppArmor enabled
```

- https://kubernetes.io/docs/tutorials/security/apparmor/
- https://learn.microsoft.com/en-us/azure/aks/secure-container-access#app-armor
- https://learn.microsoft.com/en-us/azure/aks/developer-best-practices-pod-security#secure-pod-access-to-resources: There are additional security features to limit access using AppArmor and seccomp (secure computing) that can be implemented by cluster operators.
- https://learn.microsoft.com/en-us/azure/aks/operator-best-practices-cluster-security?tabs=azure-cli#secure-container-access-to-resources: For even more granular control of container actions, you can also use built-in Linux security features such as AppArmor and seccomp.
- https://learn.microsoft.com/en-us/azure/aks/policy-reference: Kubernetes cluster containers should only use allowed AppArmor profiles
- https://techcommunity.microsoft.com/blog/azurearchitectureblog/azure-kubernetes-service-security-deep-dive-%E2%80%93-part-2-apparmor-and-seccomp/3013977
