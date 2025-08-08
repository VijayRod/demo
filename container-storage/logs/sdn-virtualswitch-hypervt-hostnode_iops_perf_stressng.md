> ## stress.k8s.polinux/stress
```
# stress.k8s.polinux/stress.cpu-mem

# utilize the max of both cpu and memory resources
# the args include cpu (--cpu) and memory (--vm x --vm-bytes), where --vm specifies the number of worker processes
kubectl delete po max-resource-pod
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: max-resource-pod
spec:
  containers:
  - name: stress-container
    image: polinux/stress
    command: ["stress"]
    args:
    - "--cpu"
    - "4"
    - "--vm"
    - "2"
    - "--vm-bytes"
    - "4G"
    - "--timeout"
    - "60s"
    resources:
      requests:
        cpu: "1"       # requests 4 CPUs
        memory: "128Mi"  # requests 8 GB de RAM
      limits:
        cpu: "4"       # limits to 4 CPUs
        memory: "8Gi"  # limits to 8 GB de RAM
EOF
kubectl get po -owide -w

NAME               READY   STATUS      RESTARTS     AGE
max-resource-pod   0/1     OOMKilled   1 (9s ago)   14s
max-resource-pod   0/1     CrashLoopBackOff   1 (15s ago)   24s
max-resource-pod   1/1     Running            2 (16s ago)   25s
max-resource-pod   0/1     OOMKilled          2 (19s ago)   28s
max-resource-pod   0/1     CrashLoopBackOff   2 (12s ago)   40s

k describe no
Memory cgroup out of memory: Killed process 65541 (stress) total-vm:4195088kB, anon-rss:2878112kB, file-rss:256kB, shmem-rss:0kB, UID:0 pgtables:5676kB oom_score_adj:872
  Warning  OOMKilling          95s (x13 over 2m23s)   kernel-monitor
  
cat /var/log/syslog
Jun 24 18:49:43 aks-nodepool1-31060421-vmss000002 kernel: [ 8341.856856] oom-kill:constraint=CONSTRAINT_MEMCG,nodemask=(null),cpuset=cri-containerd-178ec18073cc6ac7be2de8d9869daf162a6349dd056b6535849112c53ec3102a.scope,mems_allowed=0,oom_memcg=/kubepods.slice,task_memcg=/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod10d16a28_60ff_475f_a631_510d9792219f.slice/cri-containerd-178ec18073cc6ac7be2de8d9869daf162a6349dd056b6535849112c53ec3102a.scope,task=stress,pid=68061,uid=0
Jun 24 18:49:43 aks-nodepool1-31060421-vmss000002 kernel: [ 8341.856870] Memory cgroup out of memory: Killed process 68061 (stress) total-vm:4195088kB, anon-rss:2884696kB, file-rss:288kB, shmem-rss:0kB, UID:0 pgtables:5696kB oom_score_adj:872
Jun 24 18:49:43 aks-nodepool1-31060421-vmss000002 kernel: [ 8341.868335] Tasks in /kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod10d16a28_60ff_475f_a631_510d9792219f.slice/cri-containerd-178ec18073cc6ac7be2de8d9869daf162a6349dd056b6535849112c53ec3102a.scope are going to be killed due to memory.oom.group set
Jun 24 18:49:43 aks-nodepool1-31060421-vmss000002 kernel: [ 8341.890658] Memory cgroup out of memory: Killed process 68061 (stress) total-vm:4195088kB, anon-rss:2884696kB, file-rss:288kB, shmem-rss:0kB, UID:0 pgtables:5696kB oom_score_adj:872

Jun 24 18:49:43 aks-nodepool1-31060421-vmss000002 node-problem-detector-startup.sh[6018]: I0624 18:49:43.983472    6018 log_monitor.go:159] New status generated: &{Source:kernel-monitor Events:[{Severity:warn Timestamp:2025-06-24 18:49:43.405414777 +0000 UTC m=+3230.998142221 Reason:OOMKilling Message:Memory cgroup out of memory: Killed process 68061 (stress) total-vm:4195088kB, anon-rss:2884696kB, file-rss:288kB, shmem-rss:0kB, UID:0 pgtables:5696kB oom_score_adj:872}] Conditions:[{Type:KernelDeadlock Status:False Transition:2025-06-24 17:55:52.550304771 +0000 UTC m=+0.143032315 Reason:KernelHasNoDeadlock Message:kernel has no deadlock} {Type:ReadonlyFilesystem Status:False Transition:2025-06-24 15:55:52.550304971 +0000 UTC m=+0.143032415 Reason:FilesystemIsNotReadOnly Message:Filesystem is not read-only}]}
```

```
# stress.k8s.polinux/stress.cpu

kubectl delete po max-cpu-pod
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: max-cpu-pod
spec:
  containers:
  - name: stress-container
    image: polinux/stress
    command: ["stress"]
    args:
    - "--cpu"
    - "4"
    - "--timeout"
    - "300s" # 60s
    resources:
      requests:
        cpu: "1"
        memory: "128Mi" 
      limits:
        cpu: "4"
        memory: "256Mi"
EOF
kubectl get po -owide -w

k top no
NAME                                CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
aks-nodepool1-31060421-vmss000002   1964m        103%   1394Mi          24%

kubectl top po --sort-by=cpu --containers=true
POD              NAME               CPU(cores)   MEMORY(bytes)
max-cpu-pod      stress-container   1890m        0Mi

top
top - 19:05:12 up  2:34,  0 users,  load average: 3.40, 1.79, 0.82
Tasks: 159 total,   5 running, 153 sleeping,   0 stopped,   1 zombie
%Cpu(s): 98.9 us,  1.1 sy,  0.0 ni,  0.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :   7939.5 total,   5531.3 free,    837.9 used,   1570.3 buff/cache
MiB Swap:      0.0 total,      0.0 free,      0.0 used.   6814.4 avail Mem
    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
  85702 root      20   0     780     40      0 R  48.1   0.0   0:18.95 stress
  85699 root      20   0     780     40      0 R  47.4   0.0   0:19.15 stress
  85700 root      20   0     780     40      0 R  46.5   0.0   0:18.83 stress
  85701 root      20   0     780     40      0 R  46.5   0.0   0:19.09 stress
```

```
# stress.k8s.polinux/stress.memory

kubectl delete po max-resource-pod
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: max-resource-pod
spec:
  containers:
  - name: stress-container
    image: polinux/stress
    command: ["stress"]
    args:
    - "--vm"
    - "2"
    - "--vm-bytes"
    - "4G"
    - "--timeout"
    - "300s"
EOF
kubectl get po -owide -w

# or using the following
    resources:
      requests:
        cpu: "1"       # requests 4 CPUs
        memory: "128Mi"  # requests 8 GB de RAM
      limits:
        cpu: "4"       # limits to 4 CPUs
        memory: "8Gi"  # limits to 8 GB de RAM
```

> ## stress.k8s.stress-ng
- https://github.com/ColinIanKing/stress-ng#debian-packages-for-ubuntu: stress-ng (stress next generation)
- https://wiki.ubuntu.com/Kernel/Reference/stress-ng
  
```
# stress.k8s.stress-ng.cpu

kubectl delete po stress-ng-cpu
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: stress-ng-cpu
spec:
  containers:
  - name: stress-ng
    image: ubuntu
    command: ["/bin/sh", "-c"]
    args:
      - |
        apt update && \
        apt install -y stress-ng && \
        stress-ng --cpu 0 --timeout 300s # utilize all CPUs that are available
EOF
k get po -owide -w
# kubectl logs stress-ng-cpu # -p

k top no
NAME                                CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
aks-nodepool1-31060421-vmss000002   2000m        105%   1529Mi          26%

k top po --sort-by=cpu
NAME             CPU(cores)   MEMORY(bytes)
stress-ng-cpu    1884m        116Mi
```

```
# stress.k8s.stress-ng.memory

kubectl delete po max-memory-pod
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: max-memory-pod
spec:
  containers:
  - name: stress-mem
    image: ubuntu
    command: ["/bin/sh", "-c"]
    args:
      - |
        apt update && \
        apt install -y stress-ng && \
        stress-ng --vm 2 --vm-bytes 3G --vm-hang 1 --timeout 300s # --vm-hang keeps the allocation instead of allocate and deallocate
EOF
k get po -owide -w
# kubectl logs stress-ng-cpu # -p

k top no
NAME                                CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
aks-nodepool1-31060421-vmss000002   1783m        93%    4632Mi          79%

k top po --sort-by=memory
```

> ## stress.k8s.stress

```
# stress.k8s.stress

cat << EOF | kubectl create -f - 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stress
spec:
  replicas: 1
  selector:
    matchLabels:
      app: stress
  template:
    metadata:
      labels:
        app: stress
    spec:
      containers:
      - name: stress
        image: ubuntu
        imagePullPolicy: IfNotPresent
        env:
        command: ["/bin/bash"]
        args: ["-c", "apt-get update; apt-get install stress -y;stress --vm 1 --vm-bytes 100M"]
        resources:
          limits:
            memory: 123Mi
          requests:
            memory: 100Mi
EOF
kubectl get po -w
# k exec -it stress-764ff7cfbf-d2z5w -- /bin/bash
# stress --vm 1 --vm-bytes 50M
# k describe po -l app=stress | grep OOM # Reason:       OOMKilled
```
