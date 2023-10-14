```
az container attach -g $rg --name mycontainer
Container 'mycontainer' is in state 'Running'...
(count: 1) (last timestamp: 2023-10-12 19:13:37+00:00) pulling image "mcr.microsoft.com/azuredocs/aci-helloworld@sha256:565dba8ce20ca1a311c2d9485089d7ddc935dd50140510050345a1b0ea4ffa6e"
(count: 1) (last timestamp: 2023-10-12 19:13:38+00:00) Successfully pulled image "mcr.microsoft.com/azuredocs/aci-helloworld@sha256:565dba8ce20ca1a311c2d9485089d7ddc935dd50140510050345a1b0ea4ffa6e"
(count: 1) (last timestamp: 2023-10-12 19:13:46+00:00) Started container
Start streaming logs:
listening on port 80
::ffff:10.92.0.11 - - [12/Oct/2023:19:15:30 +0000] "HEAD / HTTP/1.1" 200 1663 "-" "curl/7.68.0"
::ffff:10.92.0.11 - - [12/Oct/2023:19:15:34 +0000] "GET / HTTP/1.1" 200 1663 "-" "Mozilla/5.0 (Windows NT 10.0) Appl
```

```
az container attach -g $rg --name mycontainer
::ffff:10.92.0.11 - - [12/Oct/2023:19:16:06 +0000] "GET / HTTP/1.1" 200 1663 "-" "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36"
# curl -I aci-demo1012.eastus.azurecontainer.io
```

- https://learn.microsoft.com/en-us/azure/container-instances/container-instances-quickstart#attach-output-streams
