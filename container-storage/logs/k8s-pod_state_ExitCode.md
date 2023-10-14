```
kubectl describe po
    Last State:     Terminated
      Reason:       ContainerStatusUnknown
      Message:      The container could not be located when the pod was deleted.  The container used to be Running
      Exit Code:    137
      Started:      Mon, 01 Jan 0001 00:00:00 +0000
      Finished:     Mon, 01 Jan 0001 00:00:00 +0000
```

- https://github.com/kubernetes/kubernetes/blob/master/pkg/apis/core/types.go: type ContainerStateTerminated struct {	ExitCode int32
