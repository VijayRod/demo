```
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
# kubectl delete -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml # uninstall
```

```
kubectl get all -n gatekeeper-system
NAME                                                 READY   STATUS    RESTARTS      AGE
pod/gatekeeper-audit-664bb8d7bf-sjl4n                1/1     Running   1 (10s ago)   15s
pod/gatekeeper-controller-manager-5587dcf8f4-cvt95   1/1     Running   0             15s
pod/gatekeeper-controller-manager-5587dcf8f4-j6ldh   1/1     Running   0             15s
pod/gatekeeper-controller-manager-5587dcf8f4-t5rpg   1/1     Running   0             15s
NAME                                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/gatekeeper-webhook-service   ClusterIP   10.0.58.233   <none>        443/TCP   16s
NAME                                            READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/gatekeeper-audit                1/1     1            1           17s
deployment.apps/gatekeeper-controller-manager   3/3     3            3           16s
NAME                                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/gatekeeper-audit-664bb8d7bf                1         1         1       17s
replicaset.apps/gatekeeper-controller-manager-5587dcf8f4   3         3         3       16s

kubectl get constrainttemplates -A
No resources found

kubectl get constraints
error: the server doesn't have a resource type "constraints"

kubectl get crd | grep gatek
assign.mutations.gatekeeper.sh                       2023-10-03T20:29:11Z
assignimage.mutations.gatekeeper.sh                  2023-10-03T20:29:11Z
assignmetadata.mutations.gatekeeper.sh               2023-10-03T20:29:12Z
configs.config.gatekeeper.sh                         2023-10-03T20:29:12Z
constraintpodstatuses.status.gatekeeper.sh           2023-10-03T20:29:12Z
constrainttemplatepodstatuses.status.gatekeeper.sh   2023-10-03T20:29:12Z
constrainttemplates.templates.gatekeeper.sh          2023-10-03T20:29:12Z
expansiontemplate.expansion.gatekeeper.sh            2023-10-03T20:29:12Z
expansiontemplatepodstatuses.status.gatekeeper.sh    2023-10-03T20:29:12Z
modifyset.mutations.gatekeeper.sh                    2023-10-03T20:29:13Z
mutatorpodstatuses.status.gatekeeper.sh              2023-10-03T20:29:13Z
providers.externaldata.gatekeeper.sh                 2023-10-03T20:29:13Z
```

- https://open-policy-agent.github.io/gatekeeper/website/docs/install
- https://open-policy-agent.github.io/gatekeeper/website/docs/debug
- https://learn.microsoft.com/en-us/azure/architecture/aws-professional/eks-to-aks/governance#gatekeeper
