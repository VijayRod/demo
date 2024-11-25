## ml.md

- https://developers.google.com/machine-learning/resources/ml-ai-basics
- https://developers.google.com/machine-learning/glossary
- https://platform.openai.com/docs/concepts

## ml.languagemodel

- https://developers.google.com/machine-learning/glossary#model: In general, any mathematical construct that processes input data and returns output. Phrased differently, a model is the set of parameters and structure needed for a system to make predictions. In supervised machine learning, a model takes an example as input and infers a prediction as output.
  - In supervised machine learning, a model takes an example as input and infers a prediction as output. linear regression model. neural network model. decision tree model.
  - Unsupervised machine learning also generates models, typically a function that can map an input example to the most appropriate cluster.
- https://developers.google.com/machine-learning/resources/intro-llms#what_is_a_language_model: A language model is a machine learning model that aims to predict and generate plausible language. Autocomplete is a language model, for example.
- https://arxiv.org/pdf/2305.20050: Let’s Verify Step by Step.  Large language models are capable of solving tasks that require complex multi
step reasoning by generating solutions in a step-by-step chain-of-thought format

## ml.languagemodel.supervised.neural-network

- https://medium.com/@limbusapna3/navigating-the-genai-frontier-transformers-gpt-and-the-path-to-accelerated-innovation-d4b1d0f58f65: In 2014, the sequence-to-sequence (Seq2Seq) model architecture paper titled “Sequence to Sequence Learning with Neural Networks” was introduced by Ilya Sutskever, Oriol Vinayls, and Quoc V.Le, they introduced the concept of Encoder-Decoder Architecture to solve a Seq2Seq task like machine translation.

## ml.languagemodel.supervised.neural-network.RNN.genai

- https://www.ibm.com/think/insights/generative-ai-benefits: generative AI generates images, music, speech, code, video or text, while it interprets and manipulates pre-existing data
- https://developers.google.com/machine-learning/glossary#generative-ai: generative AI models can create ("generate") content
- Some earlier technologies, including LSTMs and RNNs, can also generate original and coherent content. Some experts view these earlier technologies as generative AI
- https://medium.com/@limbusapna3/navigating-the-genai-frontier-transformers-gpt-and-the-path-to-accelerated-innovation-d4b1d0f58f65: Transformers contribute to the acceleration of general artificial intelligence (GenAI) by pushing the boundaries of language understanding and generation.
- https://deepint.ai/recurrent-neural-networks/: Recurrent Neural Networks (RNNs): Building Blocks of Generative Models
- https://openai.com/index/generative-models/
- https://platform.openai.com/docs/guides/text-generation

## ml.languagemodel.supervised.neural-network.RNN.genai.transformer (recurrent neural networks)

- https://ai.googleblog.com/2017/08/transformer-novel-neural-network.html: Transformer: A Novel Neural Network Architecture for Language Understanding.
  - Neural networks, in particular recurrent neural networks (RNNs), are now at the core of the leading approaches to language understanding tasks such as language modeling, machine translation and question answering. In “Attention Is All You Need”,
- https://developers.google.com/machine-learning/resources/intro-llms#transformers: This made it possible to process longer sequences by focusing on the most important part of the input, solving memory issues encountered in earlier models.
- https://research.ibm.com/blog/what-is-generative-AI: Transformers, introduced by Google in 2017 in a landmark paper “Attention Is All You Need,”

- https://arxiv.org/abs/1706.03762: Attention Is All You Need


## ml.languagemodel.supervised.neural-network.RNN.genai.transformer.token

- https://developers.google.com/machine-learning/resources/intro-llms#self-attention: on behalf of each token of input, self-attention (transformer) asks

## ml.languagemodel.supervised.neural-network.RNN.genai.transformer.token.llm

- https://developers.google.com/machine-learning/resources/intro-llms
- https://developers.google.com/machine-learning/resources/intro-llms#what_is_a_large_language_model: "large" has been used to describe BERT (110M parameters) as well as PaLM 2 (up to 340B parameters).
  - Parameters are the weights the model learned during training, used to predict the next token in the sequence. "Large" can refer either to the number of parameters in the model, or sometimes the number of words in the dataset.
- https://cloud.google.com/ai/llms
- https://www.ibm.com/topics/large-language-models
- https://www.computerworld.com/article/1627101/what-are-large-language-models-and-how-are-they-used-in-generative-ai.html: Along with OpenAI’s GPT-3 and 4 LLM, popular LLMs include open models such as Google’s LaMDA and PaLM LLM (the basis for Bard), Hugging Face’s BLOOM and XLM-RoBERTa, Nvidia’s NeMO LLM, XLNet, Co:here, and GLM-130B.
  - Open-source LLMs. LLaMA (Large Language Model Meta AI)

## ml.languagemodel.supervised.neural-network.RNN.genai.transformer.token.llm.chatbot.chatgpt

- https://www.computerworld.com/article/1627101/what-are-large-language-models-and-how-are-they-used-in-generative-ai.html: ChatGPT stands for chatbot generative pre-trained transformer. The chatbot’s foundation is the GPT large language model (LLM), a computer algorithm that processes natural language inputs and predicts the next word based on what it’s already seen.
- https://openai.com/index/chatgpt/

## ml.languagemodel.supervised.neural-network.RNN.genai.transformer.token.llm.chatbot.bard

- https://cloud.google.com/ai/llms#build-a-chatbot
- https://blog.google/technology/ai/google-gemini-ai/: Bard will use a fine-tuned version of Gemini Pro for more advanced reasoning, planning, understanding and more.
  - developers and enterprise customers can access Gemini Pro via the Gemini API in Google AI Studio or Google Cloud Vertex AI.
- https://expertbeacon.com/google-bert-vs-bard-a-comprehensive-comparison-of-language-models/: language models. Two of its most notable contributions are BERT (Bidirectional Encoder Representations from Transformers) and BARD (Biodirectional and Auto-Regressive Decoders)
  - While BERT focuses on encoding and understanding text, BARD goes a step further by enabling open-ended conversation and generation.

## ml.languagemodel.supervised.neural-network.RNN.genai.transformer.token.llm.model

- https://platform.openai.com/docs/models

## ml.languagemodel.supervised.neural-network.RNN.genai.transformer.token.llm.model.anthropic.claude35sonnet

- https://www.anthropic.com/news/claude-3-5-sonnet
- https://claude.ai/chat/

## ml.languagemodel.supervised.neural-network.RNN.genai.transformer.token.llm.model.google.lamda

- https://www.wired.com/story/how-chatgpt-works-large-language-model/: the research paper introducing the LaMDA (Language Model for Dialogue Applications) model, which Bard is built on
- https://arxiv.org/abs/2201.08239: LaMDA: Language Models for Dialog Applications. LaMDA is a family of Transformer based neural language models specialized for dialog, which have up to 137B parameters and are pre-trained on 1.56T words of public dialog data and web text.

## ml.languagemodel.supervised.neural-network.RNN.genai.transformer.token.llm.model.meta.llama

## ml.languagemodel.supervised.neural-network.RNN.genai.transformer.token.llm.model.openai.gpt-3

- https://www.ibm.com/think/insights/generative-ai-benefits: 

## ml.languagemodel.supervised.neural-network.RNN.genai.transformer.token.llm.model.openai.gpt-4

## ml.languagemodel.supervised.neural-network.RNN.genai.transformer.token.llm.model.openai.o1

- https://openai.com/index/introducing-openai-o1-preview/: refine their thinking process, try different strategies, and recognize their mistakes. similarly to PhD students

## ml.languagemodel.supervised.neural-network.RNN.genai.transformer.token.slm

- https://www.splunk.com/en_us/blog/learn/language-models-slm-vs-llm.html: the most visible difference between the SLM and LLM is the model size. LLMs such as ChatGPT (GPT-4) purportedly contain 1.76 Trillion parameters. Open source SLM such as Mistral 7B can contain 7 billion model parameters. 
- https://www.ibm.com/think/topics/small-language-models

## ml.languagemodel.supervised.neural-network.RNN.genai.transformer.token.llm.prompt-engineering

- https://github.blog/ai-and-ml/generative-ai/prompt-engineering-guide-generative-ai-llms/: Prompt engineering is the art of communicating with a generative AI model
- https://platform.openai.com/docs/guides/prompt-engineering
- https://developer.nvidia.com/blog/an-introduction-to-large-language-models-prompt-engineering-and-p-tuning/#prompting_llms
