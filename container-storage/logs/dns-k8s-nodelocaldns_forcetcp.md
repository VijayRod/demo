```
# node-local-dns utilizes the TCP protocol (force_tcp) to communicate with the CoreDNS service, ensuring effective load balancing.
```

- https://build.thebeat.co/yet-another-kubernetes-dns-latency-story-2a1c00ebbb8d: The “force_tcp” flag inside each zone’s configuration will force the local coreDNS to reach the upstream server of each zone using TCP protocol if it doesn’t have a fresh response in its cache.
