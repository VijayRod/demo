# servicemesh-istio
This is my personal page dedicated to troubleshooting and debugging AKS with the Istio-based service mesh, and any opinions expressed here are my own. The commonly used tools for this project are [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli), kubectl, [istioctl](https://istio.io/latest/docs/setup/getting-started/#download), and optionally [jq](https://stedolan.github.io/jq/download/), or you can use the Bash environment in [Azure Cloud Shell](https://learn.microsoft.com/en-us/azure/cloud-shell/quickstart?tabs=azurecli). For a quick start guide, refer [this](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-cli).

## Section 1: Know more and know limitations

For more info, refer [this](https://techcommunity.microsoft.com/t5/apps-on-azure-blog/istio-based-service-mesh-add-on-for-azure-kubernetes-service/ba-p/3800229). [This](https://learn.microsoft.com/en-us/azure/aks/istio-about) includes limitations too. [Roadmap is here](https://aka.ms/asm-roadmap).

### Section 1a: Enable or disable the Istio add-on

1. To enable the Istio add-on for new or existing clusters, refer [this](https://learn.microsoft.com/en-us/azure/aks/istio-deploy-addon). 

   1a. Sidecar injection must be enabled to use Istio's features. Also, the Istio ingress gateway must be enabled, with its Gateway and VirtualService resources, to manage inbound or outbound traffic for the mesh.

2. To disable the Istio add-on, refer [this](https://learn.microsoft.com/en-us/azure/aks/istio-deploy-addon#delete-resources).

### Section 1b: Enable external or internal Istio ingress gateway

1. To enable or delete, refer [this](https://learn.microsoft.com/en-us/azure/aks/istio-deploy-ingress). The Istio gateway associates the `kubernetes` or `kubernetes-internal` load balancers (in the node resource group) to manage inbound or outbound traffic for the mesh, letting you specify which traffic you want to enter or leave the mesh.

   1a. Applications aren't accessible from outside the cluster by default after enabling the ingress gateway, ensure you map the deployment's ingress to the Istio ingress gateway using the `Gateway` and `VirtualService` resources mentioned in the same link.

2. For the `EXTERNAL-IP`, run the below for the respective gateway:

```
kubectl get svc aks-istio-ingressgateway-external -n aks-istio-ingress # external ingress gateway.
kubectl get svc aks-istio-ingressgateway-internal -n aks-istio-ingress # internal ingress gateway.
```

## Section 2: Know the version of the enabled add-on

1. To know the version of Istio enabled on AKS, run `kubectl get pods -n aks-istio-system`. 

   1a. A pod name `istiod-asm-1-17-67f9f55ccb-4lxhk` in its output indicates version 1-17 i.e. 1.17. 

   1b. The version is required for configuration of the sidecar injection.

## Section 3: Debug

### Section 3a: Debug - Errors with the `az aks` or `az aks mesh` commands

1. For unexpected errors with the `az aks` or `az aks mesh` commands, ensure these are updated to the latest version with [`az upgrade`](https://learn.microsoft.com/en-us/cli/azure/update-azure-cli) and `az extension update --name aks-preview`. 

   1a. Then re-run the `az aks` or `az aks mesh` command with `--debug`. 

   1b. For example, to capture logs to a file, run `az aks mesh enable -g myResourceGroupName -n myClusterName --debug 2> debug_output.log`.

### Section 3b: Debug - Verify the control plane is healthy

1. To verify the cluster is "Running", run `az aks show -g secureshack2 -n myClusterName --query 'powerState.code'`.

2. To verify the cluster is in a "Succeeded" state, run `az aks show -g myResourceGroupName -n myClusterName --query 'provisioningState'`. 

   2a. If it's not in the "Succeeded" state, view the [activity log](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/activity-log?tabs=powershell) for the cluster resource group in the Azure portal to review failed operations for the error.
   
   2b. Or run `az aks update -g myResourceGroupName -n myClusterName` to reconcile the cluster to its goal state.

3. To ensure that the service mesh "mode" is set to "Istio", run `az aks show -g myResourceGroupName -n myClusterName --query 'serviceMeshProfile'`. The output should include it:

   ```
   {
     "istio": {
       "components": {
         "ingressGateways": null
       }
     },
     "mode": "Istio"
   }
   ```
   
4. To verify if the Istio control plane pods (istiod) have a "Running" status, run `kubectl get pods -n aks-istio-system`. Make sure to obtain access credentials for the cluster with `az aks get-credentials -g myResourceGroupName -n myClusterName`. The output should include the name of the pod(s) and their status, for example:

```
NAME                               READY   STATUS    RESTARTS   AGE
istiod-asm-1-17-67f9f55ccb-4lxhk   1/1     Running   0          50s
```

### Section 3c: Debug sidecar injection of the add-on

1. To enable sidecar injection, refer to this guide. This installs a sidecar to <ins>new</ins> pods, but not the existing ones, which enables the use of Istio's features in the new pods.

2. To verify the injection of the sidecar, create a new pod in the labeled namespace and confirm that it includes an istio-proxy container. For example:

```
kubectl run hello --image=gcr.io/google-samples/hello-app:1.0
kubectl get pod # Ensure the "hello" pod is in Running state with two containers.
kubectl describe pod hello | grep "Started container istio-proxy"
# kubectl delete po hello # cleanup.
```

3. To obtain a list of such annotated namespaces, run `kubectl get namespaces --show-labels | grep istio.io/rev=asm` or run `kubectl get namespace -l istio.io/rev=asm-1-17` if you prefer.

4. If Istio's features are no longer required for a namespace, for example, the "default" namespace, run `kubectl label namespace default istio.io/rev-` to remove the sidecar injection.

Note: Please make sure to replace "myClusterName" and "myResourceGroupName" with the actual names of your cluster and resource group respectively, in all the commands.

### Section 3d: Debug with `istioctl`

1. To verify that `istioctl` can connect to the cluster, run the command `istioctl x precheck`. A successful run should display the following message: 

   ```
   No issues found when checking the cluster. Istio is safe to install or upgrade!
   ```

   1a. If the command returns an error like the one below, ensure that `kubectl` works from the same console by running `kubectl get namespace`. You may need to obtain access credentials for the cluster using the command `az aks get-credentials -g myResourceGroupName -n myClusterName`.
   
   ```
   Error: unable to retrieve Pods: the server has asked for the client to provide credentials (get pods)
   ```

   1b. For any other error, re-run the command with `--vklog=9` for higher log level verbosity. 
   
   1c. To save the output to a file, add `> istioctl_logs.txt`.
   
2. To retrieve the proxy sync status for all Envoys in a mesh, run the command `istioctl proxy-status -i aks-istio-system`. This will return one row for each pod that has the proxy.

   ```
   NAME               CLUSTER        CDS        LDS        EDS        RDS        ECDS         ISTIOD                               VERSION
   hello.default      Kubernetes     SYNCED     SYNCED     SYNCED     SYNCED     NOT SENT     istiod-asm-1-17-67f9f55ccb-j85bk     1.17.1-distroless
   nginx.default      Kubernetes     SYNCED     SYNCED     SYNCED     SYNCED     NOT SENT     istiod-asm-1-17-67f9f55ccb-j85bk     1.17.1-distroless
   ```

   2a. If an envoy/pod is missing from the above list, it means that it is not currently connected to an Istio Pilot instance and thus will not receive any configuration. Additionally, if it is marked as "STALE", it likely means there are networking issues or the Istio Pilot needs to be scaled.
   
   2b. "SYNCED" and "NOT SENT" are usually seen in the output. "STALE" indicates a networking issue between Envoy and Istiod.
   
   2c. Refer to the advanced user note [below](#section-4-for-advanced-users) for further information about the output if required.

### Section 3e: Debug - Unexpected pod issues

1. To get the Istiod pod logs, run the command `kubectl logs -l app=istiod -n aks-istio-system`. 

   1a. To see the recent logs, add `--since=2m` or `--since=1h`. 
 
   1b. To save the output to a file, add `> istiod_logs.txt`.

2. To get the logs for a pod in `CrashLoopBackOff`, find the failing container with the command `kubectl describe pod -n namespace_name crashing_pod_name`. 

   2a. Then, capture the logs with the command `kubectl logs -n namespace_name crashing_pod_name -c failing_container_name --previous`. 
  
   2b. You can also view the [live logs](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-livedata-overview) with Container Insights or view historical logs in the [`ContainerLog`](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-log-query) table in [Log Analytics](https://learn.microsoft.com/en-us/azure/aks/monitor-aks).

3. View known issues [here](https://github.com/Azure/AKS/issues?q=is%3Aissue+is%3Aopen+istio) or (here)[https://github.com/Azure/AKS/releases].

### Section 3f: Debug - Metrics Issues

1. Enable [Managed Prometheus](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/prometheus-metrics-enable?tabs=azure-portal) and view metrics in the `InsightsMetrics` table.

2. Use [Azure Managed Grafana](https://learn.microsoft.com/en-Us/azure/azure-monitor/essentials/prometheus-metrics-overview#grafana-integration) to visualize metrics.

### Section 3g: Debug - Connectivity issues between pods

1. To confirm connectivity between pods in annotated namespace(s), create new pods/deployments and use `curl` to access them. Run the following commands:

   ```
   kubectl run hello --image=gcr.io/google-samples/hello-app:1.0
   kubectl run nginx --image=nginx
   kubectl get po -owide # Ensure both pods are Running. Note the IP of the "hello" pod.
   kubectl exec -it nginx -- curl 10.244.2.14:8080 # Replace the IP of the "hello" pod. Ensure you use port 8080 since this is used by the hello app.
   # kubectl delete po hello nginx # cleanup.
   ```

   1a. If an incorrect port is used, a delayed connect error will occur, such as the following:

   ```
   kubectl exec -it nginx -- curl 10.244.2.14:90 # Incorrect port.
   upstream connect error or disconnect/reset before headers. reset reason: connection failure, transport failure reason: delayed connect error: 111
   ```
   
   1b. If there are other connection errors, check access logs by running for the source and destination pods:

   ```
   kubectl logs hello -c istio-proxy
   ```
   
2. If connection errors occur for all pods in the namespace, temporarily disable sidecar injection for the namespace by running `kubectl label namespace default istio.io/rev-`. 

   2a. Then <ins>recreate</ins> the pods, so they do not have the sidecar, and retest connectivity between the pods to ensure it works fine without the sidecar.
   
3. To review network policies in the cluster, run `kubectl get networkpolicy -A`.
   
4. To capture simultaneous TCP dumps on source and destination nodes during the reproduction of the issue, use the steps mentioned [here](https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/capture-tcp-dump-linux-node-aks). Note the names, namespaces, and IPs of the source and destination pods with `kubectl get pod -A -owide`, and the names and IPs of the source and destination nodes with `kubectl get no -owide`.
   
### Section 3h: Debug - Connectivity issues through the Istio ingress gateway

1. Ensure the ingress gateway resource is created with the appropriate `Gateway` and `VirtualService` resources as shown [here]().

## Section 4: For Advanced Users

1. The istio-proxy container is the Envoy sidecar injected by Istio.
   
   1a. The sidecar containers are injected using a mutating admission webhook seen with `kubectl get mutatingwebhookconfigurations | grep istio-sidecar-injector`.
   
   1b. Use `istioctl proxy-status -i aks-istio-system` to retrieve the proxy sync status for all Envoys in a mesh. Each row in the output denotes an Envoy proxy in each pod in the cluster.
   
       1bi. CDS, LDS, EDS, RDS, and ECDS are Envoy (the proxy underpinning Istio) services mentioned [here](https://github.com/istio/istio/issues/34139#issuecomment-1064377239) and [here](https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/operations/dynamic_configuration).
       
       1bii. SYNCED and NOT SENT statuses are usually seen, STALE usually indicates a networking issue between Envoy and Istiod as indicated [here](https://istio.io/latest/docs/ops/diagnostic-tools/proxy-cmd/).
       
       1biii. The Istio service mesh architecture includes the proxy underpinning Istio, as shown [here](https://istio.io/latest/docs/ops/deployment/architecture/).

2. The Istio custom resources installed by the add-on can be seen with `kubectl get crd -A | grep "istio.io"`.

3. To view the ready status displayed in Envoy's access logs for a pod "hello", run `kubectl logs hello -c istio-proxy | grep "Envoy proxy is ready"`.

4. You can find a sample application that is ideal for testing Istio's features on GitHub [here](https://github.com/istio/istio/tree/main/samples/bookinfo).
