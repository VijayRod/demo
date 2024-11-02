## vs

```
# To add more components, you can use the Visual Studio Installer found in the Start Menu.
# To compile, simply open the .sln file and hit Start Debugging (F5).
```

- https://visualstudio.microsoft.com/vs/community/ (install)
- https://stackoverflow.com/questions/42964457/does-vscode-have-a-csproj-generator: Unfortunately VSCode doesn't have way to create/build solutions/projects targeting full .Net Framework however it does have support for projects targeting .Net Core. The new (VSCode) C# Dev Kit extension from Microsoft will create .sln and .csproj files for you.

## vs.app.console.container

```
# Visual Studio, New Project, Console App (Enable container support, Container OS = Linux, Container build type = Dockerfile), Create
# Program.cs: Console.WriteLine(DateTimeOffset.UtcNow + ": Hello, World!");
# F5 # 11/02/2024 14:28:08 +00:00: Hello, World! The program 'dotnet' has exited with code 0 (0x0).
# Publish: For example. to an Azure Container Registry.

kubectl run consoleapp1 --image=registry13959.azurecr.io/consoleapp1:latest
sleep 5
k get po -owide # consoleapp1   0/1     Completed   2 (25s ago)   27s
k logs consoleapp1 -c consoleapp1 -f # 11/02/2024 14:24:36 +00:00: Hello, World!
```

## vs.app.console.container.Dockerfile

```
# The following lines are set up to run on a Linux container OS:
FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
```

- https://aka.ms/customizecontainer
- https://learn.microsoft.com/en-us/visualstudio/containers/container-build

## vs.app.console.container.dynamic

```
# In addition to environment variables, we can similarly process values through ConfigMaps and Secrets.
```

## vs.app.console.container.dynamic.envsubst

```
envsubst < deployment.yaml | kubectl apply -f -
```

- https://stackoverflow.com/questions/48296082/how-to-set-dynamic-values-with-kubernetes-yaml-file

## vs.debug

- https://learn.microsoft.com/en-us/dotnet/core/runtime-discovery/troubleshoot-app-launch

## vs.spec.project

- https://aka.ms/new-console-template
- https://learn.microsoft.com/en-us/dotnet/core/tutorials/top-level-templates

## vs.spec.project.copy.ExportTemplate

```
# This includes the correct references for the new project name.
# Open the solution and go to the Project menu at the top, then choose Export Template. Type = 'Project Template' and pick the right source project. Then the name for the new template.
# You can find the template zip at C:\Users\userredacted\Documents\Visual Studio 2022\My Exported Templates. 
# To use the template, right-click on the Solution, select Add, then New Project, and either search for or select the template directly. This creates a new project with the given name.
# To build the project, right-click on it and select either Build or Rebuild.

# This is reltaed to a container image project
# Ensure the Dockerfile in the project is correct as it's used for Publish. Right click the Dockerfile, Build Docker Image.
# To debug the project, choose it from the dropdown located in the top ribbon.
# To publish the project image, right-click on the project in Solution Explorer, choose Publish, and then click Publish again.
```

- https://stackoverflow.com/questions/884255/visual-studio-copy-project
