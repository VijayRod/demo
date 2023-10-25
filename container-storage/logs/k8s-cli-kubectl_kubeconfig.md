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

- https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/: kubectl looks for a file named config in the $HOME/.kube directory. You can specify other kubeconfig files by setting the KUBECONFIG environment variable or by setting the --kubeconfig flag.
- https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/
