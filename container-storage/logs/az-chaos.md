- https://azure.microsoft.com/en-us/products/chaos-studio
- https://learn.microsoft.com/en-us/azure/chaos-studio/chaos-studio-chaos-engineering-overview
- https://chaos-mesh.org/docs/production-installation-using-helm/

```
# chaos
# portal, Chaos Studio, Targets: select a resource to add/enable
# portal, Chaos Studio, Experiments: add an experiment for a required resource(s). Go to the experiment within the created RG and start it.
```

```
# chaos.aks
# Add a target: portal, Chaos Studio, Targets, choose an AKS cluster to add/enable
# Add an experiment: portal, Chaos Studio, Experiments, add an AKS* experiment for the required resource(s)
# Install chaos-mesh on the cluster before starting the experiment: helm install.. --namespace=chaos-testing..
# Start an experiment: portal, go to the experiment within the created RG and start it

helm repo add chaos-mesh https://charts.chaos-mesh.org
helm repo update
kubectl create ns chaos-testing
helm install chaos-mesh chaos-mesh/chaos-mesh --namespace=chaos-testing --set chaosDaemon.runtime=containerd --set chaosDaemon.socketPath=/run/containerd/containerd.sock

kubectl get pods --namespace chaos-testing -l app.kubernetes.io/instance=chaos-mesh
NAME                                        READY   STATUS    RESTARTS   AGE
chaos-controller-manager-5bd7476597-978gm   1/1     Running   0          9s
chaos-controller-manager-5bd7476597-bmshx   1/1     Running   0          9s
chaos-controller-manager-5bd7476597-v9lvh   1/1     Running   0          10s
chaos-daemon-j7xxt                          1/1     Running   0          10s
chaos-daemon-kdzkz                          1/1     Running   0          10s
chaos-dashboard-5966b8f56b-5vx44            1/1     Running   0          10s
chaos-dns-server-558955948b-v5ppl           1/1     Running   0          10s

k api-resources | grep chaos
awschaos                                                chaos-mesh.org/v1alpha1           true         AWSChaos
azurechaos                                              chaos-mesh.org/v1alpha1           true         AzureChaos
blockchaos                                              chaos-mesh.org/v1alpha1           true         BlockChaos
dnschaos                                                chaos-mesh.org/v1alpha1           true         DNSChaos
gcpchaos                                                chaos-mesh.org/v1alpha1           true         GCPChaos
httpchaos                                               chaos-mesh.org/v1alpha1           true         HTTPChaos
iochaos                                                 chaos-mesh.org/v1alpha1           true         IOChaos
jvmchaos                                                chaos-mesh.org/v1alpha1           true         JVMChaos
kernelchaos                                             chaos-mesh.org/v1alpha1           true         KernelChaos
networkchaos                                            chaos-mesh.org/v1alpha1           true         NetworkChaos
physicalmachinechaos                                    chaos-mesh.org/v1alpha1           true         PhysicalMachineChaos
physicalmachines                                        chaos-mesh.org/v1alpha1           true         PhysicalMachine
podchaos                                                chaos-mesh.org/v1alpha1           true         PodChaos
podhttpchaos                                            chaos-mesh.org/v1alpha1           true         PodHttpChaos
podiochaos                                              chaos-mesh.org/v1alpha1           true         PodIOChaos
podnetworkchaos                                         chaos-mesh.org/v1alpha1           true         PodNetworkChaos
remoteclusters                                          chaos-mesh.org/v1alpha1           false        RemoteCluster
schedules                                               chaos-mesh.org/v1alpha1           true         Schedule
statuschecks                                            chaos-mesh.org/v1alpha1           true         StatusCheck
stresschaos                                             chaos-mesh.org/v1alpha1           true         StressChaos
timechaos                                               chaos-mesh.org/v1alpha1           true         TimeChaos
workflownodes                       wfn                 chaos-mesh.org/v1alpha1           true         WorkflowNode
workflows                           wf                  chaos-mesh.org/v1alpha1           true         Workflow

k get podchaos -A
```
- https://learn.microsoft.com/en-us/azure/chaos-studio/experiment-examples?tabs=azure-CLI
- https://learn.microsoft.com/en-us/azure/chaos-studio/chaos-studio-tutorial-aks-cli#set-up-chaos-mesh-on-your-aks-cluster



```
# chaos.aks.helm

helm install chaos-mesh chaos-mesh/chaos-mesh -n=chaos-mesh --set chaosDaemon.runtime=containerd --set chaosDaemon.socketPath=/run/containerd/containerd.sock --version 2.7.2

kubectl get pods --namespace chaos-mesh -l app.kubernetes.io/instance=chaos-mesh
NAME                                        READY   STATUS    RESTARTS   AGE
chaos-controller-manager-66bbd964b7-mpz9k   1/1     Running   0          43s
chaos-controller-manager-66bbd964b7-qf42w   1/1     Running   0          43s
chaos-controller-manager-66bbd964b7-vq72f   1/1     Running   0          43s
chaos-daemon-schxk                          1/1     Running   0          43s
chaos-daemon-w75md                          1/1     Running   0          43s
chaos-dashboard-5966b8f56b-ck9q9            1/1     Running   0          43s
chaos-dns-server-558955948b-r9wb8           1/1     Running   0          43s 

helm uninstall chaos-mesh -n chaos-mesh
```

- https://chaos-mesh.org/docs/production-installation-using-helm/
- https://chaos-mesh.org/docs/simulate-pod-chaos-on-kubernetes/

```
# chaos.aks.helm.experiment

cat << EOF | kubectl create -f -
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  name: pod-failure-example
  namespace: chaos-mesh
spec:
  action: pod-failure
  mode: one
  duration: '30s'
EOF

```
- https://chaos-mesh.org/docs/simulate-pod-chaos-on-kubernetes/
