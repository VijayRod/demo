<img src="https://learn.microsoft.com/en-us/azure/media/index/kubernetes-services.svg" width="100"/>

## Table of Contents

- create
- gpu driver install
- gpu metrics
- gpu workload
- More

## create

Here are the commands I used to create a GPU-enabled AKS cluster:

```
az aks create -g $g -n aksgpu -s $vmsize -l eastus --enable-azure-monitor-metrics
az aks nodepool add -g $rg --cluster-name aksgpu -n gpunp --node-count 1 --node-vm-size Standard_NC6s_v3 # --enable-cluster-autoscaler --min-count 1 --max-count 3
az aks get-credentials -g $rg -n aksgpu --overwrite-existing
kubectl get no

kubectl describe no aks-gpunp-13389075-vmss000000
Name:               aks-gpunp-13389075-vmss000000
Roles:              agent
Labels:             accelerator=nvidia
                    kubernetes.azure.com/accelerator=nvidia
Capacity:
  nvidia.com/gpu:     1
```
  
## gpu driver install

Here are the steps to install the GPU driver on the cluster:

```
# manual install of GPU driver (default yaml does not have a GPU node selector)
https://learn.microsoft.com/en-us/azure/aks/gpu-cluster#manually-install-the-nvidia-device-plugin
https://github.com/NVIDIA/k8s-device-plugin/blob/main/nvidia-device-plugin.yml
kubectl create namespace gpu-resources
cat << EOF | kubectl create -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nvidia-device-plugin-daemonset
  namespace: gpu-resources
spec:
  selector:
    matchLabels:
      name: nvidia-device-plugin-ds
  updateStrategy:
    type: RollingUpdate
  template:
    metadata:
      # Mark this pod as a critical add-on; when enabled, the critical add-on scheduler
      # reserves resources for critical add-on pods so that they can be rescheduled after
      # a failure.  This annotation works in tandem with the toleration below.
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ""
      labels:
        name: nvidia-device-plugin-ds
    spec:
      tolerations:
      # Allow this pod to be rescheduled while the node is in "critical add-ons only" mode.
      # This, along with the annotation above marks this pod as a critical add-on.
      - key: CriticalAddonsOnly
        operator: Exists
      - key: nvidia.com/gpu
        operator: Exists
        effect: NoSchedule
      - key: "sku"
        operator: "Equal"
        value: "gpu"
        effect: "NoSchedule"
      containers:
      - image: mcr.microsoft.com/oss/nvidia/k8s-device-plugin:v0.14.1
        name: nvidia-device-plugin-ctr
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop: ["ALL"]
        volumeMounts:
          - name: device-plugin
            mountPath: /var/lib/kubelet/device-plugins
      volumes:
        - name: device-plugin
          hostPath:
            path: /var/lib/kubelet/device-plugins
EOF
kubectl get all -n gpu-resources -owide
# kubectl delete ds nvidia-device-plugin-daemonset -n gpu-resources

kubectl logs -n gpu-resources -l name=nvidia-device-plugin-ds
kubectl logs -n gpu-resources nvidia-device-plugin-daemonset-9dvn4
```

## gpu metrics

To see the GPU info, go to the Azure Portal, pick a cluster, then click on Monitoring and Workbooks. Then say the Node GPU workbook.

## gpu workload

Here's the code you need to create and run a job that uses a TensorFlow image.

```
https://learn.microsoft.com/en-us/azure/aks/gpu-cluster#run-a-gpu-enabled-workload
cat << EOF | kubectl create -f -
apiVersion: batch/v1
kind: Job
metadata:
  labels:
    app: samples-tf-mnist-demo
  name: samples-tf-mnist-demo
spec:
  template:
    metadata:
      labels:
        app: samples-tf-mnist-demo
    spec:
      containers:
      - name: samples-tf-mnist-demo
        image: mcr.microsoft.com/azuredocs/samples-tf-mnist-demo:gpu
        args: ["--max_steps", "500"]
        imagePullPolicy: IfNotPresent
        resources:
          limits:
           nvidia.com/gpu: 1
      restartPolicy: OnFailure
      tolerations:
      - key: "sku"
        operator: "Equal"
        value: "gpu"
        effect: "NoSchedule"
EOF
kubectl get jobs samples-tf-mnist-demo --watch
kubectl get pods --selector app=samples-tf-mnist-demo
kubectl logs samples-tf-mnist-demo-smnr6
```

## cluster-autoscaler

Here's the link to the code for nodes with unready GPU:

- https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/processors/customresources/gpu_processor.go: nodesWithUnreadyGpu
- https://github.com/kubernetes/autoscaler/blob/7e95c7e63a5f0773e51bc484b1f7dbe802fe668a/cluster-autoscaler/core/static_autoscaler.go#L970: Handle GPU case - allocatable GPU may be equal to 0 up to 15 minutes after
