> ## HolmesGPT

```
# install on ubuntu
pipx install --force "https://github.com/robusta-dev/holmesgpt/archive/refs/heads/master.zip"
pipx ensurepath
holmes version
```
https://github.com/robusta-dev/holmesgpt/blob/master/docs/installation.md

```
# usage
holmes version
holmes ask --help
```

```
# usage-openai

export OPENAI_API_KEY="sk-proj-redacted"; echo $OPENAI_API_KEY
holmes ask  "why are my nginx pods are unhealthy?" # --model=azure/gpt-4o

AI: I couldn't find any pods with "nginx" in their name. Please check if the pods are named differently or if they are
in a different namespace. If you have more specific details about the pod names or namespaces, please provide them.
```

- https://robusta-dev.github.io/holmesgpt/ai-providers/openai/
- https://litellm.vercel.app/docs/providers/openai

```
# usage-openai.example

kubectl run nginx --image=nginx2
holmes ask  "why are my nginx pods are unhealthy?" # --model=azure/gpt-4o

AI: The nginx pod is unhealthy due to an ErrImagePull error. The image "nginx2" cannot be pulled because the repository
does not exist or may require authorization. The error message indicates "pull access denied" and
"insufficient_scope: authorization failed."
To resolve this issue, ensure that the image name is correct and that you have access to the repository. If "nginx2"
is a private image, make sure to provide the necessary credentials for pulling the image. If it's a typo, correct
the image name to a valid one, such as "nginx".
```

```
# usage-openai.example
holmes ask  "Do my pods and nodes have enough resources, and do you have any recommendations based on that?"
```

```
# usage-openai.error.RateLimitError

Error: litellm.RateLimitError: RateLimitError: OpenAIException - Request too large for gpt-4o in organization
org-redacted on tokens per min (TPM): Limit 30000, Requested 31330. The input or output tokens must
be reduced in order to run successfully. Visit https://platform.openai.com/account/rate-limits to learn more.
```

- https://platform.openai.com/api-keys
- https://platform.openai.com/docs/guides/error-codes/api-errors: 429 (Rate limit, quota)
- https://platform.openai.com/account/rate-limits: rate limits applied on tokens per minute (TPM), requests per minute or day (RPM/RPD), and other model-specific limits
  - https://platform.openai.com/settings/organization/limits
- https://platform.openai.com/docs/guides/rate-limits#usage-tiers
- https://platform.openai.com/settings/organization/billing/overview: Credit remaining
- https://openai.com/policies/service-credit-terms/

```
# usage-openai.key.permissions.Read only.error.Missing scopes: model.request
# repro: grant Permissions=ReadOnly, and submit a holmes ask request
# mitigate: grant Permissions=All
# mitigate (preferred): grant Permissions=Restricted with /v1/chat/completions (Write), /v1/models (Read)

holmes ask "how are my pods"

Error: litellm.BadRequestError: OpenAIException - You have insufficient permissions for this operation. Missing
scopes: model.request. Check that you have the correct role in your organization (Reader, Writer, Owner) and project
(Member, Owner), and if you're using a restricted API key, that it has the necessary scopes.
```

```
# usage-azure-openai
rg="rg-core"; name="gptstack-v1"; echo $rg $name
export AZURE_API_BASE=$(az cognitiveservices account show -g $rg -n $name --query "properties.endpoint" -otsv); echo $AZURE_API_BASE
export AZURE_API_VERSION="2024-02-15-preview"; echo $AZURE_API_VERSION
export AZURE_API_KEY=$(az cognitiveservices account keys list -g $rg -n $name --query "key2" -o tsv); echo $AZURE_API_KEY
env | grep AZURE_

holmes ask  "why are my nginx pods are unhealthy?" --model=azure/gpt-4o
```

```
holmes toolset refresh
```

> ## HolmesGPT.debug

```
holmes ask --help
holmes ask "what are my nodepool kubernetes versions" --model=azure/gpt-4.1 --show-tool-output

```

https://github.com/robusta-dev/holmesgpt/issues
https://github.com/robusta-dev/holmesgpt/tree/master/tests/llm/fixtures


```
# error.RateLimitError

User: why are my nginx pods are unhealthy?
Thinking...
Retrying request to /chat/completions in 60.000000 seconds                                      _base_client.py:1061
Retrying request to /chat/completions in 60.000000 seconds                                      _base_client.py:1061

..
    raise self._make_status_error_from_response(err.response) from None
openai.RateLimitError: Error code: 429 - {'error': {'code': '429', 'message': 'Requests to the
ChatCompletions_Create Operation under Azure OpenAI API version 2024-02-15-preview have exceeded
token rate limit of your current OpenAI S0 pricing tier. Please retry after 60 seconds. Please go
here: https://aka.ms/oai/quotaincrease if you would like to further increase the default rate
limit. For Free Account customers, upgrade to Pay as you Go here:
https://aka.ms/429TrialUpgrade.'}}

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
..
    raise AzureOpenAIError(
litellm.llms.azure.common_utils.AzureOpenAIError: Error code: 429 - {'error': {'code': '429',
'message': 'Requests to the ChatCompletions_Create Operation under Azure OpenAI API version
2024-02-15-preview have exceeded token rate limit of your current OpenAI S0 pricing tier. Please
retry after 60 seconds. Please go here: https://aka.ms/oai/quotaincrease if you would like to
further increase the default rate limit. For Free Account customers, upgrade to Pay as you Go
here: https://aka.ms/429TrialUpgrade.'}}

During handling of the above exception, another exception occurred:
..
    raise RateLimitError(
litellm.exceptions.RateLimitError: litellm.RateLimitError: AzureException RateLimitError -
Requests to the ChatCompletions_Create Operation under Azure OpenAI API version
2024-02-15-preview have exceeded token rate limit of your current OpenAI S0 pricing tier. Please
retry after 60 seconds. Please go here: https://aka.ms/oai/quotaincrease if you would like to
further increase the default rate limit. For Free Account customers, upgrade to Pay as you Go
here: https://aka.ms/429TrialUpgrade.
Error: litellm.RateLimitError: AzureException RateLimitError - Requests to the ChatCompletions_Create Operation
under Azure OpenAI API version 2024-02-15-preview have exceeded token rate limit of your current OpenAI S0 pricing
tier. Please retry after 60 seconds. Please go here: https://aka.ms/oai/quotaincrease if you would like to further
increase the default rate limit. For Free Account customers, upgrade to Pay as you Go here:
https://aka.ms/429TrialUpgrade.
```

> ## HolmesGPT.debug.custom_toolset

- https://github.com/robusta-dev/holmesgpt/blob/master/examples/custom_toolset.yaml

```
# custom.aks

```
- https://github.com/robusta-dev/holmesgpt/blob/master/holmes/plugins/toolsets/aks.yaml

```
# custom.aks-node-health
```
- https://github.com/robusta-dev/holmesgpt/blob/master/holmes/plugins/toolsets/aks-node-health.yaml
