```
cat $HOME/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ...
    
az aks get-credentials -g $rg -n aks --overwrite-existing
The behavior of this command has been altered by the following extension: aks-preview
Merged "aks" as current context in /root/.kube/config
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

- https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/: kubectl looks for a file named config in the $HOME/.kube directory. You can specify other kubeconfig files by setting the KUBECONFIG environment variable or by setting the --kubeconfig flag.
- https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/
