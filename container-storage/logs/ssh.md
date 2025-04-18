## ssh

```
ssh azureuser@$ip

TBD
az ssh vm $ip
az ssh vm -g $rgname -n $vm
```

- https://learn.microsoft.com/en-us/cli/azure/ssh

## ssh.spec.other.bash

```
# manually copy ssh creds from one system to another

# source
ls -l ~/.ssh/
cat ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub

# destination
mkdir ~/.ssh/
cat << EOF > ~/.ssh/id_rsa
-----BEGIN RSA PRIVATE KEY-----
content==
-----END RSA PRIVATE KEY-----
EOF
cat << EOF > ~/.ssh/id_rsa.pub
ssh-rsa content
EOF
```

## ssh.spec.other.keys

```
ls -l ~/.ssh/
-rw------- 1 userredacted userredacted 1679 Oct 29 19:27 id_rsa
-rw-r--r-- 1 userredacted userredacted  380 Oct 29 19:27 id_rsa.pub

# aks
az aks create -g $rg -n aks --generate-ssh-keys -s $vmsize -c 2
SSH key files '/home/userredacted/.ssh/id_rsa' and '/home/userredacted/.ssh/id_rsa.pub' have been generated under ~/.ssh to allow SSH access to the VM. If using machines without permanent storage like Azure Cloud Shell without an attached file share, back up your keys to a safe location
The new node pool will enable SSH access, recommended to use '--ssh-access disabled' option to disable SSH access for the node pool to make it more secure.
```

### ssh.spec.other.os.k8s

```
# See the section on kubectl debug/exec
```

- https://learn.microsoft.com/en-us/azure/aks/node-access

### ssh.spec.other.os.windows

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
