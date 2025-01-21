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
- https://cloud.google.com/kubernetes-engine/docs/troubleshooting#check_exit_code_of_the_crashed_container
- https://docs.docker.com/engine/reference/run/#exit-status
- https://github.com/kodekloudhub/throw-dice/blob/master/throw-dice.sh
- https://github.com/kubernetes/kubernetes/issues/82519: The Exit Code is obtained from docker's ExitCode. Normally it will be the exit status of the process
- https://komodor.com/learn/exit-codes-in-containers-and-kubernetes-the-complete-guide/: SIGKILL, SIGSEGV, SIGTERM
  - https://komodor.com/learn/what-is-sigkill-signal-9-fast-termination-of-linux-containers/
  - https://komodor.com/learn/sigsegv-segmentation-faults-signal-11-exit-code-139/
  - https://komodor.com/learn/sigterm-signal-15-exit-code-143-linux-graceful-termination/
  - kill -l // 9) SIGKILL, 11) SIGSEGV, 15) SIGTERM // kill -n 9 <pid>
- https://kubernetes.io/docs/tasks/debug/debug-application/determine-reason-pod-failure/
- https://stackoverflow.com/questions/31297616/what-is-the-authoritative-list-of-docker-run-exit-codes
- https://tldp.org/LDP/abs/html/exitcodes.html: Exit Codes With Special Meanings
- https://www.datree.io/resources/kubernetes-error-codes-crashloopbackoff: An exit code ranging from 1 to 128 would show an exit stemming from internal (app) signals.
- https://www.man7.org/linux/man-pages/man7/signal.7.html: Signal numbering for standard signals
- https://www.tencentcloud.com/document/product/457/35758: value of the exit code is the value of the interrupt signal plus 128
