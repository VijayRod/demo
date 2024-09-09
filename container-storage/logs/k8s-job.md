```
kubectl create job busybox --image=busybox -- echo “Hello, Kubernetes”
sleep 5
kubectl get job,po
kubectl describe job,po


NAME                COMPLETIONS   DURATION   AGE
job.batch/busybox   1/1           5s         6s
NAME                READY   STATUS      RESTARTS   AGE
pod/busybox-rm4wk   0/1     Completed   0          6s

# job
Name:             busybox
Namespace:        default
Selector:         batch.kubernetes.io/controller-uid=3482b286-0337-462f-aedf-b76012cbe248
Labels:           batch.kubernetes.io/controller-uid=3482b286-0337-462f-aedf-b76012cbe248
                  batch.kubernetes.io/job-name=busybox
                  controller-uid=3482b286-0337-462f-aedf-b76012cbe248
                  job-name=busybox
Annotations:      <none>
Parallelism:      1
Completions:      1
Completion Mode:  NonIndexed
Start Time:       Mon, 09 Sep 2024 18:42:24 +0000
Completed At:     Mon, 09 Sep 2024 18:42:29 +0000
Duration:         5s
Pods Statuses:    0 Active (0 Ready) / 1 Succeeded / 0 Failed
Pod Template:
  Labels:  batch.kubernetes.io/controller-uid=3482b286-0337-462f-aedf-b76012cbe248
           batch.kubernetes.io/job-name=busybox
           controller-uid=3482b286-0337-462f-aedf-b76012cbe248
           job-name=busybox
  Containers:
   busybox:
    Image:      busybox
    Port:       <none>
    Host Port:  <none>
    Command:
      echo
      “Hello,
      Kubernetes”
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age   From            Message
  ----    ------            ----  ----            -------
  Normal  SuccessfulCreate  7s    job-controller  Created pod: busybox-rm4wk
  Normal  Completed         2s    job-controller  Job completed

# pod - job
Name:             busybox-rm4wk
Namespace:        default
Labels:           batch.kubernetes.io/controller-uid=3482b286-0337-462f-aedf-b76012cbe248
                  batch.kubernetes.io/job-name=busybox
                  controller-uid=3482b286-0337-462f-aedf-b76012cbe248
                  job-name=busybox
Controlled By:  Job/busybox

# pod - Containers
Name:             busybox-rm4wk
Namespace:        default
Containers:
  busybox:
    Container ID:  containerd://a09e93147a20589e066ef7a1e315ff719ad33977b8a4d1d902928d0cd21e40c5
    Image:         busybox
    Image ID:      docker.io/library/busybox@sha256:34b191d63fbc93e25e275bfccf1b5365664e5ac28f06d974e8d50090fbb49f41
    Port:          <none>
    Host Port:     <none>
    Command:
      echo
      “Hello,
      Kubernetes”
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Mon, 09 Sep 2024 18:42:26 +0000
      Finished:     Mon, 09 Sep 2024 18:42:26 +0000
    Ready:          False
```

- https://kubernetes.io/docs/concepts/workloads/controllers/job/: If you want to run a Job (either a single task, or several in parallel) on a schedule, see CronJob.

```
#job-termination-and-cleanup
kubectl delete job busybox
kubectl get po # No resources found in default namespace.
```

- https://kubernetes.io/docs/concepts/workloads/controllers/job/#job-termination-and-cleanup

```
```
- https://kubernetes.io/docs/concepts/architecture/controller/: Job controller
