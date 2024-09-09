```
# kubectl create -f https://k8s.io/examples/application/job/cronjob.yaml
kubectl delete cronjob hello
cat << EOF | kubectl create -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox:1.28
            imagePullPolicy: IfNotPresent
            command:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure
EOF
kubectl get cronjob hello
kubectl get jobs --watch
```

```
# Initial state
NAME    SCHEDULE    SUSPEND   ACTIVE   LAST SCHEDULE   AGE
hello   * * * * *   False     0        <none>          1s

NAME             COMPLETIONS   DURATION   AGE
hello-28266374   0/1                      0s
hello-28266374   0/1           0s         0s
hello-28266374   0/1           7s         7s
hello-28266374   1/1           7s         7s

# State after first run
NAME    SCHEDULE    SUSPEND   ACTIVE   LAST SCHEDULE   AGE
hello   * * * * *   False     0        8s              2m1s

NAME             COMPLETIONS   DURATION   AGE
hello-28266375   0/1                      0s
hello-28266375   0/1           0s         0s
hello-28266375   0/1           4s         4s
hello-28266375   1/1           4s         4s
...

kubectl get po
NAME                   READY   STATUS      RESTARTS   AGE
hello-28266374-5klsw   0/1     Completed   0          2m33s
hello-28266375-hh6jv   0/1     Completed   0          93s
hello-28266376-xnc9z   0/1     Completed   0          33s

kubectl logs hello-28266374-5klsw
Fri Sep 29 20:15:00 UTC 2023
Hello from the Kubernetes cluster
```

- https://kubernetes.io/blog/2021/04/09/kubernetes-release-1.21-cronjob-ga/
- https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/: If the .spec.startingDeadlineSeconds field is set (not null), the CronJob controller measures the time between when a job is expected to be created and now. If the difference is higher than that limit, it will skip this execution.
- https://kubernetes.io/docs/tasks/job/automated-tasks-with-cron-jobs/
- https://kubernetes.io/docs/concepts/workloads/controllers/job/: If you want to run a Job (either a single task, or several in parallel) on a schedule, see CronJob.
