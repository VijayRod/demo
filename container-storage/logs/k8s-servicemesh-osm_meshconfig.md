```
kubectl get meshconfig osm-mesh-config -n kube-system -o yaml

apiVersion: config.openservicemesh.io/v1alpha2
kind: MeshConfig
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"kind":"MeshConfig","apiVersion":"config.openservicemesh.io/configv1alpha2","metadata":{"name":"osm-mesh-config","creationTimestamp":null},"spec":{"sidecar":{"enablePrivilegedInitContainer":false,"logLevel":"error","configResyncInterval":"0s","resources":{},"localProxyMode":"Localhost"},"traffic":{"enableEgress":true,"outboundIPRangeExclusionList":[],"outboundIPRangeInclusionList":[],"outboundPortExclusionList":[],"inboundPortExclusionList":[],"enablePermissiveTrafficPolicyMode":true,"inboundExternalAuthorization":{"enable":false,"failureModeAllow":false},"networkInterfaceExclusionList":[]},"observability":{"osmLogLevel":"info","enableDebugServer":true,"tracing":{"enable":false}},"certificate":{"serviceCertValidityDuration":"24h","certKeyBitSize":2048},"featureFlags":{"enableWASMStats":true,"enableEgressPolicy":true,"enableSnapshotCacheMode":false,"enableAsyncProxyServiceMapping":false,"enableIngressBackendPolicy":true,"enableEnvoyActiveHealthChecks":false,"enableRetryPolicy":false}}}
  creationTimestamp: "2023-08-30T22:35:56Z"
  generation: 1
  name: osm-mesh-config
  namespace: kube-system
  resourceVersion: "1433"
  uid: 2z5d04ef-d717-4c8b-870d-e4badefae396
spec:
  certificate:
    certKeyBitSize: 2048
    serviceCertValidityDuration: 24h
  featureFlags:
    enableAsyncProxyServiceMapping: false
    enableEgressPolicy: true
    enableEnvoyActiveHealthChecks: false
    enableIngressBackendPolicy: true
    enableRetryPolicy: false
    enableSnapshotCacheMode: false
    enableWASMStats: true
  observability:
    enableDebugServer: true
    osmLogLevel: info
    tracing:
      enable: false
  sidecar:
    configResyncInterval: 0s
    enablePrivilegedInitContainer: false
    localProxyMode: Localhost
    logLevel: error
    resources: {}
    tlsMaxProtocolVersion: TLSv1_3
    tlsMinProtocolVersion: TLSv1_2
  traffic:
    enableEgress: true
    enablePermissiveTrafficPolicyMode: true
    inboundExternalAuthorization:
      enable: false
      failureModeAllow: false
      statPrefix: inboundExtAuthz
      timeout: 1s
    inboundPortExclusionList: []
    networkInterfaceExclusionList: []
    outboundIPRangeExclusionList: []
    outboundIPRangeInclusionList: []
    outboundPortExclusionList: []
    
kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"sidecar":{"httpIdleTimeout":900}}}'  --type=merge
```
