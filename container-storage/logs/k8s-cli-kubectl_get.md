```
kubectl get po -A --show-labels
kubectl get po -A -l k8s-app=kube-dns

# Retrieve the name
kubectl get pods --no-headers -o custom-columns=":metadata.name" # nginx
kubectl get pods -o=name # pod/nginx
var=$(kubectl get po -n kube-system -l k8s-app=kube-dns --no-headers=true | head -n 1 | awk '{print $1}'); echo $var # nginx
```

- https://kubernetes.io/docs/reference/kubectl/cheatsheet/#viewing-and-finding-resources
- https://kubernetes.io/docs/tasks/access-application-cluster/list-all-running-container-images/
- https://stackoverflow.com/questions/35797906/kubernetes-list-all-running-pods-name
- https://stackoverflow.com/questions/51611868/how-do-i-get-a-single-pod-name-for-kubernetes
