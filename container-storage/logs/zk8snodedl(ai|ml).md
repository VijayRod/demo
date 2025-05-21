> ## dl

```
# dl.models

Ciência Computacional
└── Inteligência Artificial (IA)
    └── Machine Learning (ML)
        └── Deep Learning (DL)
            ├── NLP (Processamento de Linguagem Natural)
            │   └── Language Models
            │       └── LLMs (Large Language Models)
            │           └── Texto (com visão parcial)
            │               └── Ex: GPT-3.5, GPT-4, GPT-4-turbo
            │
            ├── Computer Vision
            │   └── Vision Models
            │       └── Text-to-Image Generator (Texto → Imagem)
            │           └── Ex: DALL·E 3, CLIP (também combina texto+imagem)
            │
            ├── Speech AI
            │   └── Speech Models
            │       └── ASR (Automatic Speech Recognition): Áudio → Texto
            │           └── Ex: Whisper
            │
            ├── Multimodal AI
            │   └── Multimodal Models
            │       └── LLM + Vision + Speech (Texto, Imagem, Áudio)
            │           └── Ex: GPT-4o (omni)
            │
            └── Representation Learning
                └── Embedding Models
                    └── Semantic Vector Models (Texto → Vetor Semântico)
                        └── Ex: text-embedding-3-small, text-embedding-3-large
```

```
# dl.tokens

| Model Type     | Uses Tokens? | Token Type                          | Example Input                              | Tokenization Example                                                                 |
|----------------|--------------|-------------------------------------|--------------------------------------------|--------------------------------------------------------------------------------------|
| LLM (e.g. GPT) | ✅ Yes        | Text tokens (BPE, Tiktoken)         | "Transformers are great!"                  | → `["Transform", "ers", " are", " great", "!"]` (≈5 tokens)                         |
| Vision (e.g. ViT, CLIP) | ✅ Yes | Visual tokens (image patches)     | 224×224 px image                           | → 14×14 grid = 196 tokens (each 16×16 px patch)                                     |
| Multimodal (e.g. GPT-4o) | ✅ Yes | Unified tokens (text + vision + audio) | Input: image + prompt: "What is this animal?" | Image patches + text tokens combined as one sequence                                |
| Speech (e.g. Whisper) | ✅ Yes | Text tokens (after audio processing) | Audio: "Olá, tudo bem?"                     | Audio → spectrogram → → `["Olá", ",", " tudo", " bem", "?"]` (~5 tokens)            |
```

> ## dl.llm

```
gpt: Generative Pre-trained Transformer

Model version: GPT-3.5, GPT-4-turbo, GPT-4o
Capabilities: text, code, image, voice, etc.
Interface: ChatGPT, API, mobile apps, plugins, etc.
Use cases: assistant, agent, co-pilot, etc

| Model Name           | Developer       | Open-source | Multimodal | Max Tokens | Typical Usage                         |
|----------------------|------------------|--------------|------------|------------|----------------------------------------|
| gpt-3.5-turbo         | OpenAI           | No           | No         | 16k        | Fast, general-purpose text, free tier  |
| gpt-4-turbo           | OpenAI           | No           | Partial    | 128k       | Advanced text/code, ChatGPT Plus/API   |
| gpt-4o (omni)         | OpenAI           | No           | Yes        | 128k       | All-in-one: text, vision, voice        |
| text-davinci-003      | OpenAI           | No           | No         | 4k         | Legacy GPT-3, high-quality text        |
| code-davinci-002      | OpenAI           | No           | No         | 8k         | Legacy code model                      |
| text-embedding-3-small| OpenAI           | No           | No         | N/A        | Semantic search, RAG, vector DB        |
| text-embedding-3-large| OpenAI           | No           | No         | N/A        | High-accuracy embeddings               |
| claude-3-opus         | Anthropic        | No           | Partial    | 200k       | Safe, reasoning-focused assistant      |
| gemini-1.5-pro        | Google DeepMind  | No           | Yes        | 1M+        | Long-context, file-aware assistant     |
| mistral-7b            | Mistral AI       | Yes          | No         | ~8k        | Lightweight general LLM                |
| mixtral-8x7b          | Mistral AI       | Yes          | No         | ~32k       | MoE architecture, fast + scalable      |
| llama-2-13b           | Meta             | Yes (with EULA) | Partial | 4k–32k     | General-purpose LLM, open usage        |
| llama-3-70b           | Meta             | Yes (with EULA) | Partial | 8k–128k    | State-of-the-art open LLM              |
| gemma-7b              | Google           | Yes (restricted) | No      | ~8k        | Research, edge devices, fine-tuning    |
| deepseek-coder        | DeepSeek         | Yes          | No         | 16k+       | Optimized for code generation          |
| deepseek-llm          | DeepSeek         | Yes          | No         | 16k+       | Chat, reasoning, open chatbot base     |
| command-r-plus        | Cohere           | Yes          | Partial    | 128k       | Instruction + RAG focused              |
| yi-34b                | 01.AI             | Yes          | Partial    | 32k+       | Multilingual LLM                       |
| qwen-72b              | Alibaba DAMO     | Yes          | Partial    | 32k+       | Multimodal, multilanguage              |
| openchat              | Community        | Yes          | No         | ~8k        | Instruction-tuned LLaMA variants       |

 
```

> ## dl.multimodal

```
# refer to llm
```

> ## dl.representation-model

```
```

> ## dl.speech-model

```
```

> ## dl.vision-model

```
```
