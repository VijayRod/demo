```
./git_pull_repos.ps1 # syncs nested repos in C:\git
```
```
Get-ChildItem C:\git -Recurse -Directory |
Where-Object { Test-Path "$($_.FullName)\.git" } |
ForEach-Object {
    git -C $_.FullName pull --ff-only
}
```
