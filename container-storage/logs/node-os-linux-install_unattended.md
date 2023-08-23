```
# To show if unattended upgrades is configured
cat /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";

# To view the unattended upgrade settings, including the default installation of security updates. The contents of this file may vary depending on the specific system you are using
cat /etc/apt/apt.conf.d/50unattended-upgrades |grep -v //
Unattended-Upgrade::Allowed-Origins {
        "${distro_id}:${distro_codename}";
        "${distro_id}:${distro_codename}-security";
        "${distro_id}ESMApps:${distro_codename}-apps-security";
        "${distro_id}ESM:${distro_codename}-infra-security";
};
Unattended-Upgrade::Package-Blacklist {
};
Unattended-Upgrade::DevRelease "auto";

# To check whether unattended-upgrades are enabled and will install security critical updates automatically
unattended-upgrades -d
Running on the development release
Starting unattended upgrades script
Allowed origins are: o=Ubuntu,a=jammy, o=Ubuntu,a=jammy-security, o=UbuntuESMApps,a=jammy-apps-security, o=UbuntuESM,a=jammy-infra-security
Initial blacklist:
Initial whitelist (not strict):
Marking not allowed <apt_pkg.PackageFile object: filename:'/var/lib/apt/lists/packages.microsoft.com_ubuntu_22.04_prod_dists_jammy_main_binary-all_Packages'  a=jammy,c=main,v=,o=microsoft-ubuntu-jammy-prod jammy,l=microsoft-ubuntu-jammy-prod jammy arch='all' site='packages.microsoft.com' IndexType='Debian Package Index' Size=4013 ID:34> with -32768 pin

# To view recent events related to package management
tail /var/log/dpkg.log
```

- https://askubuntu.com/questions/916722/how-to-verify-that-unattended-upgrades-are-enabled
- https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster
