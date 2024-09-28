```
az container logs -g $rg --name mycontainer
listening on port 80
```

```
curl -I aci-demo1012.eastus.azurecontainer.io
HTTP/1.1 200 OK

az container logs -g $rg --name mycontainer
listening on port 80
::ffff:10.92.0.11 - - [12/Oct/2023:19:15:30 +0000] "HEAD / HTTP/1.1" 200 1663 "-" "curl/7.68.0"
::ffff:10.92.0.11 - - [12/Oct/2023:19:15:34 +0000] "GET / HTTP/1.1" 200 1663 "-" "Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36"
```

- https://learn.microsoft.com/en-us/azure/container-instances/container-instances-quickstart#pull-the-container-logs
