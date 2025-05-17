```
kubectl describe po
kubectl describe po | grep A5 State
    Last State:     Terminated
      Reason:       ContainerStatusUnknown
      Message:      The container could not be located when the pod was deleted.  The container used to be Running
      Exit Code:    137
      Started:      Mon, 01 Jan 0001 00:00:00 +0000
      Finished:     Mon, 01 Jan 0001 00:00:00 +0000
```

- https://github.com/kubernetes/kubernetes/blob/master/pkg/apis/core/types.go: type ContainerStateTerminated struct {	ExitCode int32
- https://cloud.google.com/kubernetes-engine/docs/troubleshooting#check_exit_code_of_the_crashed_container
- https://docs.docker.com/engine/reference/run/#exit-status
- https://github.com/kodekloudhub/throw-dice/blob/master/throw-dice.sh
- https://github.com/kubernetes/kubernetes/issues/82519: The Exit Code is obtained from docker's ExitCode. Normally it will be the exit status of the process
- https://komodor.com/learn/exit-codes-in-containers-and-kubernetes-the-complete-guide/: SIGKILL, SIGSEGV, SIGTERM
  - https://komodor.com/learn/what-is-sigkill-signal-9-fast-termination-of-linux-containers/
  - https://komodor.com/learn/sigsegv-segmentation-faults-signal-11-exit-code-139/
  - https://komodor.com/learn/sigterm-signal-15-exit-code-143-linux-graceful-termination/
  - bash: kill -l // 9) SIGKILL, 11) SIGSEGV, 15) SIGTERM
  - bash: kill -n 9 <pid> // SIGKILL
- https://kubernetes.io/docs/tasks/debug/debug-application/determine-reason-pod-failure/
- https://stackoverflow.com/questions/31297616/what-is-the-authoritative-list-of-docker-run-exit-codes
- https://tldp.org/LDP/abs/html/exitcodes.html: Exit Codes With Special Meanings
- https://www.datree.io/resources/kubernetes-error-codes-crashloopbackoff: An exit code ranging from 1 to 128 would show an exit stemming from internal (app) signals.
- https://www.man7.org/linux/man-pages/man7/signal.7.html: Signal numbering for standard signals
- https://www.tencentcloud.com/document/product/457/35758: value of the exit code is the value of the interrupt signal plus 128

```
root@aks-nodepool1-29985679-vmss00000A:/# kill -l
 1) SIGHUP       2) SIGINT       3) SIGQUIT      4) SIGILL       5) SIGTRAP
 6) SIGABRT      7) SIGBUS       8) SIGFPE       9) SIGKILL     10) SIGUSR1
11) SIGSEGV     12) SIGUSR2     13) SIGPIPE     14) SIGALRM     15) SIGTERM
16) SIGSTKFLT   17) SIGCHLD     18) SIGCONT     19) SIGSTOP     20) SIGTSTP
21) SIGTTIN     22) SIGTTOU     23) SIGURG      24) SIGXCPU     25) SIGXFSZ
26) SIGVTALRM   27) SIGPROF     28) SIGWINCH    29) SIGIO       30) SIGPWR
31) SIGSYS      34) SIGRTMIN    35) SIGRTMIN+1  36) SIGRTMIN+2  37) SIGRTMIN+3
38) SIGRTMIN+4  39) SIGRTMIN+5  40) SIGRTMIN+6  41) SIGRTMIN+7  42) SIGRTMIN+8
43) SIGRTMIN+9  44) SIGRTMIN+10 45) SIGRTMIN+11 46) SIGRTMIN+12 47) SIGRTMIN+13
48) SIGRTMIN+14 49) SIGRTMIN+15 50) SIGRTMAX-14 51) SIGRTMAX-13 52) SIGRTMAX-12
53) SIGRTMAX-11 54) SIGRTMAX-10 55) SIGRTMAX-9  56) SIGRTMAX-8  57) SIGRTMAX-7
58) SIGRTMAX-6  59) SIGRTMAX-5  60) SIGRTMAX-4  61) SIGRTMAX-3  62) SIGRTMAX-2
63) SIGRTMAX-1  64) SIGRTMAX
```

> ## exitCode=0

```
# sample.test
# kill 15 (128+15=143) (tbd) with "exitCode=0"

k run nginx --image=nginx
k get po -owide -w

root@aks-nodepool1-29985679-vmss00000A:/# ps -aux | grep nginx
root      219567  0.0  0.0  11464  7368 ?        Ss   11:58   0:00 nginx: master process nginx -g daemon off;
systemd+  219603  0.0  0.0  11928  2764 ?        S    11:58   0:00 nginx: worker process
systemd+  219604  0.0  0.0  11928  2764 ?        S    11:58   0:00 nginx: worker process
root@aks-nodepool1-29985679-vmss00000A:/# kill -n 15 219567

k get po
NAME             READY   STATUS    RESTARTS      AGE
nginx            1/1     Running   1 (11s ago)   2m30s

# Exit Code:    0
k describe po nginx
Containers:
  nginx:
    Container ID:   containerd://68309eece1d6bf91d3f5c8730012cb2ca0e393059f4062da4d2d1598d040a267
    Image:          nginx
    Image ID:       docker.io/library/nginx@sha256:c15da6c91de8d2f436196f3a768483ad32c258ed4e1beb3d367a27ed67253e66
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Fri, 16 May 2025 18:00:45 +0000
    Last State:     Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Fri, 16 May 2025 18:00:30 +0000
      Finished:     Fri, 16 May 2025 18:00:43 +0000
    Ready:          True
    Restart Count:  1
    
# ContainerDied, exitCode=0
root@aks-nodepool1-29985679-vmss00000A:/# cat /var/log/syslog | grep "May 16 18:02:"
May 16 18:02:43 aks-nodepool1-29985679-vmss00000A systemd[1]: cri-containerd-f51267392f05152ad8ef082073f1b65abea345f4d4445cf079acd0d770374a1c.scope: Deactivated successfully.
May 16 18:02:43 aks-nodepool1-29985679-vmss00000A containerd[3039]: time="2025-05-16T18:02:43.754610904Z" level=info msg="received exit event container_id:\"f51267392f05152ad8ef082073f1b65abea345f4d4445cf079acd0d770374a1c\"  id:\"f51267392f05152ad8ef082073f1b65abea345f4d4445cf079acd0d770374a1c\"  pid:219567  exited_at:{seconds:1747396843  nanos:754293507}"
May 16 18:02:43 aks-nodepool1-29985679-vmss00000A systemd[1]: run-containerd-io.containerd.runtime.v2.task-k8s.io-f51267392f05152ad8ef082073f1b65abea345f4d4445cf079acd0d770374a1c-rootfs.mount: Deactivated successfully.
May 16 18:02:43 aks-nodepool1-29985679-vmss00000A containerd[3039]: time="2025-05-16T18:02:43.772912023Z" level=info msg="shim disconnected" id=f51267392f05152ad8ef082073f1b65abea345f4d4445cf079acd0d770374a1c namespace=k8s.io
May 16 18:02:43 aks-nodepool1-29985679-vmss00000A containerd[3039]: time="2025-05-16T18:02:43.772957423Z" level=warning msg="cleaning up after shim disconnected" id=f51267392f05152ad8ef082073f1b65abea345f4d4445cf079acd0d770374a1c namespace=k8s.io
May 16 18:02:43 aks-nodepool1-29985679-vmss00000A containerd[3039]: time="2025-05-16T18:02:43.772965922Z" level=info msg="cleaning up dead shim" namespace=k8s.io
May 16 18:02:44 aks-nodepool1-29985679-vmss00000A kubelet[4052]: I0516 18:00:44.655347    4052 kubelet.go:2439] "SyncLoop (PLEG): event for pod" pod="default/nginx" event={"ID":"7ed0f963-37b7-4383-9d94-77e3a5afb787","Type":"ContainerDied","Data":"f51267392f05152ad8ef082073f1b65abea345f4d4445cf079acd0d770374a1c"}
May 16 18:02:44 aks-nodepool1-29985679-vmss00000A kubelet[4052]: I0516 18:00:44.655636    4052 scope.go:117] "RemoveContainer" containerID="f51267392f05152ad8ef082073f1b65abea345f4d4445cf079acd0d770374a1c"
May 16 18:02:44 aks-nodepool1-29985679-vmss00000A kubelet[4052]: I0516 18:00:44.655940    4052 generic.go:334] "Generic (PLEG): container finished" podID="7ed0f963-37b7-4383-9d94-77e3a5afb787" containerID="f51267392f05152ad8ef082073f1b65abea345f4d4445cf079acd0d770374a1c" exitCode=0
May 16 18:02:44 aks-nodepool1-29985679-vmss00000A containerd[3039]: time="2025-05-16T18:02:44.656458081Z" level=info msg="PullImage \"nginx:latest\""
..May 16 18:02:45 aks-nodepool1-29985679-vmss00000A containerd[3039]: time="2025-05-16T18:02:45.506941536Z" level=info msg="CreateContainer within sandbox \"0a1d10b0bff7e6307119369f84142b36e59131b3ff97ffd022bf5d99f7564e97\" for container &ContainerMetadata{Name:nginx,Attempt:1,}"
```
