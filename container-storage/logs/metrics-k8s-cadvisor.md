- https://github.com/Azure/AKS/issues/3715#issuecomment-1610339833
- https://github.com/google/cadvisor
- https://github.com/google/cadvisor/blob/master/docs/storage/README.md
- https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-usage-monitoring/: container runtime does not publish usage statistics, then the kubelet can look up those statistics directly (using code from cAdvisor)
- https://kubernetes.io/docs/concepts/cluster-administration/system-metrics/: kubelet also exposes metrics in /metrics/cadvisor (endpoint)
