## wsl

```
# Execute in a cmd prompt. Or Start menu: wsl
# Start menu: Ubuntu # after wsl --install

wsl --help

wsl -v
WSL version: 2.3.24.0
Kernel version: 5.15.153.1-2
WSLg version: 1.0.65
MSRDC version: 1.2.5620
Direct3D version: 1.611.1-81528511
DXCore version: 10.0.26100.1-240331-1435.ge-release
Windows version: 10.0.26100.2033

wsl -l -v
  NAME                   STATE           VERSION
* Ubuntu                 Running         2
  docker-desktop-data    Stopped         2
  
wsl --status
Default Distribution: Ubuntu
Default Version: 2

wslconfig /l
Windows Subsystem for Linux Distributions:
Ubuntu (Default)
docker-desktop-data

wsl --system -e cat /etc/issue # Welcome to CBL-Mariner 2.0.n (x86_64) - Kernel \r (\l)

wsl.exe --list --online # Displays a list of available distributions for install with 'wsl.exe --install'

# home directory
\\wsl.localhost\ # Or \\wsl$
\\wsl.localhost\Ubuntu\tmp
\\wsl.localhost\Ubuntu\home\userredacted
# https://superuser.com/questions/1791373/location-of-wsl-home-directory-in-windows

# install
wsl --unregister Ubuntu # unregister and uninstall a WSL distribution
wsl --uninstall
wsl --update
wsl --install # Install WSL and the default Ubuntu distribution of Linux

# restart
# wsl --shutdown. If WSL is unresponsive, follow these steps:
sc.exe queryex LxssManager
sc.exe stop LxssManager
sc.exe start LxssManager
sc.exe queryex LxssManager
```
  
-- https://learn.microsoft.com/en-us/windows/wsl/basic-commands

## wsl.debug

- https://askubuntu.com/questions/1379425/system-has-not-been-booted-with-systemd-as-init-system-pid-1-cant-operate
  
## wsl.os.mariner

- https://github.com/microsoft/azurelinux/issues/1159: WSL now includes a CBL-Mariner by default... question is about to the availability of Mariner in the list of supported distribution for WSL, including from the online store : wsl --list --online... Mariner does not officially support WSL at this time.
