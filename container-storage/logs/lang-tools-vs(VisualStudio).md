## vs

```
# Install
# To add more components, you can use the Visual Studio Installer found in the Start Menu.

# Build
# It's best to first compile the project and run it locally using F5
# To compile, simply open the .sln file and hit Start Debugging (F5). 
```

- https://visualstudio.microsoft.com/vs/community/ (install)
- https://stackoverflow.com/questions/42964457/does-vscode-have-a-csproj-generator: Unfortunately VSCode doesn't have way to create/build solutions/projects targeting full .Net Framework however it does have support for projects targeting .Net Core. The new (VSCode) C# Dev Kit extension from Microsoft will create .sln and .csproj files for you.

## vs.app.console.container

```
# See the section on Dockerfile.build.VisualStudio.console.container
```

## vs.debug

- https://learn.microsoft.com/en-us/dotnet/core/runtime-discovery/troubleshoot-app-launch

## vs.spec.dependency.package.NuGet

```
# To add a package like StackExchange.Redis: Right-click the Solution for a solution-wide scope, or the Project for a specific project, or Packages within Project/Dependencies. Choose Browse, search for the package you need, and hit Install.
# View the installed package under Project/Dependencies/Packages.
# Include it in your cs file like this: using StackExchange.Redis;
```

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
