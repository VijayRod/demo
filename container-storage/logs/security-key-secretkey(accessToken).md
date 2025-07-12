> ## azure-aifoundary

```
# Microsoft.CognitiveServices/accounts

rg=rg-core
az group create -n $rg -l $loc

foundry="foundry$RANDOM"; echo $foundry
cd /tmp
git clone https://github.com/Azure-AI-Foundry/foundry-samples
cd foundry-samples/samples/microsoft/infrastructure-setup/00-basic
az deployment group create -g $rg --template-file main.bicep --parameters aiFoundryName=$foundry aiProjectName=myAIProject location=$loc

# portal: https://portal.azure.com/#view/Microsoft_Azure_AI_Foundry, Resource Mgmt, Projects, select the project to access the Azure AI Foundry portal
# foundry portal: https://ai.azure.com/resource/playground, select the project, or alternatively you can choose an existing Azure OpenAI resource. The Overview section displays the endpoint.
```

- https://portal.azure.com/#view/Microsoft_Azure_AI_Foundry
  - https://ai.azure.com/resource/playground
- https://github.com/Azure-AI-Foundry/foundry-samples
  - https://github.com/azure-ai-foundry/foundry-samples/blob/main/samples/microsoft/infrastructure-setup/00-basic/main.bicep

```
# azure-aifoundary.key/aad
# foundry portal, project, Overview: "API key authentication is disabled", so use AAD (az account get-access-token) or enable api key authentication (Set-AzCognitiveServicesAccount -ResourceGroupName $rg -Name $foundary -DisableLocalAuth $true)

# project endpoints see in the Overview page:
## Azure AI Foundry project endpoint: https://foundry13889.services.ai.azure.com/api/projects/myAIProject
## Azure OpenAI endpoint: https://foundry13889.openai.azure.com/
## Azure AI Services endpoint: https://foundry13889.cognitiveservices.azure.com/; Speech to text endpoint: https://eastus2.stt.speech.microsoft.com; Text to speech endpoint: https://eastus2.tts.speech.microsoft.com

# foundry portal, project, Playgrounds: This section contains the Deployment names
```

```
# azure-aifoundary.aad.azure-openai

az login
az account set -s $subId
ACCESS_TOKEN=$(az account get-access-token --resource https://cognitiveservices.azure.com/ --query accessToken -o tsv); echo $ACCESS_TOKEN

# deployment=gpt-4o; echo $foundry $deployment
curl -X POST "https://foundry13889.openai.azure.com/openai/deployments/gpt-4o/chat/completions?api-version=2024-06-01" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "Hello, can you help me?"}
    ],
    "max_tokens": 100,
    "temperature": 0.7
  }'

{"choices":[{"content_filter_results":{"hate":{"filtered":false,"severity":"safe"},"self_harm":{"filtered":false,"severity":"safe"},"sexual":{"filtered":false,"severity":"safe"},"violence":{"filtered":false,"severity":"safe"}},"finish_reason":"stop","index":0,"logprobs":null,"message":{"annotations":[],"content":"Of course! I'm here to help. What do you need assistance with?","refusal":null,"role":"assistant"}}],"created":1751467085,"id":"chatcmpl-redacted11111","model":"gpt-4o-2024-08-06","object":"chat.completion","prompt_filter_results":[{"prompt_index":0,"content_filter_results":{"hate":{"filtered":false,"severity":"safe"},"self_harm":{"filtered":false,"severity":"safe"},"sexual":{"filtered":false,"severity":"safe"},"violence":{"filtered":false,"severity":"safe"}}}],"system_fingerprint":"fp_ab9114d383","usage":{"completion_tokens":16,"completion_tokens_details":{"accepted_prediction_tokens":0,"audio_tokens":0,"reasoning_tokens":0,"rejected_prediction_tokens":0},"prompt_tokens":24,"prompt_tokens_details":{"audio_tokens":0,"cached_tokens":0},"total_tokens":40}}
```

> ## azure-openai

```
# azur-eopenai..env

# portal, Azure OpenAI
# portal 2 is the Azure AI Foundry portal

rg="rg-core"; name="gptstack-v1"; echo $rg $name
az cognitiveservices account create -g $rg -n $name \
  --kind OpenAI --sku S0 --yes \
  --custom-domain $name.openai.azure.com --api-properties "{'DisableLocalAuth':false}"

az cognitiveservices account show -g $rg -n $name --query id -o tsv
# /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg-core/providers/Microsoft.CognitiveServices/accounts/gptstack-v1

az cognitiveservices account keys list -g $rg -n $name
az cognitiveservices account show -g $rg -n $name --query "properties.endpoint" -otsv # $name.openai.azure.com

az cognitiveservices account deployment list -g $rg -n $name # -o table
az cognitiveservices account deployment create -g $rg -n $name --deployment-name gpt-35-turbo \
  --model-name gpt-35-turbo --model-version "0125" --model-format OpenAI \
  --sku-name "Standard" \
  --capacity 1
az cognitiveservices account deployment create -g $rg -n $name --deployment-name gpt-4o \
  --model-name gpt-4o --model-version "2024-11-20" --model-format OpenAI \
  --sku-name Standard \
  --capacity 1
  
az cognitiveservices account list-usage -g $rg -n $name
```

```
# azure-openai.key

rg="rg-core"; name="gptstack-v1"; echo $rg $name
export AZURE_OPENAI_KEY=$(az cognitiveservices account keys list -g $rg -n $name --query "key2" -o tsv); echo $AZURE_OPENAI_KEY
export AZURE_OPENAI_ENDPOINT=$(az cognitiveservices account show -g $rg -n $name --query "properties.endpoint" -otsv); echo $AZURE_OPENAI_ENDPOINT
# AZURE_OPENAI_ENDPOINT: https://$name.openai.azure.com/
export AZURE_OPENAI_DEPLOYMENT="gpt-35-turbo"; echo $AZURE_OPENAI_DEPLOYMENT
# export AZURE_OPENAI_DEPLOYMENT="gpt-4o"; echo $AZURE_OPENAI_DEPLOYMENT

curl "${AZURE_OPENAI_ENDPOINT}openai/deployments/${AZURE_OPENAI_DEPLOYMENT}/chat/completions?api-version=2024-02-15-preview" \
  -H "Content-Type: application/json" \
  -H "api-key: ${AZURE_OPENAI_KEY}" \
  -d '{
    "messages": [
      {"role": "system", "content": "És um assistente útil."},
      {"role": "user", "content": "Olá, quem és tu?"}
    ],
    "temperature": 0.7,
    "max_tokens": 100
  }'
  
{"choices":[{"content_filter_results":{"hate":{"filtered":false,"severity":"safe"},"self_harm":{"filtered":false,"severity":"safe"},"sexual":{"filtered":false,"severity":"safe"},"violence":{"filtered":false,"severity":"safe"}},"finish_reason":"stop","index":0,"logprobs":null,"message":{"content":"Hello! How can I assist you today?","role":"assistant"}}],"created":1751031161,"id":"chatcmpl-redacted","model":"gpt-3.5-turbo-0125","object":"chat.completion","prompt_filter_results":[{"prompt_index":0,"content_filter_results":{}}],"system_fingerprint":"fp_0165350fbb","usage":{"completion_tokens":9,"prompt_tokens":18,"total_tokens":27}}
```

- https://azure.microsoft.com/en-us/pricing/details/cognitive-services/openai-service/?cdn=disable: "latest"
- https://ai.azure.com/resource/playground: Azure AI Foundry | Azure OpenAI. Chat, Sample Code, curl (with the lastest api-version)


```
# azure-openai.entra-id

# sample: Azure AI Foundry portal, Chat, Sample Code, curl, Entra ID authentication

rg="rg-core"; name="gptstack-v1"; echo $rg $name
export AZURE_OPENAI_ENDPOINT=$(az cognitiveservices account show -g $rg -n $name --query "properties.endpoint" -otsv); echo $AZURE_OPENAI_ENDPOINT
export AZURE_OPENAI_DEPLOYMENT="gpt-35-turbo"; echo $AZURE_OPENAI_DEPLOYMENT
# export AZURE_OPENAI_DEPLOYMENT="gpt-4o"; echo $AZURE_OPENAI_DEPLOYMENT
curl "${AZURE_OPENAI_ENDPOINT}openai/deployments/${AZURE_OPENAI_DEPLOYMENT}/chat/completions?api-version=2025-01-01-preview" \
   -H "Content-Type: application/json" \
   -H "Authorization: Bearer $(az account get-access-token --scope https://cognitiveservices.azure.com/.default --query accessToken --output tsv | tr -d '\n\r')" \
   -d "{
     \"messages\": [{\"role\":\"system\",\"content\":\"You are an AI assistant that helps people find information.\"}],
     \"max_tokens\": 800,
     \"temperature\": 0.7,
     \"frequency_penalty\": 0,
     \"presence_penalty\": 0,     
     \"top_p\": 0.95,
     \"stop\": null
   }"

# {"error":{"code":"PermissionDenied","message":"The principal `redactp-1111-1111-1111-111111111111` lacks the required data action `Microsoft.CognitiveServices/accounts/OpenAI/deployments/chat/completions/action` to perform `POST /openai/deployments/{deployment-id}/chat/completions` operation."}}
rg="rg-core"; name="gptstack-v1"; echo $rg $name
export principalId=$(az ad signed-in-user show --query id -o tsv)
az role assignment create \
  --assignee $principalId \
  --role "Cognitive Services OpenAI User" \
  --scope $(az cognitiveservices account show -g $rg -n $name --query id -o tsv)
az role assignment list --assignee $principalId --all --output table | grep Cog
```

```
# azure-openai.python3

#!/bin/bash

rg="rg-core"; name="gptstack-v1"; echo $rg $name
export AZURE_OPENAI_KEY=$(az cognitiveservices account keys list -g $rg -n $name --query "key2" -o tsv); echo $AZURE_OPENAI_KEY
export AZURE_OPENAI_ENDPOINT=$(az cognitiveservices account show -g $rg -n $name --query "properties.endpoint" -otsv); echo $AZURE_OPENAI_ENDPOINT
export AZURE_OPENAI_DEPLOYMENT="gpt-35-turbo"; echo $AZURE_OPENAI_DEPLOYMENT
# export AZURE_OPENAI_DEPLOYMENT="gpt-4o"; echo $AZURE_OPENAI_DEPLOYMENT
export AZURE_API_BASE=$AZURE_OPENAI_ENDPOINT
export AZURE_API_VERSION="2024-02-15-preview"
export AZURE_API_KEY=$AZURE_OPENAI_KEY

python3 -m venv venv
source venv/bin/activate
pip install litellm

python3 <<EOF
import os
import litellm

response = litellm.completion(
    model="azure/gpt-4o",
    messages=[
        {"role": "system", "content": "You are a Kubernetes SRE expert."},
        {"role": "user", "content": "Why are my nginx pods unhealthy?"}
    ],
    max_tokens=500,
    api_base=os.environ["AZURE_API_BASE"],
    api_key=os.environ["AZURE_API_KEY"],
    api_version=os.environ["AZURE_API_VERSION"]
)

print(response['choices'][0]['message']['content'])
EOF
```

```
# curl with stream (data.choices[0].delta.content)
export AZURE_OPENAI_DEPLOYMENT="gpt-35-turbo"; echo $AZURE_OPENAI_DEPLOYMENT
curl "${AZURE_OPENAI_ENDPOINT}openai/deployments/${AZURE_OPENAI_DEPLOYMENT}/chat/completions?api-version=2024-02-15-preview" \
  -H "Content-Type: application/json" \
  -H "api-key: ${AZURE_OPENAI_KEY}" \
  --no-buffer \
  -d '{
    "messages": [
      {"role": "user", "content": "Faz um poema sobre o mar"}
    ],
    "temperature": 0.7,
    "max_tokens": 100,
    "stream": true
  }' | grep --line-buffered "data:" | sed 's/^data: //g' | jq -r '.choices[0].delta.content? // ""'
  
# curl for stream and handling multi-modal data
export AZURE_OPENAI_DEPLOYMENT="gpt-4o"; echo $AZURE_OPENAI_DEPLOYMENT
curl "${AZURE_OPENAI_ENDPOINT}openai/deployments/${AZURE_OPENAI_DEPLOYMENT}/chat/completions?api-version=2024-02-15-preview" \
  -H "Content-Type: application/json" \
  -H "api-key: ${AZURE_OPENAI_KEY}" \
  --no-buffer \
  -d '{
    "messages":[
      {"role":"system","content":"És um assistente multimodal."},
      {"role":"user","content":[
        {"type":"text","text":"Analisa esta imagem, por favor."},
        {"type":"image_url","image_url":{"url":"https://exemplo.com/minha.jpg"}}
      ]}
    ],
    "temperature":0.7,
    "max_tokens":200,
    "stream":true
  }'
```

> ## openai

```
export OPENAI_API_KEY="sk-…"

PROMPT="Dá-me uma ideia de nome para uma startup de IA em Portugal"
curl https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "'"$PROMPT"'"}],
    "temperature": 0.7
  }'
```
- https://platform.openai.com/settings/organization/api-keys
- https://platform.openai.com/usage
- https://platform.openai.com/settings/organization/billing/overview: Credit remaining
- https://openai.com/api/pricing/
- https://platform.openai.com/settings/organization/limits: Rate limits. "Current tier" "At least $5 spent on the API"
- https://platform.openai.com/docs/guides/error-codes/api-errors
- https://learn.microsoft.com/en-us/azure/ai-foundry/openai/supported-languages?tabs=dotnet-secure%2Csecure%2Cpython-secure%2Ccommand&pivots=programming-language-python
