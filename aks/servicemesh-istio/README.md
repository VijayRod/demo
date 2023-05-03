[![Istio service mesh addon](https://techcommunity.microsoft.com/t5/image/serverpage/image-id/462327iA69EF8B8167AEC91)](https://techcommunity.microsoft.com/t5/apps-on-azure-blog/istio-based-service-mesh-add-on-for-azure-kubernetes-service/ba-p/3800229)

## servicemesh-istio
This is my personal page dedicated to troubleshooting and debugging AKS with the Istio-based service mesh, and any opinions expressed here are my own. The commonly used tools for this project are [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli), kubectl, [istioctl](https://istio.io/latest/docs/setup/getting-started/#download), and optionally [jq](https://stedolan.github.io/jq/download/), or you can use the Bash environment in [Azure Cloud Shell](https://learn.microsoft.com/en-us/azure/cloud-shell/quickstart?tabs=azurecli). For a quick start guide, refer [this](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-cli).

## Table of Contents

- [Istio Add-On Configuration](#istio-add-on-configuration)
  - [Enable or disable the Istio add-on](#enable-or-disable-the-istio-add-on)
  - [Enable external or internal Istio ingress gateway](#enable-external-or-internal-istio-ingress-gateway)
  - [Know more and know limitations](#know-more-and-know-limitations)
  - [A Brief History of the Istio Project](#a-brief-history-of-the-istio-project)
  - [For Advanced Users](#for-advanced-users)
- [Know the version of the enabled add-on](#know-the-version-of-the-enabled-add-on)
- [Troubleshoot and debug](#troubleshoot-and-debug)
  - [Enable or disable - Errors with the az aks or az aks mesh commands](#enable-or-disable---errors-with-the-az-aks-or-az-aks-mesh-commands)
  - [Enable or disable - Debug sidecar injection of the add-on](#enable-or-disable---debug-sidecar-injection-of-the-add-on)
  - [Monitor - Verify the control plane is healthy](#monitor---verify-the-control-plane-is-healthy)
  - [Monitor - Debug with `istioctl`](#monitor---debug-with-istioctl)
  - [Monitor - Metrics Issues](#monitor---metrics-issues)
  - [Traffic - Connectivity issues between pods](#traffic---connectivity-issues-between-pods)
  - [Traffic - Connectivity issues through the Istio ingress gateway](#traffic---connectivity-issues-through-the-istio-ingress-gateway)
  - [Other - Unexpected pod issues](#other---unexpected-pod-issues)
  - [Known issues](#known-issues)
    - [Installing Istio using `istioctl upgrade` and Istio-based Service Mesh Add-on](#installing-istio-using-istioctl-upgrade-and-istio-based-service-mesh-add-on) 
 
## Istio Add-On Configuration

### Enable or disable the Istio add-on

1. To enable the Istio add-on for new or existing clusters, refer [this](https://learn.microsoft.com/en-us/azure/aks/istio-deploy-addon). 

   1a. Sidecar injection must be enabled to use Istio's features. Also, the Istio ingress gateway must be enabled, with its Gateway and VirtualService resources, to manage inbound or outbound traffic for the mesh.

2. To disable the Istio add-on, refer [this](https://learn.microsoft.com/en-us/azure/aks/istio-deploy-addon#delete-resources).

### Enable external or internal Istio ingress gateway

1. To enable or delete, refer [this](https://learn.microsoft.com/en-us/azure/aks/istio-deploy-ingress). The Istio gateway associates the `kubernetes` or `kubernetes-internal` load balancers (in the node resource group) to manage inbound or outbound traffic for the mesh, letting you specify which traffic you want to enter or leave the mesh.

   1a. Applications aren't accessible from outside the cluster by default after enabling the ingress gateway, ensure you map the deployment's ingress to the Istio ingress gateway using the `Gateway` and `VirtualService` resources mentioned in the same link.

2. For the `EXTERNAL-IP`, run the below for the respective gateway:

```
kubectl get svc aks-istio-ingressgateway-external -n aks-istio-ingress # external ingress gateway.
kubectl get svc aks-istio-ingressgateway-internal -n aks-istio-ingress # internal ingress gateway.
```

### Know more and know limitations

For more info, refer [this](https://techcommunity.microsoft.com/t5/apps-on-azure-blog/istio-based-service-mesh-add-on-for-azure-kubernetes-service/ba-p/3800229). [This](https://learn.microsoft.com/en-us/azure/aks/istio-about) includes limitations too. [Roadmap is here](https://aka.ms/asm-roadmap).

### A Brief History of the Istio Project

The Istio project was [started](https://istio.io/latest/about/faq/) by teams from Google and IBM in partnership with the Envoy team from Lyft. It’s been developed fully in the open on GitHub.

Istio was accepted to [CNCF](https://www.cncf.io/projects/istio/) on September 30, 2022.

(Credits: Pkc, Axel.)

### For Advanced Users

[![Istio Architecture](https://istio.io/latest/docs/ops/deployment/architecture/arch.svg)](https://istio.io/latest/docs/ops/deployment/architecture/)

1. The istio-proxy container is the Envoy sidecar injected by Istio.
   
   1a. The sidecar containers are injected using a mutating admission webhook seen with `kubectl get mutatingwebhookconfigurations | grep istio-sidecar-injector`.
   
   1b. Use `istioctl proxy-status -i aks-istio-system` to retrieve the proxy sync status for all Envoys in a mesh. Each row in the output denotes an Envoy proxy in each pod in the cluster.
   
      1b.i. `CDS`, `LDS`, `EDS`, `RDS`, and `ECDS`, seen in the output of the above command, are Envoy (the proxy underpinning Istio) services mentioned [here](https://github.com/istio/istio/issues/34139#issuecomment-1064377239) and [here](https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/operations/dynamic_configuration).
       
      1b.ii. `SYNCED` and `NOT SENT` statuses are usually seen, `STALE` usually indicates a networking issue between Envoy and Istiod as indicated [here](https://istio.io/latest/docs/ops/diagnostic-tools/proxy-cmd/).
       
      1b.iii. The Istio service mesh architecture includes the proxy underpinning Istio, as shown [here](https://istio.io/latest/docs/ops/deployment/architecture/).

2. The Istio custom resources installed by the add-on can be seen with `kubectl get crd -A | grep "istio.io"`.

3. To view the ready status displayed in Envoy's access logs for a pod "hello", run `kubectl logs hello -c istio-proxy | grep "Envoy proxy is ready"`.

4. You can find a sample application that is ideal for testing Istio's features [here](https://learn.microsoft.com/en-us/azure/aks/istio-deploy-addon#deploy-sample-application).

## Know the version of the enabled add-on

1. To know the version of Istio enabled on AKS, run `kubectl get pods -n aks-istio-system`. 

   1a. A pod name `istiod-asm-1-17-67f9f55ccb-4lxhk` in its output indicates version 1-17 i.e. 1.17. 

   1b. The version is required for configuration of the sidecar injection.

## Troubleshoot and debug

### Enable or disable - Errors with the `az aks` or `az aks mesh` commands

1. For unexpected errors with the `az aks` or `az aks mesh` commands, ensure these are updated to the latest version with [`az upgrade`](https://learn.microsoft.com/en-us/cli/azure/update-azure-cli) and `az extension update --name aks-preview`. 

   1a. Then re-run the `az aks` or `az aks mesh` command with `--debug`. 

   1b. For example, to capture logs to a file, run `az aks mesh enable -g myResourceGroupName -n myClusterName --debug 2> debug_output.log`.

### Enable or disable - Debug sidecar injection of the add-on

1. To enable sidecar injection, refer to [this](https://learn.microsoft.com/en-us/azure/aks/istio-deploy-addon#enable-sidecar-injection) guide. This installs a sidecar to <ins>new</ins> pods, but not the existing ones, which enables the use of Istio's features in the new pods.

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

### Monitor - Verify the control plane is healthy

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

### Monitor - Debug with `istioctl`

1. To verify that [`istioctl`](https://istio.io/latest/docs/setup/getting-started/#download) can connect to the cluster, run the command `istioctl x precheck`. A successful run should display the following message: 

   ```
   No issues found when checking the cluster. Istio is safe to install or upgrade!
   ```

   1a. If the command returns an error like the one below, ensure that `kubectl` works from the same console by running `kubectl get namespace`. You may need to obtain access credentials for the cluster using the command `az aks get-credentials -g myResourceGroupName -n myClusterName`.
   
   ```
   Error: unable to retrieve Pods: the server has asked for the client to provide credentials (get pods)
   ```

   1b. For any other error, re-run the istioctl command with `--vklog=9` for higher log level verbosity. 
   
   1c. To save the output to a file, add `> istioctl_logs.txt` to the command.
   
2. To retrieve the proxy sync status for all Envoys in a mesh, run the command `istioctl proxy-status -i aks-istio-system`, or istioctl x precheck -n default to only check a single namespace "default". This will return one row for each pod that has the proxy.

   ```
   NAME               CLUSTER        CDS        LDS        EDS        RDS        ECDS         ISTIOD                               VERSION
   hello.default      Kubernetes     SYNCED     SYNCED     SYNCED     SYNCED     NOT SENT     istiod-asm-1-17-67f9f55ccb-j85bk     1.17.1-distroless
   nginx.default      Kubernetes     SYNCED     SYNCED     SYNCED     SYNCED     NOT SENT     istiod-asm-1-17-67f9f55ccb-j85bk     1.17.1-distroless
   ```

   2a. If an envoy/pod is missing from the above output, it means that it is not currently connected to an Istio Pilot instance and thus will not receive any configuration.
   
   2b. `SYNCED` and `NOT SENT` are usually seen in the output. `STALE` indicates a networking issue between Envoy and Istiod or the Istio Pilot needs to be scaled.
   
   2c. Refer to the advanced user note [above](#for-advanced-users) for further information about the output if required.

3. To retrieve information about proxy configuration from an Envoy instance, run `istioctl proxy-config -i aks-istio-system all -o json hello -n default` for example for pod 'hello' in namespace 'default'. Instead of 'all', one of 'clusters|listeners|routes|endpoints|bootstrap|log|secret' can be used.

### Monitor - Metrics Issues

1. Enable [Managed Prometheus](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/prometheus-metrics-enable?tabs=azure-portal) and view metrics in the `InsightsMetrics` table. The metrics are listed [here](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/prometheus-metrics-scrape-default), and the troubleshooting steps are [here](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/prometheus-metrics-troubleshoot).

2. Use [Azure Managed Grafana](https://learn.microsoft.com/en-Us/azure/azure-monitor/essentials/prometheus-metrics-overview#grafana-integration) to visualize metrics.

### Traffic - Connectivity issues between pods

1. To confirm connectivity between pods, create new pods/deployments in the annotated namespace(s), and use curl within the pod(s) to access each other. For example, run the following commands for the default namespace:

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
   
4. To capture simultaneous TCP dumps on source and destination nodes during the reproduction of the issue, use the steps mentioned [here](https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/capture-tcp-dump-linux-node-aks). 

   4a. Note the names, namespaces, and IPs of the source and destination pods with `kubectl get pod -A -owide`, and the names and IPs of the source and destination nodes with `kubectl get no -owide`.
   
### Traffic - Connectivity issues through the Istio ingress gateway

1. Ensure the ingress gateway resource is created with the appropriate `Gateway` and `VirtualService` resources as shown [here](#section-1b-enable-external-or-internal-istio-ingress-gateway).

### Other - Unexpected pod issues

1. To get the Istiod pod logs, run the command `kubectl logs -l app=istiod -n aks-istio-system`. To list the Istio pods, run `kubectl get po -l app=istiod -n aks-istio-system`.

   1a. To see the recent logs, add `--since=2m` or `--since=1h`. 
 
      1a.i. To save the output to a file, add `> istiod_logs.txt`.

2. To get the logs for a pod in `CrashLoopBackOff`, find the failing container with the command `kubectl describe pod -n namespace_name crashing_pod_name`. 

   2a. Then, capture the logs with the command `kubectl logs -n namespace_name crashing_pod_name -c failing_container_name --previous`. 
  
   2b. You can also view the [live logs](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-livedata-overview) with Container Insights or view historical logs in the [`ContainerLog`](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-log-query) table in [Log Analytics](https://learn.microsoft.com/en-us/azure/aks/monitor-aks).

### Known issues

If there are any known issues, you can find them listed [here](https://github.com/Azure/AKS/issues?q=is%3Aissue+is%3Aopen+istio) or [here](https://github.com/Azure/AKS/releases).

#### Installing Istio using `istioctl upgrade` and Istio-based Service Mesh Add-on

Installing Istio with `istioctl upgrade` together with the Istio-based service mesh add-on is *not supported*. As documented [here](https://learn.microsoft.com/en-us/azure/aks/istio-about#limitations), the add-on doesn't work with AKS clusters that have Istio installed outside of the add-on installation. Attempting to install the add-on in these circumstances may result in errors and symptoms such as:
- `istioctl upgrade` deploying objects to the default `istio-system` namespace (which is different from the `aks-istio-system` namespace used by the AKS Istio add-on)
- namespaces with a different label found with `kubectl get namespace -l istio-injection=enabled` (the AKS Istio add-on uses explicit versioning for namespace labels, as indicated [here](https://learn.microsoft.com/en-us/azure/aks/istio-deploy-addon#enable-sidecar-injection))
- pods in annotated namespaces not being deployed with AKS Istio add-on's `istio-proxy` sidecar container.

You can use `istioctl uninstall --purge` to clean up the non-add-on objects, but this would also delete the add-on CRDs. Therefore, after the clean up, it may be better to disable the add-on with `az aks mesh disable -g myResourceGroupName -n myClusterName`, and then re-enable it with `az aks mesh enable -g myResourceGroupName -n myClusterName`. Additionally, pods not having the sidecar container would need to be re-created.

(Credits: Sergio Turrent.)
