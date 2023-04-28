# servicemesh-istio
This is my personal page dedicated to troubleshooting and debugging AKS with the Istio-based service mesh, and any opinions expressed here are my own. The commonly used tools for this project are [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli), kubectl, [istioctl](https://istio.io/latest/docs/setup/getting-started/#download), and optionally [jq](https://stedolan.github.io/jq/download/), or you can use the Bash environment in [Azure Cloud Shell](https://learn.microsoft.com/en-us/azure/cloud-shell/quickstart?tabs=azurecli). For a quick start guide, refer [this](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-cli).

# Section 1: Know more and know limitations

For more info, refer [this](https://docs.microsoft.com/en-us/azure/aks/servicemesh-istio-about). This includes limitations too. [Roadmap is here](https://docs.microsoft.com/en-us/azure/aks/servicemesh-istio-roadmap).

## Section 1a: Enable or disable the Istio add-on

1. To enable the Istio add-on for new or existing clusters, refer [this](https://docs.microsoft.com/en-us/azure/aks/servicemesh-istio-install). Sidecar injection must be enabled to use Istio's features. Also, the Istio ingress gateway must be enabled, with its Gateway and VirtualService resources, to manage inbound or outbound traffic for the mesh.
2. To disable the Istio add-on, refer [this](https://docs.microsoft.com/en-us/azure/aks/servicemesh-istio-uninstall).

## Section 1b: Enable external or internal Istio ingress gateway

1. To enable or delete, refer [this](https://docs.microsoft.com/en-us/azure/aks/servicemesh-istio-ingress). Gateway associates the Kubernetes or Kubernetes-internal load balancers (in the node resource group) to manage inbound or outbound traffic for the mesh, letting you specify which traffic you want to enter or leave the mesh.
   - Applications aren't accessible from outside the cluster by default after enabling the ingress gateway, ensure you map the deployment's ingress to the Istio ingress gateway using the Gateway and VirtualService resources mentioned in the same link.
2. For the `EXTERNAL-IP`, run the below for the respective gateway:

```
kubectl get svc aks-istio-ingressgateway-external -n aks-istio-ingress # external ingress gateway.
kubectl get svc aks-istio-ingressgateway-internal -n aks-istio-ingress # internal ingress gateway.
```

# Section 2: Know the version of the enabled add-on

To know the version of Istio enabled on AKS, run `kubectl get pods -n aks-istio-system`. A pod name `istiod-asm-1-17-67f9f55ccb-4lxhk` in its output indicates version 1-17 i.e. 1.17. The version is required for configuration of the sidecar injection.

# Section 3: Debug

## Section 3a: Debug - Errors with the `az aks` or `az aks mesh` commands

For unexpected errors with the `az aks` or `az aks mesh` commands, ensure these are updated to the latest version with `az upgrade` and `az extension update --name aks-preview`. Then re-run the `az aks` or `az aks mesh` command with `--debug`. For example, to capture logs to a file, run `az aks mesh enable -g myResourceGroupName -n myClusterName --debug 2> debug_output.log`.

## Section 3b: Debug - Verify the control plane is healthy

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

