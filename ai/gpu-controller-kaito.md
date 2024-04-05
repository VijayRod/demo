![Kaito architecture](https://github.com/Azure/kaito/blob/main/docs/img/arch.png)

## More about Kaito

If you want to deploy AI/ML models like falcon and llama2 on a Kubernetes cluster, you can use `Kubernetes AI Toolchain Operator` (Kaito). It's an operator that handles the deployment for you automatically. These models are large and open-sourced, so they're popular for inference tasks.

## Table of Contents

- Workspace and machine controllers
- How the AI model affects the workspace and machine resources
- Kaito model repository
- More

## Workspace and machine controllers

Kaito makes two controllers. One is a `workspace` controller, which makes a workspace resource for each AI model we host. The other is a `gpu-provisioner` controller, which creates GPU nodes for the model.

```
|-- Workspace controller
    |-- CRDs - workspace, machine (deployment or statefulset to create inference workloads)
|-- Node provisioner controller (gpu-provisioner)
```

- https://github.com/Azure/kaito/blob/main/charts/kaito/gpu-provisioner/README.md
- https://github.com/Azure/kaito/blob/main/charts/kaito/workspace/README.md
- https://github.com/Azure/gpu-provisioner/tree/main/charts/gpu-provisioner

## How the AI model affects the workspace and machine resources

Here's what happens: the `workspace` controller looks at the AI model spec you send and sees if it needs to make any worker nodes that fit the workspace resource spec. Then it sets up a service and a deployment/statefulset for the AI inference model. The `gpu-provisioner` controller is in charge of creating the worker nodes.

```
kubectl apply -f https://raw.githubusercontent.com/Azure/kaito/main/examples/inference/kaito_workspace_falcon_7b-instruct.yaml
workspace.kaito.sh/workspace-falcon-7b-instruct created

kubectl get machines -w
NAME          TYPE   ZONE   NODE   READY   AGE
wsb42f9cb5f                                2m47s
wsb42f9cb5f                                4m18s
wsb42f9cb5f                 aks-wsb42f9cb5f-41071934-vmss000000   True    4m18s

kubectl get workspace workspace-falcon-7b-instruct -w
NAME                           INSTANCE            RESOURCEREADY   INFERENCEREADY   WORKSPACEREADY   AGE
workspace-falcon-7b-instruct   Standard_NC12s_v3                                                     51s
workspace-falcon-7b-instruct   Standard_NC12s_v3                                                     4m2s
workspace-falcon-7b-instruct   Standard_NC12s_v3   False                                             4m2s
workspace-falcon-7b-instruct   Standard_NC12s_v3   False                            False            4m2s
workspace-falcon-7b-instruct   Standard_NC12s_v3   False                            False            4m20s
workspace-falcon-7b-instruct   Standard_NC12s_v3   False                            False            4m20s
workspace-falcon-7b-instruct   Standard_NC12s_v3   True                             False            4m20s
workspace-falcon-7b-instruct   Standard_NC12s_v3   True            True             False            16m
workspace-falcon-7b-instruct   Standard_NC12s_v3   True            True             True             16m

kubectl logs -n kube-system kaito-workspace-6bf49b98cb-z5k2b
{"severity":"INFO","timestamp":"2024-04-05T18:29:58.775905523Z","logger":"webhook","caller":"webhook/admission.go:93","message":"Webhook ServeHTTP request=&http.Request{Method:\"POST\", URL:(*url.URL)(0xc0008e1320), Proto:\"HTTP/1.1\", ProtoMajor:1, ProtoMinor:1, Header:http.Header{\"Accept\":[]string{\"application/json, */*\"}, \"Accept-Encoding\":[]string{\"gzip\"}, \"Content-Length\":[]string{\"1999\"}, \"Content-Type\":[]string{\"application/json\"}, \"User-Agent\":[]string{\"kube-apiserver-admission\"}}, Body:(*http.body)(0xc000cad080), GetBody:(func() (io.ReadCloser, error))(nil), ContentLength:1999, TransferEncoding:[]string(nil), Close:false, Host:\"workspace-webhook-svc.kube-system.svc:9443\", Form:url.Values(nil), PostForm:url.Values(nil), MultipartForm:(*multipart.Form)(nil), Trailer:http.Header(nil), RemoteAddr:\"10.244.1.8:55122\", RequestURI:\"/validate/workspace.kaito.sh?timeout=10s\", TLS:(*tls.ConnectionState)(0xc000509a20), Cancel:(<-chan struct {})(nil), Response:(*http.Response)(nil), ctx:(*context.cancelCtx)(0xc0002777c0)}"}
I0405 18:29:58.777958       1 workspace_validation.go:36] "Validate creation" workspace="default/workspace-falcon-7b-instruct"
{"severity":"INFO","timestamp":"2024-04-05T18:29:58.778006031Z","logger":"webhook","caller":"webhook/admission.go:151","message":"remote admission controller audit annotations=map[string]string(nil)","knative.dev/kind":"kaito.sh/v1alpha1, Kind=Workspace","knative.dev/namespace":"default","knative.dev/name":"workspace-falcon-7b-instruct","knative.dev/operation":"CREATE","knative.dev/resource":"kaito.sh/v1alpha1, Resource=workspaces","knative.dev/subresource":"","knative.dev/userinfo":"masterclient","admissionreview/uid":"d4491a98-da26-451b-8d25-feede578fe86","admissionreview/allowed":true,"admissionreview/result":"nil"}
I0405 18:29:58.788261       1 workspace_controller.go:60] "Reconciling" workspace="default/workspace-falcon-7b-instruct"
{"severity":"INFO","timestamp":"2024-04-05T18:29:58.83608777Z","logger":"webhook","caller":"webhook/admission.go:93","message":"Webhook ServeHTTP request=&http.Request{Method:\"POST\", URL:(*url.URL)(0xc000a37680), Proto:\"HTTP/1.1\", ProtoMajor:1, ProtoMinor:1, Header:http.Header{\"Accept\":[]string{\"application/json, */*\"}, \"Accept-Encoding\":[]string{\"gzip\"}, \"Content-Length\":[]string{\"3836\"}, \"Content-Type\":[]string{\"application/json\"}, \"User-Agent\":[]string{\"kube-apiserver-admission\"}}, Body:(*http.body)(0xc000cad740), GetBody:(func() (io.ReadCloser, error))(nil), ContentLength:3836, TransferEncoding:[]string(nil), Close:false, Host:\"workspace-webhook-svc.kube-system.svc:9443\", Form:url.Values(nil), PostForm:url.Values(nil), MultipartForm:(*multipart.Form)(nil), Trailer:http.Header(nil), RemoteAddr:\"10.244.0.12:52300\", RequestURI:\"/validate/workspace.kaito.sh?timeout=10s\", TLS:(*tls.ConnectionState)(0xc000509d90), Cancel:(<-chan struct {})(nil), Response:(*http.Response)(nil), ctx:(*context.cancelCtx)(0xc000277bd0)}"}
I0405 18:29:58.836523       1 workspace_validation.go:42] "Validate update" workspace="default/workspace-falcon-7b-instruct"
{"severity":"INFO","timestamp":"2024-04-05T18:29:58.836553272Z","logger":"webhook","caller":"webhook/admission.go:151","message":"remote admission controller audit annotations=map[string]string(nil)","knative.dev/kind":"kaito.sh/v1alpha1, Kind=Workspace","knative.dev/namespace":"default","knative.dev/name":"workspace-falcon-7b-instruct","knative.dev/operation":"UPDATE","knative.dev/resource":"kaito.sh/v1alpha1, Resource=workspaces","knative.dev/subresource":"","knative.dev/userinfo":"system:serviceaccount:kube-system:kaito-workspace","admissionreview/uid":"b7096661-6e12-416f-9006-24d17b56f306","admissionreview/allowed":true,"admissionreview/result":"nil"}
I0405 18:29:58.945780       1 workspace_controller.go:275] "no current nodes match the workspace resource spec" workspace="default/workspace-falcon-7b-instruct"
I0405 18:29:58.945820       1 workspace_controller.go:203] "need to create more nodes" NodeCount=1
I0405 18:29:58.945845       1 workspace_status.go:54] "updateStatusCondition" workspace="default/workspace-falcon-7b-instruct" conditionType="MachineReady" status="Unknown" reason="CreateMachinePending" message="creating 1 machines"
{"severity":"INFO","timestamp":"2024-04-05T18:29:58.950859643Z","logger":"webhook","caller":"webhook/admission.go:93","message":"Webhook ServeHTTP request=&http.Request{Method:\"POST\", URL:(*url.URL)(0xc000bdec60), Proto:\"HTTP/1.1\", ProtoMajor:1, ProtoMinor:1, Header:http.Header{\"Accept\":[]string{\"application/json, */*\"}, \"Accept-Encoding\":[]string{\"gzip\"}, \"Content-Length\":[]string{\"4630\"}, \"Content-Type\":[]string{\"application/json\"}, \"User-Agent\":[]string{\"kube-apiserver-admission\"}}, Body:(*http.body)(0xc000a7bc40), GetBody:(func() (io.ReadCloser, error))(nil), ContentLength:4630, TransferEncoding:[]string(nil), Close:false, Host:\"workspace-webhook-svc.kube-system.svc:9443\", Form:url.Values(nil), PostForm:url.Values(nil), MultipartForm:(*multipart.Form)(nil), Trailer:http.Header(nil), RemoteAddr:\"10.244.0.12:52300\", RequestURI:\"/validate/workspace.kaito.sh?timeout=10s\", TLS:(*tls.ConnectionState)(0xc000509d90), Cancel:(<-chan struct {})(nil), Response:(*http.Response)(nil), ctx:(*context.cancelCtx)(0xc000b0db80)}"}
I0405 18:29:58.951580       1 workspace_validation.go:42] "Validate update" workspace="default/workspace-falcon-7b-instruct"
{"severity":"INFO","timestamp":"2024-04-05T18:29:58.951612946Z","logger":"webhook","caller":"webhook/admission.go:151","message":"remote admission controller audit annotations=map[string]string(nil)","knative.dev/kind":"kaito.sh/v1alpha1, Kind=Workspace","knative.dev/namespace":"default","knative.dev/name":"workspace-falcon-7b-instruct","knative.dev/operation":"UPDATE","knative.dev/resource":"kaito.sh/v1alpha1, Resource=workspaces","knative.dev/subresource":"status","knative.dev/userinfo":"system:serviceaccount:kube-system:kaito-workspace","admissionreview/uid":"a736e9f0-3114-475e-8360-af185a116b99","admissionreview/allowed":true,"admissionreview/result":"nil"}
I0405 18:29:58.957656       1 machine.go:109] "CreateMachine" machine="default/wsb42f9cb5f"
I0405 18:29:59.967319       1 machine.go:190] "CheckMachineStatus" machine="wsb42f9cb5f"
I0405 18:34:00.130008       1 workspace_status.go:54] "updateStatusCondition" workspace="default/workspace-falcon-7b-instruct" conditionType="MachineReady" status="False" reason="checkMachineStatusFailed" message="check machine status timed out. machine wsb42f9cb5f is not ready"
{"severity":"INFO","timestamp":"2024-04-05T18:34:00.184743187Z","logger":"webhook","caller":"webhook/admission.go:93","message":"Webhook ServeHTTP request=&http.Request{Method:\"POST\", URL:(*url.URL)(0xc000a3a750), Proto:\"HTTP/1.1\", ProtoMajor:1, ProtoMinor:1, Header:http.Header{\"Accept\":[]string{\"application/json, */*\"}, \"Accept-Encoding\":[]string{\"gzip\"}, \"Content-Length\":[]string{\"5081\"}, \"Content-Type\":[]string{\"application/json\"}, \"User-Agent\":[]string{\"kube-apiserver-admission\"}}, Body:(*http.body)(0xc00097be00), GetBody:(func() (io.ReadCloser, error))(nil), ContentLength:5081, TransferEncoding:[]string(nil), Close:false, Host:\"workspace-webhook-svc.kube-system.svc:9443\", Form:url.Values(nil), PostForm:url.Values(nil), MultipartForm:(*multipart.Form)(nil), Trailer:http.Header(nil), RemoteAddr:\"10.244.0.12:41698\", RequestURI:\"/validate/workspace.kaito.sh?timeout=10s\", TLS:(*tls.ConnectionState)(0xc000509ce0), Cancel:(<-chan struct {})(nil), Response:(*http.Response)(nil), ctx:(*context.cancelCtx)(0xc000d2f7c0)}"}
I0405 18:34:00.185282       1 workspace_validation.go:42] "Validate update" workspace="default/workspace-falcon-7b-instruct"
{"severity":"INFO","timestamp":"2024-04-05T18:34:00.18532959Z","logger":"webhook","caller":"webhook/admission.go:151","message":"remote admission controller audit annotations=map[string]string(nil)","knative.dev/kind":"kaito.sh/v1alpha1, Kind=Workspace","knative.dev/namespace":"default","knative.dev/name":"workspace-falcon-7b-instruct","knative.dev/operation":"UPDATE","knative.dev/resource":"kaito.sh/v1alpha1, Resource=workspaces","knative.dev/subresource":"status","knative.dev/userinfo":"system:serviceaccount:kube-system:kaito-workspace","admissionreview/uid":"6eec004a-c661-4a42-8cd3-8bc314e1f778","admissionreview/allowed":true,"admissionreview/result":"nil"}
I0405 18:34:00.192123       1 workspace_status.go:54] "updateStatusCondition" workspace="default/workspace-falcon-7b-instruct" conditionType="ResourceReady" status="False" reason="workspaceResourceStatusFailed" message="check machine status timed out. machine wsb42f9cb5f is not ready"
{"severity":"INFO","timestamp":"2024-04-05T18:34:00.196580547Z","logger":"webhook","caller":"webhook/admission.go:93","message":"Webhook ServeHTTP request=&http.Request{Method:\"POST\", URL:(*url.URL)(0xc000a3b950), Proto:\"HTTP/1.1\", ProtoMajor:1, ProtoMinor:1, Header:http.Header{\"Accept\":[]string{\"application/json, */*\"}, \"Accept-Encoding\":[]string{\"gzip\"}, \"Content-Length\":[]string{\"5355\"}, \"Content-Type\":[]string{\"application/json\"}, \"User-Agent\":[]string{\"kube-apiserver-admission\"}}, Body:(*http.body)(0xc0008a3300), GetBody:(func() (io.ReadCloser, error))(nil), ContentLength:5355, TransferEncoding:[]string(nil), Close:false, Host:\"workspace-webhook-svc.kube-system.svc:9443\", Form:url.Values(nil), PostForm:url.Values(nil), MultipartForm:(*multipart.Form)(nil), Trailer:http.Header(nil), RemoteAddr:\"10.244.0.12:41698\", RequestURI:\"/validate/workspace.kaito.sh?timeout=10s\", TLS:(*tls.ConnectionState)(0xc000509ce0), Cancel:(<-chan struct {})(nil), Response:(*http.Response)(nil), ctx:(*context.cancelCtx)(0xc000d2f9f0)}"}
I0405 18:34:00.197030       1 workspace_validation.go:42] "Validate update" workspace="default/workspace-falcon-7b-instruct"
{"severity":"INFO","timestamp":"2024-04-05T18:34:00.197056249Z","logger":"webhook","caller":"webhook/admission.go:151","message":"remote admission controller audit annotations=map[string]string(nil)","knative.dev/kind":"kaito.sh/v1alpha1, Kind=Workspace","knative.dev/namespace":"default","knative.dev/name":"workspace-falcon-7b-instruct","knative.dev/operation":"UPDATE","knative.dev/resource":"kaito.sh/v1alpha1, Resource=workspaces","knative.dev/subresource":"status","knative.dev/userinfo":"system:serviceaccount:kube-system:kaito-workspace","admissionreview/uid":"2eb8ea65-66c1-4b7f-bb9e-4bc5eb9280cb","admissionreview/allowed":true,"admissionreview/result":"nil"}
I0405 18:34:00.204756       1 workspace_status.go:54] "updateStatusCondition" workspace="default/workspace-falcon-7b-instruct" conditionType="WorkspaceReady" status="False" reason="workspaceFailed" message="check machine status timed out. machine wsb42f9cb5f is not ready"
{"severity":"INFO","timestamp":"2024-04-05T18:34:00.20919511Z","logger":"webhook","caller":"webhook/admission.go:93","message":"Webhook ServeHTTP request=&http.Request{Method:\"POST\", URL:(*url.URL)(0xc0006f8120), Proto:\"HTTP/1.1\", ProtoMajor:1, ProtoMinor:1, Header:http.Header{\"Accept\":[]string{\"application/json, */*\"}, \"Accept-Encoding\":[]string{\"gzip\"}, \"Content-Length\":[]string{\"5796\"}, \"Content-Type\":[]string{\"application/json\"}, \"User-Agent\":[]string{\"kube-apiserver-admission\"}}, Body:(*http.body)(0xc0008a3a00), GetBody:(func() (io.ReadCloser, error))(nil), ContentLength:5796, TransferEncoding:[]string(nil), Close:false, Host:\"workspace-webhook-svc.kube-system.svc:9443\", Form:url.Values(nil), PostForm:url.Values(nil), MultipartForm:(*multipart.Form)(nil), Trailer:http.Header(nil), RemoteAddr:\"10.244.0.12:41698\", RequestURI:\"/validate/workspace.kaito.sh?timeout=10s\", TLS:(*tls.ConnectionState)(0xc000509ce0), Cancel:(<-chan struct {})(nil), Response:(*http.Response)(nil), ctx:(*context.cancelCtx)(0xc000d2fbd0)}"}
I0405 18:34:00.209833       1 workspace_validation.go:42] "Validate update" workspace="default/workspace-falcon-7b-instruct"
{"severity":"INFO","timestamp":"2024-04-05T18:34:00.209884614Z","logger":"webhook","caller":"webhook/admission.go:151","message":"remote admission controller audit annotations=map[string]string(nil)","knative.dev/kind":"kaito.sh/v1alpha1, Kind=Workspace","knative.dev/namespace":"default","knative.dev/name":"workspace-falcon-7b-instruct","knative.dev/operation":"UPDATE","knative.dev/resource":"kaito.sh/v1alpha1, Resource=workspaces","knative.dev/subresource":"status","knative.dev/userinfo":"system:serviceaccount:kube-system:kaito-workspace","admissionreview/uid":"092e6fc6-aa22-46f5-b632-05b9cbe9fafa","admissionreview/allowed":true,"admissionreview/result":"nil"}
2024-04-05T18:34:00Z    ERROR   Reconciler error        {"controller": "workspace", "controllerGroup": "kaito.sh", "controllerKind": "Workspace", "Workspace": {"name":"workspace-falcon-7b-instruct","namespace":"default"}, "namespace": "default", "name": "workspace-falcon-7b-instruct", "reconcileID": "a16329f0-1b97-491c-9884-8bd88f17b744", "error": "check machine status timed out. machine wsb42f9cb5f is not ready"}
sigs.k8s.io/controller-runtime/pkg/internal/controller.(*Controller).reconcileHandler
        /go/pkg/mod/sigs.k8s.io/controller-runtime@v0.15.2/pkg/internal/controller/controller.go:324
sigs.k8s.io/controller-runtime/pkg/internal/controller.(*Controller).processNextWorkItem
        /go/pkg/mod/sigs.k8s.io/controller-runtime@v0.15.2/pkg/internal/controller/controller.go:265
sigs.k8s.io/controller-runtime/pkg/internal/controller.(*Controller).Start.func2.2
        /go/pkg/mod/sigs.k8s.io/controller-runtime@v0.15.2/pkg/internal/controller/controller.go:226
I0405 18:34:00.216250       1 workspace_controller.go:60] "Reconciling" workspace="default/workspace-falcon-7b-instruct"
I0405 18:34:00.216355       1 machine.go:190] "CheckMachineStatus" machine="wsb42f9cb5f"
I0405 18:34:17.231382       1 machine.go:219] "machine status is ready" machine="wsb42f9cb5f"
I0405 18:34:17.231603       1 nodes.go:51] "UpdateNodeWithLabel" nodeName="aks-wsb42f9cb5f-41071934-vmss000000" labelKey="accelerator" labelValue="nvidia"
I0405 18:34:18.248848       1 workspace_status.go:54] "updateStatusCondition" workspace="default/workspace-falcon-7b-instruct" conditionType="MachineReady" status="True" reason="installNodePluginsSuccess" message="machines plugins have been installed successfully"
{"severity":"INFO","timestamp":"2024-04-05T18:34:18.298334781Z","logger":"webhook","caller":"webhook/admission.go:93","message":"Webhook ServeHTTP request=&http.Request{Method:\"POST\", URL:(*url.URL)(0xc00055d8c0), Proto:\"HTTP/1.1\", ProtoMajor:1, ProtoMinor:1, Header:http.Header{\"Accept\":[]string{\"application/json, */*\"}, \"Accept-Encoding\":[]string{\"gzip\"}, \"Content-Length\":[]string{\"5995\"}, \"Content-Type\":[]string{\"application/json\"}, \"User-Agent\":[]string{\"kube-apiserver-admission\"}}, Body:(*http.body)(0xc000bcdd40), GetBody:(func() (io.ReadCloser, error))(nil), ContentLength:5995, TransferEncoding:[]string(nil), Close:false, Host:\"workspace-webhook-svc.kube-system.svc:9443\", Form:url.Values(nil), PostForm:url.Values(nil), MultipartForm:(*multipart.Form)(nil), Trailer:http.Header(nil), RemoteAddr:\"10.244.0.12:59116\", RequestURI:\"/validate/workspace.kaito.sh?timeout=10s\", TLS:(*tls.ConnectionState)(0xc000027130), Cancel:(<-chan struct {})(nil), Response:(*http.Response)(nil), ctx:(*context.cancelCtx)(0xc000b65450)}"}
I0405 18:34:18.298844       1 workspace_validation.go:42] "Validate update" workspace="default/workspace-falcon-7b-instruct"
{"severity":"INFO","timestamp":"2024-04-05T18:34:18.298875884Z","logger":"webhook","caller":"webhook/admission.go:151","message":"remote admission controller audit annotations=map[string]string(nil)","knative.dev/kind":"kaito.sh/v1alpha1, Kind=Workspace","knative.dev/namespace":"default","knative.dev/name":"workspace-falcon-7b-instruct","knative.dev/operation":"UPDATE","knative.dev/resource":"kaito.sh/v1alpha1, Resource=workspaces","knative.dev/subresource":"status","knative.dev/userinfo":"system:serviceaccount:kube-system:kaito-workspace","admissionreview/uid":"f8500fa0-73aa-4380-94c2-947e27ca893e","admissionreview/allowed":true,"admissionreview/result":"nil"}
I0405 18:34:18.305569       1 workspace_status.go:74] "updateStatusNodeList" workspace="default/workspace-falcon-7b-instruct"
{"severity":"INFO","timestamp":"2024-04-05T18:34:18.312272251Z","logger":"webhook","caller":"webhook/admission.go:93","message":"Webhook ServeHTTP request=&http.Request{Method:\"POST\", URL:(*url.URL)(0xc000a3a750), Proto:\"HTTP/1.1\", ProtoMajor:1, ProtoMinor:1, Header:http.Header{\"Accept\":[]string{\"application/json, */*\"}, \"Accept-Encoding\":[]string{\"gzip\"}, \"Content-Length\":[]string{\"6053\"}, \"Content-Type\":[]string{\"application/json\"}, \"User-Agent\":[]string{\"kube-apiserver-admission\"}}, Body:(*http.body)(0xc000a50b40), GetBody:(func() (io.ReadCloser, error))(nil), ContentLength:6053, TransferEncoding:[]string(nil), Close:false, Host:\"workspace-webhook-svc.kube-system.svc:9443\", Form:url.Values(nil), PostForm:url.Values(nil), MultipartForm:(*multipart.Form)(nil), Trailer:http.Header(nil), RemoteAddr:\"10.244.0.12:59116\", RequestURI:\"/validate/workspace.kaito.sh?timeout=10s\", TLS:(*tls.ConnectionState)(0xc000027130), Cancel:(<-chan struct {})(nil), Response:(*http.Response)(nil), ctx:(*context.cancelCtx)(0xc0003cc550)}"}
I0405 18:34:18.312923       1 workspace_validation.go:42] "Validate update" workspace="default/workspace-falcon-7b-instruct"
{"severity":"INFO","timestamp":"2024-04-05T18:34:18.312949954Z","logger":"webhook","caller":"webhook/admission.go:151","message":"remote admission controller audit annotations=map[string]string(nil)","knative.dev/kind":"kaito.sh/v1alpha1, Kind=Workspace","knative.dev/namespace":"default","knative.dev/name":"workspace-falcon-7b-instruct","knative.dev/operation":"UPDATE","knative.dev/resource":"kaito.sh/v1alpha1, Resource=workspaces","knative.dev/subresource":"status","knative.dev/userinfo":"system:serviceaccount:kube-system:kaito-workspace","admissionreview/uid":"1a24351c-7e19-4d91-9620-59c02130cde8","admissionreview/allowed":true,"admissionreview/result":"nil"}
I0405 18:34:18.320310       1 workspace_status.go:54] "updateStatusCondition" workspace="default/workspace-falcon-7b-instruct" conditionType="ResourceReady" status="True" reason="workspaceResourceStatusSuccess" message="workspace resource is ready"
{"severity":"INFO","timestamp":"2024-04-05T18:34:18.325153715Z","logger":"webhook","caller":"webhook/admission.go:93","message":"Webhook ServeHTTP request=&http.Request{Method:\"POST\", URL:(*url.URL)(0xc000a3b0e0), Proto:\"HTTP/1.1\", ProtoMajor:1, ProtoMinor:1, Header:http.Header{\"Accept\":[]string{\"application/json, */*\"}, \"Accept-Encoding\":[]string{\"gzip\"}, \"Content-Length\":[]string{\"6089\"}, \"Content-Type\":[]string{\"application/json\"}, \"User-Agent\":[]string{\"kube-apiserver-admission\"}}, Body:(*http.body)(0xc000a51780), GetBody:(func() (io.ReadCloser, error))(nil), ContentLength:6089, TransferEncoding:[]string(nil), Close:false, Host:\"workspace-webhook-svc.kube-system.svc:9443\", Form:url.Values(nil), PostForm:url.Values(nil), MultipartForm:(*multipart.Form)(nil), Trailer:http.Header(nil), RemoteAddr:\"10.244.0.12:59116\", RequestURI:\"/validate/workspace.kaito.sh?timeout=10s\", TLS:(*tls.ConnectionState)(0xc000027130), Cancel:(<-chan struct {})(nil), Response:(*http.Response)(nil), ctx:(*context.cancelCtx)(0xc0003cc6e0)}"}
I0405 18:34:18.327287       1 workspace_validation.go:42] "Validate update" workspace="default/workspace-falcon-7b-instruct"
{"severity":"INFO","timestamp":"2024-04-05T18:34:18.327320726Z","logger":"webhook","caller":"webhook/admission.go:151","message":"remote admission controller audit annotations=map[string]string(nil)","knative.dev/kind":"kaito.sh/v1alpha1, Kind=Workspace","knative.dev/namespace":"default","knative.dev/name":"workspace-falcon-7b-instruct","knative.dev/operation":"UPDATE","knative.dev/resource":"kaito.sh/v1alpha1, Resource=workspaces","knative.dev/subresource":"status","knative.dev/userinfo":"system:serviceaccount:kube-system:kaito-workspace","admissionreview/uid":"511f4eae-fa27-4308-aeb0-e709b00ae6bc","admissionreview/allowed":true,"admissionreview/result":"nil"}
I0405 18:34:18.771322       1 resources.go:24] "CreateService" service="default/workspace-falcon-7b-instruct"
I0405 18:34:19.119558       1 resources.go:20] "CreateDeployment" deployment="default/workspace-falcon-7b-instruct"

kubectl logs -n kube-system kaito-gpu-provisioner-774556d85c-2npps
{"level":"INFO","time":"2024-04-05T18:29:58.983Z","logger":"controller","message":"Create","machine":{"name":"wsb42f9cb5f"}}
{"level":"INFO","time":"2024-04-05T18:29:58.983Z","logger":"controller","message":"Instance.Create","machine":{"name":"wsb42f9cb5f"}}
{"level":"INFO","time":"2024-04-05T18:29:58.983Z","logger":"controller","message":"createAgentPool","agentpool":"wsb42f9cb5f"}
{"level":"INFO","time":"2024-04-05T18:34:16.533Z","logger":"controller.machine.lifecycle","message":"launched machine","machine":"wsb42f9cb5f","provisioner":"default","provider-id":"azure:///subscriptions/8d99b0de-7ea1-4a2b-8fd0-c2ef9f25c5dc/resourceGroups/mc_rgai_aks_eastus/providers/Microsoft.Compute/virtualMachineScaleSets/aks-wsb42f9cb5f-41071934-vmss/virtualMachines/0","instance-type":"","zone":"","capacity-type":"","allocatable":null}

kubectl get svc
NAME                           TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)            AGE
kubernetes                     ClusterIP   10.0.0.1      <none>        443/TCP            126m
workspace-falcon-7b-instruct   ClusterIP   10.0.154.72   <none>        80/TCP,29500/TCP   17m

kubectl get deploy
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
workspace-falcon-7b-instruct   1/1     1            1           17m

kubectl describe po workspace-falcon-7b-instruct-7d757d9588-78zxm | grep Image:
    Image:         mcr.microsoft.com/aks/kaito/kaito-falcon-7b-instruct:0.0.2
```

- https://learn.microsoft.com/en-us/azure/aks/ai-toolchain-operator#deploy-a-default-hosted-ai-model

## Kaito model repository

You can check out how to use the AI models that Kaito hosts by default on [this](https://github.com/Azure/kaito#usage) link. 

If you want to add a new model to the Kaito repo, follow [these](https://github.com/Azure/kaito/blob/main/docs/How-to-add-new-models.md) steps. Kaito lets you [host large model images in the public](https://github.com/Azure/kaito) MCR from Microsoft if the license allows. The [model image](https://github.com/Azure/kaito/blob/main/docs/How-to-add-new-models.md#step-3-push-model-image-to-mcr) is pushed to the registry, and the requestor can [register the model with preset configurations](https://github.com/Azure/kaito/blob/main/docs/How-to-add-new-models.md#step-4-add-preset-configurations).

- https://learn.microsoft.com/en-us/azure/aks/ai-toolchain-operator#deploy-a-default-hosted-ai-model

## Initial state

```
kubectl logs -n kube-system kaito-workspace-6bf49b98cb-z5k2b
2024-04-05T18:15:15Z    INFO    controller-runtime.metrics      Metrics server is starting to listen    {"addr": ":8080"}
I0405 18:15:15.391620       1 main.go:122] "starting webhook reconcilers"
2024/04/05 18:15:15 Registering 1 clients
2024/04/05 18:15:15 Registering 2 informer factories
2024/04/05 18:15:15 Registering 2 informers
2024/04/05 18:15:15 Registering 2 controllers
{"severity":"INFO","timestamp":"2024-04-05T18:15:15.410660846Z","caller":"logging/config.go:80","message":"Unable to read vcs.revision from binary"}
{"severity":"INFO","timestamp":"2024-04-05T18:15:15.410726646Z","logger":"webhook","caller":"profiling/server.go:65","message":"Profiling enabled: false"}
{"severity":"INFO","timestamp":"2024-04-05T18:15:15.437938262Z","logger":"webhook","caller":"sharedmain/main.go:283","message":"Starting configuration manager..."}
{"level":"info","ts":1712340915.5412657,"logger":"fallback","caller":"injection/injection.go:63","msg":"Starting informers..."}
{"severity":"INFO","timestamp":"2024-04-05T18:15:15.742231558Z","logger":"webhook","caller":"webhook/webhook.go:218","message":"Informers have been synced, unblocking admission webhooks."}
{"severity":"INFO","timestamp":"2024-04-05T18:15:15.742356559Z","logger":"webhook","caller":"sharedmain/main.go:311","message":"Starting controllers..."}
{"severity":"INFO","timestamp":"2024-04-05T18:15:15.742433559Z","logger":"webhook.ValidationWebhook","caller":"controller/controller.go:486","message":"Starting controller and workers"}
{"severity":"INFO","timestamp":"2024-04-05T18:15:15.742449759Z","logger":"webhook.ValidationWebhook","caller":"controller/controller.go:496","message":"Started workers"}
{"severity":"INFO","timestamp":"2024-04-05T18:15:15.743003662Z","logger":"webhook.WebhookCertificates","caller":"controller/controller.go:486","message":"Starting controller and workers"}
{"severity":"INFO","timestamp":"2024-04-05T18:15:15.743026962Z","logger":"webhook.WebhookCertificates","caller":"controller/controller.go:496","message":"Started workers"}
{"severity":"INFO","timestamp":"2024-04-05T18:15:15.743293863Z","logger":"webhook.WebhookCertificates","caller":"controller/controller.go:550","message":"Reconcile succeeded","knative.dev/traceid":"aa95a4e6-239f-4347-b240-97bcbb65f090","knative.dev/key":"kube-system/workspace-webhook-cert","duration":"247.101µs"}
{"severity":"INFO","timestamp":"2024-04-05T18:15:15.786868348Z","logger":"webhook.ValidationWebhook","caller":"validation/reconcile_config.go:228","message":"Updating webhook","knative.dev/traceid":"61720425-1aba-4bf0-92bc-9887af676642","knative.dev/key":"validation.workspace.kaito.sh"}
{"severity":"INFO","timestamp":"2024-04-05T18:15:15.794463681Z","logger":"webhook.ValidationWebhook","caller":"validation/reconcile_config.go:228","message":"Updating webhook","knative.dev/traceid":"50c19f20-71b1-4f91-9d94-b9585ed89d03","knative.dev/key":"kube-system/workspace-webhook-cert"}
{"severity":"INFO","timestamp":"2024-04-05T18:15:15.795217784Z","logger":"webhook.ValidationWebhook","caller":"controller/controller.go:550","message":"Reconcile succeeded","knative.dev/traceid":"61720425-1aba-4bf0-92bc-9887af676642","knative.dev/key":"validation.workspace.kaito.sh","duration":"52.737525ms"}
{"severity":"INFO","timestamp":"2024-04-05T18:15:15.80136151Z","logger":"webhook.ValidationWebhook","caller":"controller/controller.go:550","message":"Reconcile succeeded","knative.dev/traceid":"50c19f20-71b1-4f91-9d94-b9585ed89d03","knative.dev/key":"kube-system/workspace-webhook-cert","duration":"58.002747ms"}
I0405 18:15:17.392660       1 main.go:142] "starting manager"
2024-04-05T18:15:17Z    INFO    Starting server {"kind": "health probe", "addr": "[::]:8081"}
2024-04-05T18:15:17Z    INFO    starting server {"path": "/metrics", "kind": "metrics", "addr": "[::]:8080"}
2024-04-05T18:15:17Z    INFO    Starting EventSource    {"controller": "workspace", "controllerGroup": "kaito.sh", "controllerKind": "Workspace", "source": "kind source: *v1alpha1.Workspace"}
2024-04-05T18:15:17Z    INFO    Starting EventSource    {"controller": "workspace", "controllerGroup": "kaito.sh", "controllerKind": "Workspace", "source": "kind source: *v1.Deployment"}
2024-04-05T18:15:17Z    INFO    Starting EventSource    {"controller": "workspace", "controllerGroup": "kaito.sh", "controllerKind": "Workspace", "source": "kind source: *v1.StatefulSet"}
2024-04-05T18:15:17Z    INFO    Starting EventSource    {"controller": "workspace", "controllerGroup": "kaito.sh", "controllerKind": "Workspace", "source": "kind source: *v1alpha5.Machine"}
2024-04-05T18:15:17Z    INFO    Starting Controller     {"controller": "workspace", "controllerGroup": "kaito.sh", "controllerKind": "Workspace"}
2024-04-05T18:15:17Z    INFO    Starting workers        {"controller": "workspace", "controllerGroup": "kaito.sh", "controllerKind": "Workspace", "worker count": 5}

kubectl logs -n kube-system kaito-gpu-provisioner-774556d85c-2npps
{"level":"INFO","time":"2024-04-05T18:15:17.578Z","message":"Unable to read vcs.revision from binary"}
{"level":"INFO","time":"2024-04-05T18:15:20.319Z","logger":"controller","message":"Starting server","path":"/metrics","kind":"metrics","addr":"[::]:8000"}
{"level":"INFO","time":"2024-04-05T18:15:20.320Z","logger":"controller","message":"Starting server","kind":"health probe","addr":"[::]:8081"}
{"level":"INFO","time":"2024-04-05T18:15:20.325Z","message":"Unable to read vcs.revision from binary"}
{"level":"INFO","time":"2024-04-05T18:15:20.325Z","logger":"webhook","message":"Profiling enabled: false"}
{"level":"INFO","time":"2024-04-05T18:15:20.352Z","logger":"webhook","message":"Starting configuration manager..."}
{"level":"INFO","time":"2024-04-05T18:15:20.421Z","logger":"controller","message":"Starting EventSource","controller":"termination","controllerGroup":"","controllerKind":"Node","source":"kind source: *v1.Node"}
{"level":"INFO","time":"2024-04-05T18:15:20.421Z","logger":"controller","message":"Starting Controller","controller":"termination","controllerGroup":"","controllerKind":"Node"}
{"level":"INFO","time":"2024-04-05T18:15:20.421Z","logger":"controller","message":"Starting workers","controller":"termination","controllerGroup":"","controllerKind":"Node","worker count":100}
{"level":"INFO","time":"2024-04-05T18:15:20.421Z","logger":"controller","message":"Starting EventSource","controller":"machine.lifecycle","controllerGroup":"karpenter.sh","controllerKind":"Machine","source":"kind source: *v1alpha5.Machine"}
{"level":"INFO","time":"2024-04-05T18:15:20.422Z","logger":"controller","message":"Starting EventSource","controller":"machine.lifecycle","controllerGroup":"karpenter.sh","controllerKind":"Machine","source":"kind source: *v1.Node"}
{"level":"INFO","time":"2024-04-05T18:15:20.422Z","logger":"controller","message":"Starting Controller","controller":"machine.lifecycle","controllerGroup":"karpenter.sh","controllerKind":"Machine"}
{"level":"INFO","time":"2024-04-05T18:15:20.422Z","logger":"controller","message":"Starting EventSource","controller":"consistency","controllerGroup":"karpenter.sh","controllerKind":"Machine","source":"kind source: *v1alpha5.Machine"}
{"level":"INFO","time":"2024-04-05T18:15:20.422Z","logger":"controller","message":"Starting EventSource","controller":"consistency","controllerGroup":"karpenter.sh","controllerKind":"Machine","source":"kind source: *v1.Node"}
{"level":"INFO","time":"2024-04-05T18:15:20.422Z","logger":"controller","message":"Starting Controller","controller":"consistency","controllerGroup":"karpenter.sh","controllerKind":"Machine"}
{"level":"INFO","time":"2024-04-05T18:15:20.422Z","logger":"controller","message":"Starting EventSource","controller":"machine.termination","controllerGroup":"karpenter.sh","controllerKind":"Machine","source":"kind source: *v1alpha5.Machine"}
{"level":"INFO","time":"2024-04-05T18:15:20.422Z","logger":"controller","message":"Starting EventSource","controller":"machine.termination","controllerGroup":"karpenter.sh","controllerKind":"Machine","source":"kind source: *v1.Node"}
{"level":"INFO","time":"2024-04-05T18:15:20.422Z","logger":"controller","message":"Starting Controller","controller":"machine.termination","controllerGroup":"karpenter.sh","controllerKind":"Machine"}
{"level":"INFO","time":"2024-04-05T18:15:20.422Z","logger":"controller","message":"Starting workers","controller":"machine.lifecycle","controllerGroup":"karpenter.sh","controllerKind":"Machine","worker count":1000}
{"level":"INFO","time":"2024-04-05T18:15:20.424Z","logger":"controller","message":"Starting workers","controller":"consistency","controllerGroup":"karpenter.sh","controllerKind":"Machine","worker count":10}
{"level":"INFO","time":"2024-04-05T18:15:20.424Z","logger":"controller.machine.garbagecollection","message":"starting controller"}
{"level":"INFO","time":"2024-04-05T18:15:20.425Z","logger":"controller","message":"Starting workers","controller":"machine.termination","controllerGroup":"karpenter.sh","controllerKind":"Machine","worker count":100}
{"level":"INFO","time":"2024-04-05T18:15:20.425Z","logger":"controller","message":"Starting EventSource","controller":"machine.disruption","controllerGroup":"karpenter.sh","controllerKind":"Machine","source":"kind source: *v1alpha5.Machine"}
{"level":"INFO","time":"2024-04-05T18:15:20.425Z","logger":"controller","message":"Starting EventSource","controller":"machine.disruption","controllerGroup":"karpenter.sh","controllerKind":"Machine","source":"kind source: *v1.Node"}
{"level":"INFO","time":"2024-04-05T18:15:20.425Z","logger":"controller","message":"Starting EventSource","controller":"machine.disruption","controllerGroup":"karpenter.sh","controllerKind":"Machine","source":"kind source: *v1.Pod"}
{"level":"INFO","time":"2024-04-05T18:15:20.425Z","logger":"controller","message":"Starting Controller","controller":"machine.disruption","controllerGroup":"karpenter.sh","controllerKind":"Machine"}
{"level":"INFO","time":"2024-04-05T18:15:20.425Z","logger":"controller","message":"Starting workers","controller":"machine.disruption","controllerGroup":"karpenter.sh","controllerKind":"Machine","worker count":10}
{"level":"INFO","time":"2024-04-05T18:15:20.453Z","logger":"controller","message":"Starting informers..."}
{"level":"INFO","time":"2024-04-05T18:15:20.453Z","logger":"webhook","message":"Starting controllers..."}
{"level":"INFO","time":"2024-04-05T18:15:21.473Z","logger":"controller.pricing","message":"updated on-demand pricing for region eastus","instance-type-count":1021}
```

## Workspace controller auto reconcile

```
kubectl logs -n kube-system kaito-workspace-6bf49b98cb-z5k2b
I0405 19:15:16.795031       1 workspace_controller.go:60] "Reconciling" workspace="default/workspace-falcon-7b-instruct"
I0405 19:15:16.795202       1 workspace_controller.go:457] "An inference workload already exists for workspace" workspace="default/workspace-falcon-7b-instruct"
I0405 19:15:17.795958       1 resources.go:71] "deployment status is ready" deployment="workspace-falcon-7b-instruct"
```

## Cleanup

```
kubectl delete workspace workspace-falcon-7b-instruct
workspace.kaito.sh "workspace-falcon-7b-instruct" deleted

kubectl get svc,deploy,workspace,machines
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.0.0.1     <none>        443/TCP   152m

kubectl logs -n kube-system kaito-workspace-6bf49b98cb-z5k2b
I0405 19:16:09.310152       1 workspace_controller.go:132] "deleteWorkspace" workspace="default/workspace-falcon-7b-instruct"
I0405 19:16:09.310174       1 workspace_gc_finalizer.go:19] "garbageCollectWorkspace" workspace="default/workspace-falcon-7b-instruct"
{"severity":"INFO","timestamp":"2024-04-05T19:16:09.324203258Z","logger":"webhook","caller":"webhook/admission.go:93","message":"Webhook ServeHTTP request=&http.Request{Method:\"POST\", URL:(*url.URL)(0xc000a378c0), Proto:\"HTTP/1.1\", ProtoMajor:1, ProtoMinor:1, Header:http.Header{\"Accept\":[]string{\"application/json, */*\"}, \"Accept-Encoding\":[]string{\"gzip\"}, \"Content-Length\":[]string{\"6694\"}, \"Content-Type\":[]string{\"application/json\"}, \"User-Agent\":[]string{\"kube-apiserver-admission\"}}, Body:(*http.body)(0xc000a7a300), GetBody:(func() (io.ReadCloser, error))(nil), ContentLength:6694, TransferEncoding:[]string(nil), Close:false, Host:\"workspace-webhook-svc.kube-system.svc:9443\", Form:url.Values(nil), PostForm:url.Values(nil), MultipartForm:(*multipart.Form)(nil), Trailer:http.Header(nil), RemoteAddr:\"10.244.0.12:46190\", RequestURI:\"/validate/workspace.kaito.sh?timeout=10s\", TLS:(*tls.ConnectionState)(0xc000026fd0), Cancel:(<-chan struct {})(nil), Response:(*http.Response)(nil), ctx:(*context.cancelCtx)(0xc000b657c0)}"}
I0405 19:16:09.324870       1 workspace_validation.go:42] "Validate update" workspace="default/workspace-falcon-7b-instruct"
{"severity":"INFO","timestamp":"2024-04-05T19:16:09.324899461Z","logger":"webhook","caller":"webhook/admission.go:151","message":"remote admission controller audit annotations=map[string]string(nil)","knative.dev/kind":"kaito.sh/v1alpha1, Kind=Workspace","knative.dev/namespace":"default","knative.dev/name":"workspace-falcon-7b-instruct","knative.dev/operation":"UPDATE","knative.dev/resource":"kaito.sh/v1alpha1, Resource=workspaces","knative.dev/subresource":"","knative.dev/userinfo":"system:serviceaccount:kube-system:kaito-workspace","admissionreview/uid":"64edb4dd-fd84-4085-b56b-e36d2799a51a","admissionreview/allowed":true,"admissionreview/result":"nil"}
I0405 19:16:09.334602       1 workspace_gc_finalizer.go:40] "successfully removed the workspace finalizers" workspace="default/workspace-falcon-7b-instruct"

kubectl logs -n kube-system kaito-gpu-provisioner-774556d85c-2npps | tail
{"level":"INFO","time":"2024-04-05T19:16:36.269Z","logger":"controller","message":"Get","providerID":"azure:///subscriptions/8d99b0de-7ea1-4a2b-8fd0-c2ef9f25c5dc/resourceGroups/mc_rgai_aks_eastus/providers/Microsoft.Compute/virtualMachineScaleSets/aks-wsb42f9cb5f-41071934-vmss/virtualMachines/0"}
{"level":"INFO","time":"2024-04-05T19:16:38.294Z","logger":"controller","message":"Get","providerID":"azure:///subscriptions/8d99b0de-7ea1-4a2b-8fd0-c2ef9f25c5dc/resourceGroups/mc_rgai_aks_eastus/providers/Microsoft.Compute/virtualMachineScaleSets/aks-wsb42f9cb5f-41071934-vmss/virtualMachines/0"}
{"level":"INFO","time":"2024-04-05T19:16:39.773Z","logger":"controller","message":"Delete","machine":{"name":"aks-wsb42f9cb5f-41071934-vmss000000"}}
{"level":"INFO","time":"2024-04-05T19:16:39.773Z","logger":"controller","message":"Instance.Delete","id":"azure:///subscriptions/8d99b0de-7ea1-4a2b-8fd0-c2ef9f25c5dc/resourceGroups/mc_rgai_aks_eastus/providers/Microsoft.Compute/virtualMachineScaleSets/aks-wsb42f9cb5f-41071934-vmss/virtualMachines/0"}
{"level":"INFO","time":"2024-04-05T19:16:39.774Z","logger":"controller","message":"deleteAgentPool","agentpool":"wsb42f9cb5f"}
{"level":"INFO","time":"2024-04-05T19:17:12.377Z","logger":"controller","message":"Delete","machine":{"name":"wsb42f9cb5f"}}
{"level":"INFO","time":"2024-04-05T19:17:12.378Z","logger":"controller","message":"Instance.Delete","id":"azure:///subscriptions/8d99b0de-7ea1-4a2b-8fd0-c2ef9f25c5dc/resourceGroups/mc_rgai_aks_eastus/providers/Microsoft.Compute/virtualMachineScaleSets/aks-wsb42f9cb5f-41071934-vmss/virtualMachines/0"}
{"level":"INFO","time":"2024-04-05T19:17:12.377Z","logger":"controller.termination","message":"deleted node","node":"aks-wsb42f9cb5f-41071934-vmss000000"}
{"level":"INFO","time":"2024-04-05T19:17:12.378Z","logger":"controller","message":"deleteAgentPool","agentpool":"wsb42f9cb5f"}
{"level":"INFO","time":"2024-04-05T19:17:13.227Z","logger":"controller.machine.termination","message":"deleted machine","machine":"wsb42f9cb5f","node":"aks-wsb42f9cb5f-41071934-vmss000000","provisioner":"default","provider-id":"azure:///subscriptions/8d99b0de-7ea1-4a2b-8fd0-c2ef9f25c5dc/resourceGroups/mc_rgai_aks_eastus/providers/Microsoft.Compute/virtualMachineScaleSets/aks-wsb42f9cb5f-41071934-vmss/virtualMachines/0"}
```

## Resources

```
kubectl api-resources | grep -e kaito -e karp
NAME                                SHORTNAMES          APIVERSION                             NAMESPACED   KIND
workspaces                          wk,wks              kaito.sh/v1alpha1                      true         Workspace
machines                                                karpenter.sh/v1alpha5                  false        Machine

kubectl get deployment -n kube-system | grep kaito
kaito-gpu-provisioner   1/1     1            1           79s
kaito-workspace         1/1     1            1           79s

kubectl get ds -n kube-system | grep kaito
NAME                                   DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
kaito-nvidia-device-plugin-daemonset   0         0         0       0            0           <none>          79s

kubectl get workspace,machine
No resources found
```

## References

- https://github.com/Azure/kaito
- https://github.com/Azure/kaito/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement
- https://azure.microsoft.com/en-us/updates/public-preview-kubernetes-ai-toolchain-operator-kaito-addon-for-aks/
- https://learn.microsoft.com/en-us/azure/aks/ai-toolchain-operator
