```
# kubectl create deploy nginx --image=nginx
deployment.apps/nginx created

# kubectl set resources deploy/nginx -c=nginx --limits=cpu=200m,memory=512Mi
deployment.apps/nginx resource requirements updated
```

```
# kubectl set resources po/nginx -c=nginx --limits=cpu=200m,memory=512Mi
error: failed to patch resources update to pod template Pod "nginx" is invalid: spec: Forbidden: pod updates may not change fields other than `spec.containers[*].image`, `spec.initContainers[*].image`, `spec.activeDeadlineSeconds`, `spec.tolerations` (only additions to existing tolerations) or `spec.terminationGracePeriodSeconds` (allow it to be set to 1 if it was previously negative)
```

- https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
