> ## azureopenai

```
# azureopenai..env

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
# azureopenai.key

rg="rg-core"; name="gptstack-v1"; echo $rg $name
export AZURE_OPENAI_KEY=$(az cognitiveservices account keys list -g $rg -n $name --query "key2" -o tsv); echo $AZURE_OPENAI_KEY
export AZURE_OPENAI_ENDPOINT=$(az cognitiveservices account show -g $rg -n $name --query "properties.endpoint" -otsv); echo $AZURE_OPENAI_ENDPOINT
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
# azureopenai.entra-id

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
# azureopenai.python3

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
