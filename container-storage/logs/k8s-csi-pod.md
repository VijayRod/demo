## Pod is in a pending state with an error "pod has unbound immediate PersistentVolumeClaims"

```
>       Events:
>          Type     Reason            Age                From               Message
>          ----     ------            ----               ----               -------
>          Warning  FailedScheduling  27s (x2 over 27s)  default-scheduler  error while running >"VolumeBinding" filter plugin for pod "mysql-0": pod has unbound immediate PersistentVolumeClaims
```

- https://stackoverflow.com/questions/60774220/kubernetes-pod-has-unbound-immediate-persistentvolumeclaims: PersistentVolumeClaims will remain unbound indefinitely if a matching PersistentVolume does not exist. The PersistentVolume is matched with accessModes and capacity...
- https://stackoverflow.com/questions/74741993/0-1-nodes-are-available-1-pod-has-unbound-immediate-persistentvolumeclaims: You need to create a PV in order to get a PVC bound...
