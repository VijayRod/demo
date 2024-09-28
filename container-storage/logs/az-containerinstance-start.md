```
rg=rgaci
dns="aci-demo$RANDOM"
az group create -g $rg -l $loc
az container create -g $rg --name mycontainer --image mcr.microsoft.com/azuredocs/aci-helloworld --dns-name-label $dns --ports 80
{
  "confidentialComputeProperties": null,
  "containers": [
    {
      "command": null,
      "environmentVariables": [],
      "image": "mcr.microsoft.com/azuredocs/aci-helloworld",
      "instanceView": {
        "currentState": {
          "detailStatus": "",
          "exitCode": null,
          "finishTime": null,
          "startTime": "2023-10-12T19:13:46.485000+00:00",
          "state": "Running"
        },
        "events": [
          {
            "count": 1,
            "firstTimestamp": "2023-10-12T19:13:37+00:00",
            "lastTimestamp": "2023-10-12T19:13:37+00:00",
            "message": "pulling image \"mcr.microsoft.com/azuredocs/aci-helloworld@sha256:565dba8ce20ca1a311c2d9485089d7ddc935dd50140510050345a1b0ea4ffa6e\"",
            "name": "Pulling",
            "type": "Normal"
          },
          {
            "count": 1,
            "firstTimestamp": "2023-10-12T19:13:38+00:00",
            "lastTimestamp": "2023-10-12T19:13:38+00:00",
            "message": "Successfully pulled image \"mcr.microsoft.com/azuredocs/aci-helloworld@sha256:565dba8ce20ca1a311c2d9485089d7ddc935dd50140510050345a1b0ea4ffa6e\"",
            "name": "Pulled",
            "type": "Normal"
          },
          {
            "count": 1,
            "firstTimestamp": "2023-10-12T19:13:46+00:00",
            "lastTimestamp": "2023-10-12T19:13:46+00:00",
            "message": "Started container",
            "name": "Started",
            "type": "Normal"
          }
        ],
        "previousState": null,
        "restartCount": 0
      },
```      
      
- https://learn.microsoft.com/en-us/azure/container-instances/container-instances-troubleshooting#container-takes-a-long-time-to-start
