```
cat $HOME/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ...
    
az aks get-credentials -g $rg -n aks --overwrite-existing
The behavior of this command has been altered by the following extension: aks-preview
Merged "aks" as current context in /root/.kube/config
# Merged "aks" as current context in /home/vijayrod/.kube/config
ls -l ~/.kube
drwxr-x--- 4 userredacted userredacted 4096 Oct 28 18:44 cache
-rw-r--r-- 1 userredacted userredacted 9660 Oct 29 19:14 config
```

```
rm /tmp/config-demo
az aks get-credentials -g $rg -n aks -f /tmp/config-demo # cat /tmp/config-demo
kubectl config use-context aks --kubeconfig=/tmp/config-demo
kubectl get po

kubectl config set current-context aks --v=9 # Use to reset which means ${HOME}/.kube/config will be utilized
I0806 18:20:12.298355     174 loader.go:373] Config loaded from file:  /root/.kube/config
I0806 18:20:12.302055     174 loader.go:373] Config loaded from file:  /root/.kube/config
Property "current-context" set.
```

```
## copy and paste the kubeconfig from a different system
cat << EOF > $HOME/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tredacted
    server: https://aks-rg-efec8e-443ozcvu.hcp.swedencentral.azmk8s.io:443
  name: aks
contexts:
- context:
    cluster: aks
    user: clusterUser_rg_aks
  name: aks
current-context: aks
kind: Config
preferences: {}
users:
- name: clusterUser_rg_aks
  user:
    client-certificate-data: LS0tredacted==
    client-key-data: LS0tredacted
    token: LS0tredacted
EOF
cat $HOME/.kube/config
kubectl get ns
```

- https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/: kubectl looks for a file named config in the $HOME/.kube directory. You can specify other kubeconfig files by setting the KUBECONFIG environment variable or by setting the --kubeconfig flag.
- https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/
