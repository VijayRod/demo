## network.proxy

- https://stackoverflow.com/questions/10173096/how-proxy-server-works-with-tcp-http-connections: After processing the CONNECT command, a proxy just copies bytes in both directions. 
- https://stackoverflow.com/questions/48127953/difference-between-https-reverse-proxy-tcp-proxy-socks5-proxy

## network.proxy.http



## network.proxy.tcp


## network.proxy.tcp.k8s.konnectivity

- https://kubernetes.io/docs/tasks/extend-kubernetes/setup-konnectivity/
- https://kubernetes.io/docs/concepts/architecture/control-plane-node-communication/: Konnectivity service provides TCP level proxy for the control plane to cluster communication
- https://stackoverflow.com/questions/61706923/what-is-the-konnectivity-service-for-kubernetes: Konnectivity Server. The proxy server which runs in the master network. It has a secure channel established to the cluster network. It could work on either an HTTP Connect mechanism or gRPC. If the former it would use standard HTTP Connect. If the latter it would expose a gRPC interface to KAS to provide connectivity service. Formerly known the Network Proxy Server.
  - Konnectivity Agent. A proxy agent which runs in the node network for establishing the tunnel. Formerly known as the Network Proxy Agent.
- https://github.com/kubernetes/enhancements/tree/master/keps/sig-api-machinery/1281-network-proxy
  
## network.proxy.tls

- https://learn.microsoft.com/en-us/azure/application-gateway/tcp-tls-proxy-overview
