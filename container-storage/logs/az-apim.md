```
rgname=testshack
loc=swedencentral
apim="myapim$RANDOM"

az group create -n $rgname -l $loc
az apim create -g $rgname -n $apim \
  --publisher-name Contoso --publisher-email admin@contoso.com \
  --no-wait ## 40 minutes to create and activate
```

```
az apim show -g $rgname -n $apim -o table

NAME         RESOURCE GROUP    LOCATION        GATEWAY ADDR    PUBLIC IP    PRIVATE IP    STATUS      TIER       UNITS
-----------  ----------------  --------------  --------------  -----------  ------------  ----------  ---------  -------
myapim23822  testshack         Sweden Central                                             Activating  Developer  1

NAME         RESOURCE GROUP    LOCATION        GATEWAY ADDR                       PUBLIC IP      PRIVATE IP    STATUS    TIER       UNITS
-----------  ----------------  --------------  ---------------------------------  -------------  ------------  --------  ---------  -------
myapim23822  testshack         Sweden Central  https://myapim23822.azure-api.net  20.240.31.100                Online    Developer  1

az group delete -n $rgname -y --no-wait
```

- https://learn.microsoft.com/en-us/azure/api-management/get-started-create-service-instance-cli
