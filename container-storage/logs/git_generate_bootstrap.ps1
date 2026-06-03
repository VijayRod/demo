```
./git_generate_bootstrap.ps1 # generate script to clone/update nested repos in C:\git
./git_clone_repos.ps1 # rerun anytime to update or clone repos as needed
```

```
$root = "C:\git"
$output = "C:\git\git_clone_repos.ps1"

$lines = @()

$lines += '$ErrorActionPreference = "Continue"'
$lines += ''

Get-ChildItem $root -Recurse -Directory -Force |
Where-Object { Test-Path "$($_.FullName)\.git" } |
ForEach-Object {

    $repoPath = $_.FullName

    $remote = git -C $repoPath remote get-url origin 2>$null

    if ($LASTEXITCODE -eq 0 -and $remote) {

        $relative = $repoPath.Replace("$root\", "")

        $lines += "Write-Host ''"
        $lines += "Write-Host '=== $relative ===' -ForegroundColor Cyan"

        $lines += @"
if (Test-Path "C:\git\$relative\.git") {

    Write-Host "UPDATE: C:\git\$relative" -ForegroundColor Yellow

    try {
        git -C "C:\git\$relative" pull
    }
    catch {
        Write-Host "FAILED UPDATE: C:\git\$relative" -ForegroundColor Red
    }

} else {

    Write-Host "CLONE: C:\git\$relative" -ForegroundColor Green

    New-Item -ItemType Directory -Force -Path (Split-Path "C:\git\$relative") | Out-Null

    try {
        git clone "$remote" "C:\git\$relative"
    }
    catch {
        Write-Host "FAILED CLONE: C:\git\$relative" -ForegroundColor Red
    }
}
"@
    }
}
```
$lines | Set-Content $output

Write-Host "Generated: $output"
