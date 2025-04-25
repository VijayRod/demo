## rest

- https://www.freecodecamp.org/news/rest-api-tutorial-rest-client-rest-service-and-api-calls-explained-with-code-examples/
- https://restfulapi.net/http-methods/
- https://restapitutorial.com/

### rest.api.app.examples

```
curl https://example.com/test.txt -v
> GET /test.txt HTTP/2
> Host: example.com
> user-agent: curl/7.68.0
> accept: */*

curl https://official-joke-api.appspot.com/random_joke -v
> GET /random_joke HTTP/2
> Host: official-joke-api.appspot.com
> user-agent: curl/7.68.0
> accept: */*

curl openai.com -v
> GET / HTTP/1.1
> Host: openai.com
> User-Agent: curl/7.68.0
> Accept: */*
```

- https://blog.postman.com/rest-api-examples/

### rest.api.app.examples.XMLHttpRequest

- https://www.peej.co.uk/articles/rich-user-experience.html: REST. XMLHttpRequest object to issue a HTTP GET request to the URL
- https://www.w3schools.com/js/js_json_http.asp: XMLHttpRequest
- https://www.w3schools.com/tags/ref_httpmethods.asp
- https://www.w3schools.com/xml/xml_http.asp
- https://www.w3schools.com/js/js_ajax_http.asp
- https://www.w3schools.com/xml/tryit.asp?filename=tryajax_first
- https://www.w3schools.com/xml/dom_http.asp: XMLHttpRequest
- https://www.w3schools.com/xml/ajax_xmlhttprequest_create.asp

### rest.api.app.doc.swagger

- https://stackify.com/rest-api-tutorial/
- https://editor.swagger.io/
- https://swagger.io/tools/swagger-ui/
  
## rest.api.app.bruno

```
# Windows, Bruno install

# app configuration
Mode = Developer Mode
Collection, Preferences, General = uncheck "SSL/TLS Certificate Verification"

# app usage
Create Collection, then proceed to create a New Request using GET https://example.com/test.txt, and then run it
```

- https://docs.usebruno.com/scripting/getting-started
- https://github.com/usebruno/bruno/: Bruno - Opensource IDE for exploring and testing APIs.

## rest.api.app.postman

- https://www.postman.com/downloads/
- https://www.postman.com/downloads/: Postman on the web (Try the Web Version), or simply sign in at https://www.postman.com/
- https://web.postman.co/templates/recommended: REST API basics, etc.

## rest.api.app.ResourceExplorer

```
# This includes both Read Only and Read/Write views.
```

- https://resources.azure.com/

## rest.api.app.ResourceExplorer.ResourceManager

```
# Azure portal: Resource Manager. Offers a view that is read-only.
```

## rest.api.arm.rp.contract *

- https://github.com/AzureExpert/azure-resource-manager-rpc/blob/master/v1.0/common-api-details.md

## rest.api.arm.rp.manifest

```
az provider show -n Microsoft.RedHatOpenShift
{
  "authorizations": [
    {
      "applicationId": "f1dd0a37-89c6-4e07-bcd1-ffd3d43d8875",
      "managedByAuthorization": {
        "allowManagedByInheritance": true
      },
      "managedByRoleDefinitionId": "9e3af657-a8ff-583c-a75c-2fe7c4bcb635",
      "roleDefinitionId": "640c5ac9-6f32-4891-94f4-d20f7aa9a7e6"
    }
  ],
  "id": "/subscriptions/redacts-1111-1111-1111-111111111111/providers/Microsoft.RedHatOpenShift",
  "namespace": "Microsoft.RedHatOpenShift",
  "providerAuthorizationConsentState": null,
  "registrationPolicy": "RegistrationRequired",
  "registrationState": "Registered",
  "resourceTypes": [
    {
...
```

## rest.api.azure.Microsoft.ContainerService (aks)

- https://learn.microsoft.com/en-us/rest/api/aks/
- https://github.com/Azure/azure-rest-api-specs/blob/main/specification/containerservice/resource-manager/Microsoft.ContainerService/aks/readme.md
