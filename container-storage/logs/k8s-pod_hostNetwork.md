```
# identity the network namespace linked to a hostNetwork pod
# Host network pods operate within the node's network namespace, mapping to the pod's IP (which is the same as the node's IP). This means other processes may also contribute to the network usage within the node's network namespace

k delete po nginx
k run nginx --image=nginx
k delete po exemplo-hostnetwork
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: exemplo-hostnetwork
spec:
  hostNetwork: true
  containers:
  - name: nginx
    image: nginx
EOF
k get po -owide -w

root@aks-nodepool1-14237402-vmss000001:/# crictl ps | grep nginx
CONTAINER           IMAGE               CREATED              STATE               NAME                    ATTEMPT             POD ID              POD
c8702783cb41c       ad5708199ec7d       37 seconds ago       Running             nginx                   0                   edaf23accad8c       exemplo-hostnetwork                   default
3b673f26a412e       ad5708199ec7d       37 seconds ago       Running             nginx                   0                   61be600152499       nginx                                 default

crictl inspect c8702783cb41c | grep pid
crictl inspect 3b673f26a412e | grep pid

pid1=6502
pid2=6457
ls -l /proc/$pid1/ns/net
ls -l /proc/$pid2/ns/net
lrwxrwxrwx 1 root root 0 Aug 27 19:04 /proc/6502/ns/net -> 'net:[4026531840]'
lrwxrwxrwx 1 root root 0 Aug 27 19:04 /proc/6457/ns/net -> 'net:[4026532283]'

readlink /proc/$pid1/ns/net # net:[4026531840]
readlink /proc/$pid2/ns/net # net:[4026532283]

ps -auxH
root        6457  0.0  0.0  11472  7412 ?        Ss   09:03   0:00 nginx: master process nginx -g daemon off;
root        6502  0.0  0.0  11472  7648 ?        Ss   09:03   0:00 nginx: master process nginx -g daemon off;
systemd+    6531  0.0  0.0  11936  2916 ?        S    09:03   0:00 nginx: worker process
systemd+    6532  0.0  0.0  11936  2916 ?        S    09:03   0:00 nginx: worker process
systemd+    6548  0.0  0.0  11936  3072 ?        S    09:03   0:00 nginx: worker process
systemd+    6549  0.0  0.0  11936  3072 ?        S    09:03   0:00 nginx: worker process

pstree -p
systemd(1)-+-agetty(915)
           |-containerd-shim(6311)-+-nginx(6457)-+-nginx(6531)
           |                       |             `-nginx(6532)
           |                       |-pause(6333)
           |                       |-{containerd-shim}(6312)
           |                       |-{containerd-shim}(6313)
           |                       |-{containerd-shim}(6314)
           |                       |-{containerd-shim}(6315)
           |                       |-{containerd-shim}(6316)
           |                       |-{containerd-shim}(6317)
           |                       |-{containerd-shim}(6318)
           |                       |-{containerd-shim}(6319)
           |                       |-{containerd-shim}(6339)
           |                       |-{containerd-shim}(6340)
           |                       |-{containerd-shim}(6550)
           |                       `-{containerd-shim}(42996)
           |-containerd-shim(6364)-+-nginx(6502)-+-nginx(6548)
           |                       |             `-nginx(6549)
           |                       |-pause(6385)
           |                       |-{containerd-shim}(6365)
           |                       |-{containerd-shim}(6366)
           |                       |-{containerd-shim}(6367)
           |                       |-{containerd-shim}(6368)
           |                       |-{containerd-shim}(6369)
           |                       |-{containerd-shim}(6370)
           |                       |-{containerd-shim}(6371)
           |                       |-{containerd-shim}(6372)
           |                       |-{containerd-shim}(6373)
           |                       |-{containerd-shim}(6393)
           |                       `-{containerd-shim}(6641)
```

```
# * root network namespace: corresponds to the namespace with id 0
ip netns list
cni-53113298-c31d-c49a-2718-28c9152a5b55 (id: 1)
cni-199c2b74-656d-6914-e18a-013f3f010017 (id: 0)
```

```
# * node's network namespace (inode: 4026531840): used by the init process (PID 1)
# in this case, the node's network namespace is the same as the root network namespace
readlink /proc/1/ns/net
net:[4026531840]

for pid in $(ls /proc | grep -E '^[0-9]+$'); do
  ns=$(readlink /proc/$pid/ns/net 2>/dev/null)
  if [ "$ns" = "net:[4026531840]" ]; then
    echo "$pid $(cat /proc/$pid/comm)"
  fi
done
6502 nginx
6548 nginx
6549 nginx

ps -eo pid,comm | while read pid comm; do
  ns=$(readlink /proc/$pid/ns/net 2>/dev/null)
  if [ "$ns" = "net:[4026531840]" ]; then
    echo "$pid $comm"
  fi
done
6502 nginx
6548 nginx
6549 nginx
```

```
# * Isolated network namespace (inode 4026532283), likely created by a pod or container that does not have hostNetwork: true.

# inode (4026532283) corresponds to the network namespace named cni-53113298-c31d-c49a-2718-28c9152a5b55, which has id 1
ip netns list
cni-53113298-c31d-c49a-2718-28c9152a5b55 (id: 1)
cni-199c2b74-656d-6914-e18a-013f3f010017 (id: 0)
ls -li /var/run/netns/
total 0
4026532206 -r--r--r-- 1 root root 0 Aug 27 09:02 cni-199c2b74-656d-6914-e18a-013f3f010017
4026532283 -r--r--r-- 1 root root 0 Aug 27 09:03 cni-53113298-c31d-c49a-2718-28c9152a5b55
```

```
# display all pods across namespaces with hostNetwork==true

kubectl get pods -A -o json | jq '.items[] | select(.spec.hostNetwork==true) | [.metadata.namespace, .metadata.name, .spec.nodeName]'
[
  "default",
  "exemplo-hostnetwork",
  "aks-nodepool1-14237402-vmss000001"
]
[
  "kube-system",
  "azure-cns-459wg",
  "aks-nodepool1-14237402-vmss000002"
]

kubectl get pods -A -o json | jq '.items[] | select(.spec.hostNetwork==true and .metadata.namespace != "kube-system") | {namespace: .metadata.namespace, name: .metadata.name, node: .spec.nodeName}'
{
  "namespace": "default",
  "name": "exemplo-hostnetwork",
  "node": "aks-nodepool1-14237402-vmss000001"
}

kubectl get pods -A -o json \
  | jq -r '.items[] | select(.spec.hostNetwork==true and .metadata.namespace != "kube-system") | [.metadata.namespace, .metadata.name, .spec.nodeName] | @tsv' \
  | column -t -s $'\t'
default  exemplo-hostnetwork  aks-nodepool1-14237402-vmss000001
```
