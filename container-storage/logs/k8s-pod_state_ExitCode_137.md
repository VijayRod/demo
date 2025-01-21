```
kubectl describe po
    Last State:     Terminated
      Reason:       ContainerStatusUnknown
      Message:      The container could not be located when the pod was deleted.  The container used to be Running
      Exit Code:    137
      Started:      Mon, 01 Jan 0001 00:00:00 +0000
      Finished:     Mon, 01 Jan 0001 00:00:00 +0000
```

- https://komodor.com/learn/how-to-fix-oomkilled-exit-code-137/
- https://komodor.com/learn/exit-codes-in-containers-and-kubernetes-the-complete-guide/: Exit Code 137	Immediate termination (SIGKILL)	Container was immediately terminated by the operating system via SIGKILL signal
