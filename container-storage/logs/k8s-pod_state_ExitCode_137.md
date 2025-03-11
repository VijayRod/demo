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
- https://stackoverflow.com/questions/59729917/kubernetes-pods-terminated-exit-code-137: Exit Code 137 does not necessarily mean OOMKilled. It indicates failure as container received SIGKILL (some interrupt or ‘oom-killer’ [OUT-OF-MEMORY]). If pod got OOMKilled, you will see below line when you describe the pod
      State:        Terminated
      Reason:       OOMKilled
- 137 mean that k8s kill container for some reason (may be it didn't pass liveness probe). Cod 137 is 128 + 9(SIGKILL) process was killed by external signal
