```
kubectl delete namespace namespace_to_delete –force ## TBD does not work with finalizers
kubectl patch ns namespace_to_delete -p '{"metadata":{"finalizers":null}}'
```

- https://kubernetes.io/docs/concepts/overview/working-with-objects/finalizers/

```
Root Cause Analysis (RCA):

If a Pod is stuck in the Terminating state, it means that a deletion request has been issued, but the control plane is unable to delete the Pod object. This typically happens if the Pod has a finalizer, and there is an admission webhook installed in the cluster that prevents the control plane from removing the finalizer.

Finalizers prevent objects from being deleted from the API until they are themselves removed. Once the controller completes the cleanup and accounting for the deleted object, it removes the finalizer, allowing the control plane to delete the object from the API.

In this scenario, the controller first sends a PATCH request to remove the job-tracking finalizer from the Pod. However, the webhook intercepts the request and modifies fields, leading to a validation failure because an immutable property in the Pod spec was changed. As a result, the request becomes invalid, and the finalizer cannot be removed.

Therefore, the Pods remain stuck in the Terminating state.
```

```
Action:

To unblock the termination of the affected Pods, the finalizer needs to be removed from the Pod spec. Follow these steps:

Disable the webhook that is causing invalid mutations on the Pod(s).

Patch the Pod(s) to remove the finalizer using the following command:
kubectl patch pod <pod-name> -p '{"metadata":{"finalizers":null}}'

If the webhook is provided by a third-party, ensure you are using the latest version and report the issue to the corresponding provider.

If you are the author of the webhook:
For a mutating webhook, ensure it does not modify immutable fields during UPDATE operations.
For a validating webhook, ensure that your validation policies only apply to new changes.

There may be more Pods in the Terminating state than those listed above. To view all Pods stuck in the Terminating state, run the following command:
kubectl get pods --all-namespaces | grep Terminating
```

```
kubectl get po -oyaml
apiVersion: v1
items:
- apiVersion: v1
  kind: Pod
  metadata:
    finalizers:
    - batch.kubernetes.io/job-tracking
    generateName: hibernate-pause-11111111-
    name: hibernate-pause-11111111-abcde
    namespace: ns12345
    ownerReferences:
    - apiVersion: batch/v1
      blockOwnerDeletion: true
      controller: true
      kind: Job
      name: hibernate-pause-11111111

kubectl describe mutatingwebhookconfiguration
Name:         gatekeeper-mutating-webhook-configuration
Namespace:    
Kind:         MutatingWebhookConfiguration
Webhooks:
  Rules:
    API Groups:
      *
    API Versions:
      *
    Operations:
      CREATE
      UPDATE
```

- https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/#my-pod-stays-terminating: This typically happens if the Pod has a finalizer and there is an admission webhook installed in the cluster that prevents the control plane from removing the finalizer. To identify this scenario, check if your cluster has any ValidatingWebhookConfiguration or MutatingWebhookConfiguration that target UPDATE operations for pods resources.
- https://kubernetes.io/docs/concepts/workloads/controllers/job/#job-tracking-with-finalizers
