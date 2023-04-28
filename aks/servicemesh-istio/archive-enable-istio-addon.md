
This page has guidance on how to troubleshoot and debug the enabling of the Istio add-on on AKS.

### Enable the Istio add-on

To enable Istio on AKS, you can either create a new AKS cluster or use an existing one. Use the following commands:

1. For a new cluster, run `az aks create -g myResourceGroupName -n myClusterName --enable-asm` with the appropriate names.
   
   a. For an existing cluster, run `az aks mesh enable -g myResourceGroupName -n myClusterName`.
   
   b. For detailed steps, refer to [https://learn.microsoft.com/en-us/azure/aks/istio-deploy-addon](https://learn.microsoft.com/en-us/azure/aks/istio-deploy-addon).
2. To capture logs for unexpected failures, re-run the respective command with `--debug`. For example, to capture logs to a file, run `az aks mesh enable -g myResourceGroupName -n myClusterName --debug 2> debug_output.log`.
3. To verify success:

   a. Run `az aks show -g myResourceGroupName -n myClusterName --query 'serviceMeshProfile'` to ensure Istio is enabled. The output includes "mode" as Istio.

    ```json
    {
      "istio": {
        "components": {
          "ingressGateways": null
        }
      },
      "mode": "Istio"
    }
    ```

   b. Run `az aks show -g myResourceGroupName -n myClusterName --query 'provisioningState'` to ensure the cluster is in a `Succeeded` state.

   c. Run `kubectl get pods -n aks-istio-system` to verify that the Istio control plane pods have a `Running` status. This is after obtaining access credentials for the cluster with `az aks get-credentials -g myResourceGroupName -n myClusterName`.

    ```bash
    NAME                               READY   STATUS    RESTARTS   AGE
    istiod-asm-1-17-67f9f55ccb-4lxhk   1/1     Running   0          50s
    ```
4. Note that *sidecar injection mentioned [below](#enable-automatic-sidecar-injection-of-the-add-on) must be enabled to use Istio's features*.

### Know the version of the enabled add-on

To know the version of Istio enabled on AKS, run `kubectl get pods -n aks-istio-system`. The pod name `istiod-asm-1-17-67f9f55ccb-4lxhk` in its output indicates version `1-17` i.e. 1.17.

### Enable automatic sidecar injection of the add-on

Sidecar injection must be enabled to use Istio's features. 

1. To automatically install a sidecar to new pods, annotate each required namespace using the required version obtained from [above](#know-the-version-of-the-enabled-add-on). For example, to annotate the "default" namespace, run `kubectl label namespace default istio.io/rev=asm-1-17`.

    a. To obtain a list of such annotated namespaces, run `kubectl get namespaces --show-labels | grep istio.io/rev=asm`, or run `kubectl get namespace -l istio.io/rev=asm-1-17` if you prefer.
    
    b. For *manual* sidecar injection, refer to [https://learn.microsoft.com/en-us/azure/aks/istio-deploy-addon#enable-sidecar-injection](https://learn.microsoft.com/en-us/azure/aks/istio-deploy-addon#enable-sidecar-injection).

2. To verify the injection of the sidecar, create a new pod in the labeled namespace and confirm it includes an `istio-proxy` container. Examples below assume "default" namespace is annotated, else add `-n namespacename`.

    ```bash
    kubectl run hello --image=gcr.io/google-samples/hello-app:1.0
    kubectl get pod # Ensure the "hello" pod is in Running state with two containers.
    kubectl describe pod hello | grep "Started container istio-proxy"
    ```

3. If Istio's features are no longer required for a namespace, say with the name "default", run `kubectl label namespace default istio.io/rev-` to remove the sidecar injection.

### Optionally, verify connectivity between pods in the annotated namespace(s)

To confirm connectivity between pods in the annotated namespace(s), you can either use curl to access your own pods/deployments or follow the steps outlined below. Note that it is crucial to create <ins>new</ins> pods/deployments rather than using existing ones.

1. Create another pod and ensure you are able to connect. Run the following commands and verify the "hello" and "nginx" pods are in the Running status:
    ```bash
    kubectl run nginx --image=nginx
    kubectl get po -owide
    ```
   Note the IP of the "hello" pod.

2. Run the below by replacing the IP of the "hello" pod. Ensure you use port 8080 since this is used by the hello app.:
    ```bash
    kubectl exec -it nginx -- curl 10.244.2.14:8080
    ```

   a. If an incorrect port is used, you will get a `delayed connect error` like below. This is an HTTP error 500.
    
      ```bash
      kubectl exec -it nginx -- curl 10.244.2.14:90
      upstream connect error or disconnect/reset before headers. reset reason: connection failure, transport failure reason: delayed connect error: 111
      ```
       
   b. If there are other connection errors, check source and destination access logs by running:
    
      ```bash
      kubectl logs hello -c istio-proxy
      ```

    c. If the connection errors are occurring for all pods in the namespace, you may want to temporarily disable sidecar injection by running `kubectl label namespace default istio.io/rev-`. Then, recreate the pods so they do not have the sidecar and retest connectivity between the pods to ensure it works fine without the sidecar.

### For advanced users

1. The istio-proxy container is the Envoy sidecar injected by Istio. The sidecar containers are injected using a mutating admission webhook seen with:

```bash
kubectl get mutatingwebhookconfigurations | grep istio-sidecar-injector
```

2. The Istio custom resources installed by the add-on can be seen with:
```bash
kubectl get crd -A | grep "istio.io".
```

3. To view the ready status displayed in Envoy's access logs for a pod "hello", run:

```bash
kubectl logs hello -c istio-proxy | grep "Envoy proxy is ready"
```

4. You can find a sample application that is ideal for testing Istio's features at [https://learn.microsoft.com/en-us/azure/aks/istio-deploy-addon#deploy-sample-application](https://learn.microsoft.com/en-us/azure/aks/istio-deploy-addon#deploy-sample-application).
