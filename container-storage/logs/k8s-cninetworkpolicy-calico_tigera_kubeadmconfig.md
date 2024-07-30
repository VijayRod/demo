```
kubectl delete cm -n kube-system kubeadm-config
```

- https://github.com/tigera/operator/blob/master/pkg/controller/installation/core_controller.go: key := types.NamespacedName{Name: kubeadmConfigMap, Namespace: metav1.NamespaceSystem}
