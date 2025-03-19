- https://go.dev/ref/mod
- https://www.w3schools.com/go/index.php

```
# go(.Windows)

# Download the stable Go version for the OS from https://go.dev/dl/
# Install instructions at https://go.dev/doc/install
cmd: go version # go version go1.24.1 windows/amd64
VSCode (*restart after Go install), Terminal: go version
*Azure CloudShell: Go is already installed
```

- https://go.dev/dl/
- https://go.dev/doc/install

```
# go...debug
# Run go commands in the Terminal window in VS Code or in a Windows command prompt. Just make sure you are in the go project directory.
# Refer to the verbose sections for each command
go version
```

```
# go...debug.gctrace
# gctrace=1 enables garbage collection (GC) tracing. Higher values (e.g., gctrace=2 or more) have no effect—the Go runtime only checks if the value is non-zero.
bash: GODEBUG=gctrace=1 go run main.go
ps: $env:GODEBUG="gctrace=1"; go run main.go # Use $env:GODEBUG="gctrace=0" to reset
```

```
# go..build
go build -v . # Then run with "./your-binary-name" (without quotes)
```

```
# go..get.modulecache
# The go get command downloads modules to this OS module cache at /go/pkg/mod, and updates the SDK in the go.sum file in the project directory
# go get -v
Linux/macOS: ~/go/pkg/mod
Windows: C:\Users\<user>\go\pkg\mod # cd go/pkg/mod; dir go

## It took 30 minutes on a high=-speed connection, with most of the time spent on the second line, i.e., for the v68 download (although it only took a couple of seconds in Azure CloudShell)
go get github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/resources/armresources
go: downloading github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/resources/armresources v1.2.0
go: downloading github.com/Azure/azure-sdk-for-go v68.0.0+incompatible
go: downloading github.com/Azure/azure-sdk-for-go/sdk/azcore v1.9.0
go: downloading github.com/Azure/azure-sdk-for-go/sdk/internal v1.5.0
go: downloading golang.org/x/net v0.17.0
go: downloading golang.org/x/text v0.13.0
go: added github.com/Azure/azure-sdk-for-go/sdk/azcore v1.9.0
go: added github.com/Azure/azure-sdk-for-go/sdk/internal v1.5.0
go: added github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/resources/armresources v1.2.0
go: added golang.org/x/net v0.17.0
go: added golang.org/x/text v0.13.0

# go..get.error.no required module provides package
# Execute go get github.com/Azure/azure-sdk-for-go/sdk/azidentity
main.go:8:2: no required module provides package github.com/Azure/azure-sdk-for-go/sdk/azidentity: go.mod file not found in current directory or any parent directory; see 'go help modules'

# go..get.modulecache.clean.manual
Linux/macOS: go clean -modcache
Windows: rm -rf ~/go/pkg/mod/*
```

```
# go..run
# The -x flag prints the commands executed by go run
# Since go run compiles and runs the code, you can use go build -v
go run -x main.go
```

```
# go..test
go test -v ./...
```

```
# go.sdk.azure-sdk-for-go.sample

# Ensure Go is installed in the OS. Verify with the "go version" command, for example in a VSCode terminal window, or in Azure CloudShell (preferred).

# Install the Go extension in VS Code
https://marketplace.visualstudio.com/items?itemName=golang.go

# Install the Azure SDK for Go
# In VSCode, Terminal window. View the status in the Output window.
# *Alternatively, use Azure CloudShell (preferred)
md c:\git\goTest
cd c:\git\goTest
go mod init azure-go-test   # Inicializa um projeto Go. Adds a go.mod file in the current directory
go get github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/resources/armresources
go get github.com/Azure/azure-sdk-for-go/sdk/azidentity

# In VSCode, project directory, create a New File "main.go"
# Replace the subscription Id and optionally the resource group name and the location
# (tbd) In VSCode, Terminal window (wsl): az login (az login -t redactt --use-device-code); az account set --subscription redacts
# (tbd) In VSCode, Terminal window (PowerShell): Connect-AzAccount; go run main.go # DefaultAzureCredential: failed to acquire a token
# *In Azure CloudShell (upload the go file): go run main.go
package main

import (
	"context"
	"fmt"
	"log"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/resources/armresources"
)

func main() {
	// Definir a Subscription ID e o nome do Resource Group
	subscriptionID := "<SEU_SUBSCRIPTION_ID>"
	resourceGroupName := "MeuResourceGroup"
	location := "eastus" // Pode mudar para "westeurope", "brazilsouth", etc.

	// Criar credenciais para autenticação no Azure
	cred, err := azidentity.NewDefaultAzureCredential(nil)
	if err != nil {
		log.Fatalf("Erro ao obter credenciais: %v", err)
	}

	// Criar cliente para gerenciar grupos de recursos
	client, err := armresources.NewResourceGroupsClient(subscriptionID, cred, nil)
	if err != nil {
		log.Fatalf("Erro ao criar cliente: %v", err)
	}

	// Criar o Resource Group
	ctx := context.Background()
	_, err = client.CreateOrUpdate(ctx, resourceGroupName, armresources.ResourceGroup{
		Location: &location,
	}, nil)

	if err != nil {
		log.Fatalf("Erro ao criar Resource Group: %v", err)
	}

	fmt.Println("Resource Group criado com sucesso:", resourceGroupName)
}

# Execute the go file
go run main.go # Resource Group criado com sucesso: MeuResourceGroup
```

- https://marketplace.visualstudio.com/items?itemName=golang.go
- https://github.com/Azure/azure-sdk-for-go/tree/main?tab=readme-ov-file#packages-available: Each service can have both 'client' and 'management' modules. 'Client' modules are used to consume the service, whereas 'management' modules are used to configure and manage the service.
