# vs

```
# To add more components, you can use the Visual Studio Installer found in the Start Menu.
# To compile, simply open the .sln file and hit Start Debugging (F5).
```

- https://visualstudio.microsoft.com/vs/community/ (install)
- https://stackoverflow.com/questions/42964457/does-vscode-have-a-csproj-generator: Unfortunately VSCode doesn't have way to create/build solutions/projects targeting full .Net Framework however it does have support for projects targeting .Net Core. The new (VSCode) C# Dev Kit extension from Microsoft will create .sln and .csproj files for you.

# vs.debug

- https://learn.microsoft.com/en-us/dotnet/core/runtime-discovery/troubleshoot-app-launch

# vs.spec.project.copy

```
# Export Template - This includes the correct references for the new project name.
# Open the solution and go to the Project menu at the top, then choose Export Template. Type = 'Project Template' and pick the right source project. Then the name for the new template.
# You can find the template zip at C:\Users\userredacted\Documents\Visual Studio 2022\My Exported Templates. 
# To use the template, right-click on the Solution, select Add, then New Project, and either search for or select the template directly. This creates a new project with the given name.
# To build the project container image, choose the project from the dropdown next to the Docker button in the ribbon and then select the project in the Docker button dropdown.
# To publish the project image, simply right-click on the project within Solution Explorer, select Publish, and then click Publish once more.
```

- https://stackoverflow.com/questions/884255/visual-studio-copy-project
