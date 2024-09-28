## wsl

```
# Execute in a cmd prompt
wsl --help
wsl -v
wsl --system -e cat /etc/issue # Welcome to CBL-Mariner 2.0.n (x86_64) - Kernel \r (\l)
wsl.exe --list --online # Displays a list of available distributions for install with 'wsl.exe --install'
```
  
-- https://learn.microsoft.com/en-us/windows/wsl/basic-commands

## wsl.os.mariner

- https://github.com/microsoft/azurelinux/issues/1159: WSL now includes a CBL-Mariner by default... question is about to the availability of Mariner in the list of supported distribution for WSL, including from the online store : wsl --list --online... Mariner does not officially support WSL at this time.
