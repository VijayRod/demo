## bash

- https://www.gnu.org/software/bash/manual/bash.html
- https://www.gnu.org/software/coreutils/manual/coreutils.html

## bash.spec.other.env

```
env # | grep PATH
```
- https://unix.stackexchange.com/questions/26047/how-to-correctly-add-a-path-to-path

## bash.spec.other.env.bash_profile

```
# cp ~/.bash_profile ~/.bash_profile-old # No such file or directory
echo 'cd /tmp' >> ~/.bash_profile
echo 'alias k=kubectl' >> ~/.bash_profile
echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bash_profile
echo 'loc=swedencentral; rg=rg; vmsize=Standard_B2ms; subId=redacted; tenantId="redacted"' >> ~/.bash_profile
echo 'echo $(date),$HOME,$loc,$rg,$vmsize,sub $subId,tenant $tenantId' >> ~/.bash_profile
echo 'k get no; k get po -A; k cluster-info | grep control' >> ~/.bash_profile
source ~/.bash_profile
cat ~/.bash_profile | tail -n 10
# vi ~/.bash_profile
```

## bash.spec.other.env.bashrc

```

```

- https://askubuntu.com/questions/127056/where-is-bashrc: don't create a .bashrc if it's just for this, create or modify ~/.bash_profile
- https://askubuntu.com/questions/121413/understanding-bashrc-and-bash-profile
- https://cloudzy.com/blog/linux-bashrc/
- https://www.digitalocean.com/community/tutorials/bashrc-file-in-linux

## bash.spec.other.env.profile

```
cat ~/.profile # This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
```

## bash.spec.other.loop.while

```
tbd redisProvisionState=Scaling; while [[ $redisProvisionState -eq "Scaling" ]]; do sleep 5; redisProvisionState=$(az redis show -g $rg -n $redis --query provisioningState -otsv); echo $(date) - $redisProvisionState; done
```

- https://stackoverflow.com/questions/1289026/syntax-for-a-single-line-while-loop-in-bash
- https://linuxhandbook.com/bash-while-loop/
