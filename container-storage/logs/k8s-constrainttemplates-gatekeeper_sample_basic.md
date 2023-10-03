```
cd /tmp
git clone https://github.com/open-policy-agent/gatekeeper.git
cd /tmp/gatekeeper/demo/basic
./demo.sh # Pressing the Enter key at each prompt
```

```
# Terminal 2

kubectl get constrainttemplates
NAME                AGE
k8srequiredlabels   88s

kubectl get -n gatekeeper-system constrainttemplatepodstatuses.status.gatekeeper.sh
NAME                                                                   AGE
gatekeeper--audit--664bb8d7bf--sjl4n-k8srequiredlabels                 4m18s
gatekeeper--controller--manager--5587dcf8f4--cvt95-k8srequiredlabels   4m18s
gatekeeper--controller--manager--5587dcf8f4--j6ldh-k8srequiredlabels   4m18s
gatekeeper--controller--manager--5587dcf8f4--t5rpg-k8srequiredlabels   4m18s

kubectl get po -n gatekeeper-system
NAME                                             READY   STATUS    RESTARTS      AGE
gatekeeper-audit-664bb8d7bf-sjl4n                1/1     Running   1 (25m ago)   25m
gatekeeper-controller-manager-5587dcf8f4-cvt95   1/1     Running   0             25m
gatekeeper-controller-manager-5587dcf8f4-j6ldh   1/1     Running   0             25m
gatekeeper-controller-manager-5587dcf8f4-t5rpg   1/1     Running   0             25m
```

- https://open-policy-agent.github.io/gatekeeper/website/docs/examples
- https://github.com/open-policy-agent/gatekeeper/tree/master/demo/basic
