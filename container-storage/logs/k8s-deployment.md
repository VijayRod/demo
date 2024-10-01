```
kubectl create deploy nginx --image=nginx
kubectl scale deploy nginx --replicas 10
kubectl get deploy -w
kubectl get po -l app=nginx

kubectl create deploy nginx --image=nginx --dry-run=client -oyaml 
kubectl rollout restart deploy nginx
kubectl delete deploy nginx
```

- https://kubernetes.io/: K8s, is an open-source system for automating deployment, scaling, and...
- https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/
- https://kubernetes.io/docs/concepts/services-networking/service/: Deployment
- https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
- https://kubernetes.io/docs/tasks/run-application/run-stateless-application-deployment/
- https://kubernetes.io/docs/tutorials/kubernetes-basics/deploy-app/deploy-intro/
