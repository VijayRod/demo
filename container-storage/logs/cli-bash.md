## bash

- https://www.gnu.org/software/bash/manual/bash.html
- https://www.gnu.org/software/coreutils/manual/coreutils.html

## bash.loop.while

```
tbd redisProvisionState=Scaling; while [[ $redisProvisionState -eq "Scaling" ]]; do sleep 5; redisProvisionState=$(az redis show -g $rg -n $redis --query provisioningState -otsv); echo $(date) - $redisProvisionState; done
```

- https://stackoverflow.com/questions/1289026/syntax-for-a-single-line-while-loop-in-bash
- https://linuxhandbook.com/bash-while-loop/
