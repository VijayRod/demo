```
# k8s.vpa
# vpa mutates the resource request/limit of the pod
```
- https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler

```
# k8s.vpa..aks
# vpas 

rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks --enable-vpa -s $vmsize # -c 2
# az aks update -g $rg -n aks --enable-vpa
# az aks update -g $rg -n aks --disable-vpa
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no; kubectl get po -A; kubectl cluster-info | grep control

# --enable-vpa
az aks show -g $rg -n aks --query workloadAutoScalerProfile
{
  "keda": null,
  "verticalPodAutoscaler": {
    "addonAutoscaling": "Disabled",
    "enabled": true
  }
}

k get po -A --show-labels | grep vpa
kube-system   vpa-admission-controller-6bfcfd948d-tjwwx        1/1     Running   0          3m22s   app=vpa-admission-controller,kubernetes.azure.com/managedby=aks,pod-template-hash=6bfcfd948d
kube-system   vpa-admission-controller-6bfcfd948d-vztw9        1/1     Running   0          3m22s   app=vpa-admission-controller,kubernetes.azure.com/managedby=aks,pod-template-hash=6bfcfd948d
kube-system   vpa-recommender-6cbb69d9b-nkgck                  1/1     Running   0          3m22s   app=vpa-recommender,kubernetes.azure.com/managedby=aks,pod-template-hash=6cbb69d9b
kube-system   vpa-updater-69f7f7bbf5-xt727                     1/1     Running   0          3m22s   app=vpa-updater,kubernetes.azure.com/managedby=aks,pod-template-hash=69f7f7bbf5

k logs -n kube-system -l app=vpa-admission-controller

k logs -n kube-system -l app=vpa-recommender

k logs -n kube-system -l app=vpa-updater

kubectl get customresourcedefinition | grep verticalpodautoscalers
verticalpodautoscalers.autoscaling.k8s.io             2025-08-19T18:18:25Z
```
- https://learn.microsoft.com/en-us/azure/aks/vertical-pod-autoscaler
- https://learn.microsoft.com/en-us/azure/aks/use-vertical-pod-autoscaler
- https://learn.microsoft.com/en-us/azure/aks/use-vertical-pod-autoscaler: The Vertical Pod Autoscaler vpa-recommender deployment analyzes the pods hosting the hamster application to see if the CPU and Memory requirements are appropriate. If adjustments are needed, the vpa-updater relaunches the pods with updated values.
- https://github.com/kubernetes/autoscaler/blob/master/vertical-pod-autoscaler/examples/hamster.yaml: # recommenders field can be unset when using the default recommender.

```
# k8s.vpa.example.hamster-vpa

verticalpodautoscaler.autoscaling.k8s.io/hamster-vpa created
deployment.apps/hamster created

k get po -w

k get vpa
# k get verticalpodautoscalers
NAME          MODE   CPU    MEM    PROVIDED   AGE
hamster-vpa   Auto   587m   50Mi   True       8m24s

k get vpa/hamster-vpa -oyaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  creationTimestamp: "2025-08-19T18:34:16Z"
  generation: 1
  name: hamster-vpa
  namespace: default
  resourceVersion: "9901"
  uid: a198d8fb-159e-4b02-972e-9cedfc3fed99
spec:
  resourcePolicy:
    containerPolicies:
    - containerName: '*'
      controlledResources:
      - cpu
      - memory
      maxAllowed:
        cpu: 1
        memory: 500Mi
      minAllowed:
        cpu: 100m
        memory: 50Mi
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: hamster
  updatePolicy:
    updateMode: Auto
status:
  conditions:
  - lastTransitionTime: "2025-08-19T18:34:31Z"
    status: "True"
    type: RecommendationProvided
  recommendation:
    containerRecommendations:
    - containerName: hamster
      lowerBound:
        cpu: 422m
        memory: 50Mi
      target:
        cpu: 587m
        memory: 50Mi
      uncappedTarget:
        cpu: 587m
        memory: 11500k
      upperBound:
        cpu: "1"
        memory: 500Mi
```
- https://github.com/kubernetes/autoscaler/blob/master/vertical-pod-autoscaler/examples/hamster.yaml

```
# k8s.vpa.example.hamster-vpa.aks
```
- https://learn.microsoft.com/en-us/azure/aks/use-vertical-pod-autoscaler#test-vertical-pod-autoscaler-installation

```
# k8s.vpa.known-issues.mode.Off: vpa is generating recommendations, but it is not updating the resource requests or limits for the pods

# MODE
k get vpa
NAME          MODE   CPU    MEM    PROVIDED   AGE
hamster-vpa   Auto   587m   50Mi   True       8m24s

k get vpa/hamster-vpa -oyaml
spec:
  updatePolicy:
    updateMode: Off
    
# mode.update
k get vpa # hamster-vpa   Auto   587m   50Mi   True       20h
kubectl patch vpa hamster-vpa --type merge -p '{"spec":{"updatePolicy":{"updateMode":"Off"}}}'
k get vpa # hamster-vpa   Off    587m   50Mi   True       20h

```
- https://learn.microsoft.com/en-us/azure/aks/vertical-pod-autoscaler#vpa-object-operation-modes: ** Off: VPA doesn't automatically change the resource requirements of the pods. The recommendations are calculated and can be inspected in the VPA object.
