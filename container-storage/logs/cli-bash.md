## bash

- https://www.gnu.org/software/bash/manual/bash.html
- https://www.gnu.org/software/coreutils/manual/coreutils.html

## bash.spec.other.bashrc

```
# cp ~/.bashrc ~/.bashrc-old
echo 'rg=rg; loc=swedencentral; subId=redacted; tenantId="redacted"' >> ~/.bashrc
echo 'echo $(date),$HOME,$rg,$loc,sub $subId,tenant $tenantId' >> ~/.bashrc
echo 'cd /tmp' >> ~/.bashrc
echo 'alias k=kubectl' >> ~/.bashrc
source ~/.bashrc
cat .bashrc | tail -n 10
# vi ~/.bashrc
```

- https://askubuntu.com/questions/127056/where-is-bashrc: don't create a .bashrc if it's just for this, create or modify ~/.bash_profile
- https://askubuntu.com/questions/121413/understanding-bashrc-and-bash-profile
- https://cloudzy.com/blog/linux-bashrc/
- https://www.digitalocean.com/community/tutorials/bashrc-file-in-linux

## bash.spec.other.loop.while

```
tbd redisProvisionState=Scaling; while [[ $redisProvisionState -eq "Scaling" ]]; do sleep 5; redisProvisionState=$(az redis show -g $rg -n $redis --query provisioningState -otsv); echo $(date) - $redisProvisionState; done
```

- https://stackoverflow.com/questions/1289026/syntax-for-a-single-line-while-loop-in-bash
- https://linuxhandbook.com/bash-while-loop/
