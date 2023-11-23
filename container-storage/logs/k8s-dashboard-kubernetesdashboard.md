```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
namespace/kubernetes-dashboard created
serviceaccount/kubernetes-dashboard created
service/kubernetes-dashboard created
secret/kubernetes-dashboard-certs created
secret/kubernetes-dashboard-csrf created
secret/kubernetes-dashboard-key-holder created
configmap/kubernetes-dashboard-settings created
role.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrole.rbac.authorization.k8s.io/kubernetes-dashboard created
rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
deployment.apps/kubernetes-dashboard created
service/dashboard-metrics-scraper created
deployment.apps/dashboard-metrics-scraper created

kubectl proxy
Starting to serve on 127.0.0.1:8001
# http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

```
kubectl get all -n kubernetes-dashboard --show-labels
NAME                                             READY   STATUS    RESTARTS   AGE   LABELS
pod/dashboard-metrics-scraper-5cb4f4bb9c-jd2cg   1/1     Running   0          94s   k8s-app=dashboard-metrics-scraper,pod-template-hash=5cb4f4bb9c
pod/kubernetes-dashboard-6967859bff-zzt6f        1/1     Running   0          94s   k8s-app=kubernetes-dashboard,pod-template-hash=6967859bff

NAME                                TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE   LABELS
service/dashboard-metrics-scraper   ClusterIP   10.0.168.15    <none>        8000/TCP   94s   k8s-app=dashboard-metrics-scraper
service/kubernetes-dashboard        ClusterIP   10.0.128.224   <none>        443/TCP    96s   k8s-app=kubernetes-dashboard

NAME                                        READY   UP-TO-DATE   AVAILABLE   AGE   LABELS
deployment.apps/dashboard-metrics-scraper   1/1     1            1           94s   k8s-app=dashboard-metrics-scraper
deployment.apps/kubernetes-dashboard        1/1     1            1           94s   k8s-app=kubernetes-dashboard

NAME                                                   DESIRED   CURRENT   READY   AGE   LABELS
replicaset.apps/dashboard-metrics-scraper-5cb4f4bb9c   1         1         1       95s   k8s-app=dashboard-metrics-scraper,pod-template-hash=5cb4f4bb9c
replicaset.apps/kubernetes-dashboard-6967859bff        1         1         1       95s   k8s-app=kubernetes-dashboard,pod-template-hash=6967859bff
```

- https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
- https://github.com/kubernetes/dashboard
