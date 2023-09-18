If the PVC is still attached to the pods, we cannot delete the PV. We need to scale down the StatefulSet replica to 0 and then delete the PVC instead of the PV.

- https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#limitations: Deleting and/or scaling a StatefulSet down will not delete the volumes associated with the StatefulSet
