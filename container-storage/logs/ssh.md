## ssh

```
ssh azureuser@$ip

TBD
az ssh vm $ip
az ssh vm -g $rgname -n $vm
```

- https://learn.microsoft.com/en-us/cli/azure/ssh

### ssh.os.k8s

```
# See the section on kubectl debug/exec

kubectl cp nsenter-es99e8:/tmp/capture_file_nodeC.pcap /tmp/capture_file_nodeC.pcap --retries=10
```

- https://learn.microsoft.com/en-us/azure/aks/node-access

### ssh.os.windows

```
# Miscellaneous
ssh-keygen -f "/root/.ssh/known_hosts" -R "[127.0.0.1]:2022" ## To optionally remove a saved ECDSA key
ssh-keygen -f "/root/.ssh/known_hosts" -R "10.224.0.91" ## To optionally remove a saved fingerprint for the ECDSA key sent by a remote host
```

- https://learn.microsoft.com/en-us/azure/aks/node-access

## ssh.tools.scp

```
# scp source destination
scp ~/.ssh/id_rsa.pub azureuser@4.225.175.48:~/.ssh/id_rsa.pub
```
