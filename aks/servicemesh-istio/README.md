# servicemesh-istio
This is my personal page dedicated to troubleshooting and debugging AKS with the Istio-based service mesh, and any opinions expressed here are my own. The commonly used tools for this project are [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli), kubectl, [istioctl](https://istio.io/latest/docs/setup/getting-started/#download), and optionally [jq](https://stedolan.github.io/jq/download/), or you can use the Bash environment in [Azure Cloud Shell](https://learn.microsoft.com/en-us/azure/cloud-shell/quickstart?tabs=azurecli). For a quick start guide, refer [this](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-cli).

## Section 1: Know more and know limitations

For more info, refer [this](https://docs.microsoft.com/en-us/azure/aks/servicemesh-istio-about). This includes limitations too. [Roadmap is here](https://docs.microsoft.com/en-us/azure/aks/servicemesh-istio-roadmap).

### Section 1a: Enable or disable the Istio add-on

1. To enable the Istio add-on for new or existing clusters, refer [this](https://docs.microsoft.com/en-us/azure/aks/servicemesh-istio-install). Sidecar injection must be enabled to use Istio's features. Also, the Istio ingress gateway must be enabled, with its Gateway and VirtualService resources, to manage inbound or outbound traffic for the mesh.
2. To disable the Istio add-on, refer [this](https://docs.microsoft.com/en-us/azure/aks/servicemesh-istio-uninstall).

### Section 1b: Enable external or internal Istio ingress gateway

1. To enable or delete, refer [this](https://docs.microsoft.com/en-us/azure/aks/servicemesh-istio-ingress). Gateway associates the Kubernetes or Kubernetes-internal load balancers (in the node resource group) to manage inbound or outbound traffic for the mesh, letting you specify which traffic you want to enter or leave the mesh.
   - Applications aren't accessible from outside the cluster by default after enabling the ingress gateway, ensure you map the deployment's ingress to the Istio ingress gateway using the Gateway and VirtualService resources mentioned in the same link.
2. For the `EXTERNAL-IP`, run the below for the respective gateway:

```
kubectl get svc aks-istio-ingressgateway-external -n aks-istio-ingress # external ingress gateway.
kubectl get svc aks-istio-ingressgateway-internal -n aks-istio-ingress # internal ingress gateway.
```

## Section 2: Know the version of the enabled add-on

To know the version of Istio enabled on AKS, run `kubectl get pods -n aks-istio-system`. A pod name `istiod-asm-1-17-67f9f55ccb-4lxhk` in its output indicates version 1-17 i.e. 1.17. The version is required for configuration of the sidecar injection.

## Section 3: Debug

### Section 3a: Debug - Errors with the `az aks` or `az aks mesh` commands

For unexpected errors with the `az aks` or `az aks mesh` commands, ensure these are updated to the latest version with `az upgrade` and `az extension update --name aks-preview`. Then re-run the `az aks` or `az aks mesh` command with `--debug`. For example, to capture logs to a file, run `az aks mesh enable -g myResourceGroupName -n myClusterName --debug 2> debug_output.log`.

### Section 3b: Debug - Verify the control plane is healthy

1. To verify the cluster is "Running", run `az aks show -g secureshack2 -n myClusterName --query 'powerState.code'`.

2. To verify the cluster is in a "Succeeded" state, run `az aks show -g myResourceGroupName -n myClusterName --query 'provisioningState'`. 

   If it's not in the "Succeeded" state, view the activity log for the cluster resource group in the Azure portal to review failed operations for the error. Otherwise, run `az aks update -g myResourceGroupName -n myClusterName` to reconcile the cluster to its goal state.

3. To ensure that the service mesh mode is set to Istio, run `az aks show -g myResourceGroupName -n myClusterName --query 'serviceMeshProfile'`. The output should include:

   ```
   ```
4. To verify if the Istio control plane pods (istiod) have a "Running" status, run "kubectl get pods -n aks-istio-system". Make sure to obtain access credentials for the cluster with `az aks get-credentials -g myResourceGroupName -n myClusterName`. The output should include the name of the pod(s) and their status, for example:

```
NAME                               READY   STATUS    RESTARTS   AGE
istiod-asm-1-17-67f9f55ccb-4lxhk   1/1     Running   0          50s
```

### Section 3c: Debug sidecar injection of the add-on:

To enable sidecar injection, refer to this guide. This installs a sidecar to <ins>new</ins> pods, but not the existing ones, which enables the use of Istio's features in the new pods.

To verify the injection of the sidecar, create a new pod in the labeled namespace and confirm that it includes an istio-proxy container. For example:

```
kubectl run hello --image=gcr.io/google-samples/hello-app:1.0
kubectl get pod # Ensure the "hello" pod is in Running state with two containers.
kubectl describe pod hello | grep "Started container istio-proxy"
# kubectl delete po hello # cleanup.
```

To obtain a list of such annotated namespaces, run `kubectl get namespaces --show-labels | grep istio.io/rev=asm` or run `kubectl get namespace -l istio.io/rev=asm-1-17` if you prefer.

If Istio's features are no longer required for a namespace, for example, the "default" namespace, run `kubectl label namespace default istio.io/rev-` to remove the sidecar injection.

Note: Please make sure to replace "myClusterName" and "myResourceGroupName" with the actual names of your cluster and resource group respectively, in all the commands.

### Section 3d: Debug with Istioctl

1. To verify that Istioctl can connect to the cluster, run the command `istioctl x precheck`. A successful run should display the following message: 

   ```
   "No issues found when checking the cluster. Istio is safe to install or upgrade!"
   ```

   1a. If this command returns an error like the one below, ensure that kubectl works from the same console by running `kubectl get namespace`. You may need to obtain access credentials for the cluster using the command `az aks get-credentials -g myResourceGroupName -n myClusterName`.
   
   ```
   Error: unable to retrieve Pods: the server has asked for the client to provide credentials (get pods)
   ```

   1b. For any other error, re-run the command with `--vklog=9` for higher log level verbosity. To save the output to a file, add `> istioctl_logs.txt`.
   
2. To retrieve the proxy sync status for all Envoys in a mesh, run the command `istioctl proxy-status -i aks-istio-system`. This will return one row for each pod that has the proxy.

   ```
   NAME               CLUSTER        CDS        LDS        EDS        RDS        ECDS         ISTIOD                               VERSION
   hello.default      Kubernetes     SYNCED     SYNCED     SYNCED     SYNCED     NOT SENT     istiod-asm-1-17-67f9f55ccb-j85bk     1.17.1-distroless
   nginx.default      Kubernetes     SYNCED     SYNCED     SYNCED     SYNCED     NOT SENT     istiod-asm-1-17-67f9f55ccb-j85bk     1.17.1-distroless
   ```

   2a. If an envoy/pod is missing from the above list, it means that it is not currently connected to a Pilot instance and thus will not receive any configuration. Additionally, if it is marked as "STALE", it likely means there are networking issues or Pilot needs to be scaled.
   2b. "SYNCED" and "NOT SENT" are usually seen in the output. "STALE" indicates a networking issue between Envoy and Istiod.
   2c. Refer to the advanced user note below for further information about the output.

### Section 3e: Debug - Unexpected Issues

To get the Istiod pod logs, run the command `kubectl logs -l app=istiod -n aks-istio-system`. To see the recent logs, add `--since=2m` or `--since=1h`. To save the output to a file, add `> istiod_logs.txt`.

To get the logs for a pod in CrashLoopBackOff, find the failing container with the command `kubectl describe pod -n namespace_name crashing_pod_name`. Then, capture the logs with the command `kubectl logs -n namespace_name crashing_pod_name -c failing_container_name --previous`. You can also view the live logs with Container Insights or view historical logs in the ContainerLog table in Log Analytics.

View known issues here: [insert link here] or here: [insert link here].

### Section 3f: Debug - Metrics Issues

Enable Managed Prometheus and view metrics in the InsightsMetrics table.

Use Azure Managed Grafana to visualize metrics.

### Section 3g: Debug - Connectivity Issues Between Pods

1. To confirm connectivity between pods in annotated namespace(s), create new pods/deployments and use `curl` to access them. Run the following commands:

   ```
   kubectl run hello --image=gcr.io/google-samples/hello-app:1.0
   kubectl run nginx --image=nginx
   kubectl get po -owide # Ensure both pods are Running. Note the IP of the "hello" pod.
   kubectl exec -it nginx -- curl 10.244.2.14:8080 # Replace the IP of the "hello" pod. Ensure you use port 8080 since this is used by the hello app.
   kubectl delete po hello nginx # cleanup
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
   
   If connection errors occur for all pods in the namespace, temporarily disable sidecar injection for the namespace by running `kubectl label namespace default istio.io/rev-`. Then <ins>recreate</ins> the pods, so they do not have the sidecar, and retest connectivity between the pods to ensure it works fine without the sidecar.
   
   To review network policies in the cluster, run `kubectl get networkpolicy -A`.
   
   To capture simultaneous TCP dumps on source and destination nodes during the reproduction of the issue, use the steps mentioned here. Note the names, namespaces, and IPs of the source and destination pods with `kubectl get pod -A -owide`, and the names and IPs of the source and destination nodes with `kubectl get no -owide`.
   
### Section 3h: Debug - Connectivity Issues Through the Istio Ingress Gateway

Ensure the ingress gateway resource is created with the appropriate `Gateway` and `VirtualService` resources as shown here.

## Section 4: For Advanced Users

1. The istio-proxy container is the Envoy sidecar injected by Istio.
   1a. The sidecar containers are injected using a mutating admission webhook seen with kubectl get mutatingwebhookconfigurations | grep istio-sidecar-injector.
   1b. Use istioctl proxy-status -i aks-istio-system to retrieve the proxy sync status for all Envoys in a mesh. Each row denotes an Envoy proxy in each pod in the cluster.
       1bi. CDS, LDS, EDS, RDS, and ECDS are Envoy (the proxy underpinning Istio) services mentioned here and here.
       1bii. SYNCED and SYNCED statuses are usually seen, STALE usually indicates a networking issue between Envoy and Istiod as indicated here.
       1biii. The Istio service mesh architecture includes the proxy underpinning Istio, as shown here.
2. The Istio custom resources installed by the add-on can be seen with `kubectl get crd -A | grep "istio.io"`.
3. To view the ready status displayed in Envoy's access logs for a pod "hello", run `kubectl logs hello -c istio-proxy | grep "Envoy proxy is ready"`.
