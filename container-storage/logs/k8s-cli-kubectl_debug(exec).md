## kubectl.debug.node
```
# See the section on runcommand
# See the section on kubectl.debug.tools.kubectlnodeshell

kubectl debug node/aks-nodepool1-37663765-vmss000000 -it --image=busybox

node=$(kubectl get no -oname | head -n 1)
kubectl debug $node -it --image=busybox

kubectl debug node/aks-nodepool1-37663765-vmss000000 -it --image=ubuntu # apt update && apt install dnsutils -y
# Use chroot /host, to ensure commands like crictl function

# log files
kubectl debug node/{node-name-xxxx} --image=nginx
kubectl cp node-debugger-{node-name-xxxx}:/host/var/log/messages /tmp/messages
kubectl cp node-debugger-{node-name-xxxx}:/host/var/log/syslog /tmp/syslog
kubectl cp node-debugger-{node-name-xxxx}:/host/var/log/kern.log /tmp/kern.log
kubectl delete po node-debugger-{node-name-xxxx} # Once you have gathered the logs, feel free to remove the debug pod

# log files - copy
kubectl cp nsenter-es99e8:/tmp/capture_file_nodeC.pcap /tmp/capture_file_nodeC.pcap --retries=10
```

- https://kubernetes.io/docs/tasks/debug/debug-cluster/kubectl-node-debug/
- https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#debug
- https://learn.microsoft.com/en-us/azure/aks/node-access

## kubectl.debug.node.tcpdump

```
# See the section on tcpdump k8s

kubectl debug node/aks-nodepool1-14217322-vmss000000 -it --image=mcr.microsoft.com/cbl-mariner/busybox:2.0
# chroot /host
root@aks-nodepool1-14217322-vmss000000:/# tcpdump 1.2.3.4
kubectl cp <debugger podname>:/host/tmp/tcpdump-keda-law.pcap /tmp/tcpdump/tcpdump-keda-law-aks-nodepool1-14217322-vmss000000.pcap

kubectl get po --show-labels
node-debugger-aks-nodepool1-14217322-vmss000000-n6rvn   1/1     Running   0          2m44s   <none>
```
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/logs/capture-tcp-dump-linux-node-aks

### kubectl.debug.pod

```
kubectl debug -it --image=busybox mypod # sh
kubectl debug -it --image=debian:latest mypod # bash. apt update -y && apt install dnsutils -y && apt install curl -y
# Session ended, the ephemeral container will not be restarted but may be reattached using 'kubectl attach nginx -c debugger-gvgsf -i -t' if it is still running
```

### kubectl.debug.pod.exec

```
kubectl exec -it mypod -- /bin/bash
kubectl exec -it mypod -- sh
```

- https://kubernetes.io/docs/tasks/debug/debug-application/get-shell-running-container/
- https://kubernetes.io/docs/reference/kubectl/generated/kubectl_exec/
  
## kubectl.debug.tools.kubectlenter

```
cd /usr/local/bin
wget https://raw.githubusercontent.com/andyzhangx/demo/master/dev/kubectl-enter
chmod a+x ./kubectl-enter
cd ~
```

```
kubectl-enter aks-nodepool1-16524978-vmss000000
```

- https://github.com/andyzhangx/demo/blob/master/dev/kubectl-enter
  
## kubectl.debug.tools.kubectlexec

```
# kubectl-exec
Kuberetes client version is 1.27. Generator will not be used since it is deprecated.
0 aks-nodepool1-20742417-vmss000000
Enter the node number: 0
creating pod "aks-nodepool1-20742417-vmss000000-exec-10398" on node "aks-nodepool1-20742417-vmss000000"
If you don't see a command prompt, try pressing enter.
root@aks-nodepool1-20742417-vmss000000:/#
```

- https://github.com/mohatb/kubectl-exec#installation

## kubectl.debug.tools.kubectlnodeshell

- https://github.com/kvaps/kubectl-node-shell#installation

## kubectl.debug.tools.netshoot

- https://github.com/nicolaka/netshoot?tab=readme-ov-file#the-netshoot-kubectl-plugin: diagram

## kubectl.debug.tools.sshnode

```
wget -P /tmp https://raw.githubusercontent.com/bpinheiro19/k8s-experiments/main/scripts/sshnode/sshnode.sh
chmod +x /tmp/sshnode.sh
/tmp/sshnode.sh
```

```
If you don't see a command prompt, try pressing enter.
root@aks-nodepool1-20742417-vmss000000:/#
```

- https://gist.github.com/bpinheiro19/99763c377efb13b7ba3fd361de70a894
