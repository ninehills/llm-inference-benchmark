# llm-inference-benchmark

LLM Inference benchmark

## Inference frameworks

| Framework | Docker Image | API Server  | OpenAI API Server | WebUI | Multi Models** | Multi-node | Backends | Embedding Model |
| --------- | ------------ | ----------- | ----------------- | ----- | ------------ | ------------ | -------- | --------------- |
| [text-generation-webui](https://github.com/oobabooga/text-generation-webui) | Yes | Yes | Yes | Yes | No | No | Transformers/llama.cpp/ExLlama/ExLlamaV2/AutoGPTQ/AutoAWQ/GPTQ-for-LLaMa/CTransformers | No |
| [OpenLLM](https://github.com/bentoml/OpenLLM) | Yes | Yes | Yes | No | No | No | Transformers(int8,int4,gptq), vLLM(awq/squeezellm), TensorRT | No |
| [vLLM](https://github.com/vllm-project/vllm)* | Yes | Yes | Yes | No | No | No | vLLM | No |
| [Xinference](https://github.com/xorbitsai/inference) | Yes | Yes | Yes | Yes | Yes | Yes | Transformers/vLLM/TensorRT/GGML | Yes |
| [TGI](https://github.com/huggingface/text-generation-inference) | Yes | Yes | No | No | No | No | Transformers/AutoGPTQ/AWQ/vLLM/ExLlama/ExLlamaV2 | No |
| [ScaleLLM](https://github.com/vectorch-ai/ScaleLLM) | Yes | Yes | Yes | Yes | No | No | Transformers/AutoGPTQ/AWQ/vLLM/ExLlama/ExLlamaV2 | No |
| [FastChat](https://github.com/lm-sys/FastChat) | Yes | Yes | Yes | Yes | Yes | Yes | Transformers/AutoGPTQ/AWQ/vLLM/ExLlama/ExLlamaV2 | Yes |

- *vLLM can also be used as a backend.
- **Multi Models: support to load multiple models at the same time.

## Inference backends

We only choose the backends that runned on GPU.

| Backend | PEFT Adapters* | Quatisation | Batching | Distributed Inference | Streaming |
| ------- | ------------- | ---------- | -------- | ----------- | --------- |
| [Transformers](https://github.com/huggingface/transformers) | Yes | [bitsandbytes](https://github.com/TimDettmers/bitsandbytes)(int8/int4), [AutoGPTQ](https://github.com/PanQiWei/AutoGPTQ)(gptq), AutoAWQ(awq) | Yes | [accelerate](https://huggingface.co/docs/accelerate/index) | Yes |
| [vLLM](https://github.com/vllm-project/vllm) | No | awq/squeezellm | Yes | Yes | Yes |
| [ExLlamaV2](https://github.com/turboderp/exllamav2) | No | GPTQ | Yes | Yes | Yes |
| [TensorRT](https://github.com/NVIDIA/TensorRT-LLM) | No | [some models](https://github.com/NVIDIA/TensorRT-LLM/blob/main/docs/source/precision.md) | Yes | Yes | Yes |
| [Candle](https://github.com/huggingface/candle) | No | No | Yes | Yes | Yes |
| [CTranslate2](https://github.com/OpenNMT/CTranslate2) | No | Yes | Yes | Yes | Yes |

- *PEFT Adapters: support to load seperate PEFT adapters(mostly lora).

## Benchmark

Hardware:

- GPU: 1x NVIDIA RTX4090 24GB
- CPU: Intel Core i9-13900K
- Memory: 96GB

Software:

- VM: WSL2 on Windows 11
- Guest OS: Ubuntu 22.04
- NVIDIA Driver Version: 536.67
- CUDA Version: 12.2
- PyTorch: 2.1.1

Model:

- BFloat16: [01-ai/Yi-6B-Chat](https://huggingface.co/01-ai/Yi-6B-Chat)
- GPTQ 4bits: [TheBloke/Yi-34B-GPTQ](https://huggingface.co/TheBloke/Yi-34B-GPTQ)
- GPTQ 8bits: [01-ai/Yi-6B-Chat-4bits](https://huggingface.co/01-ai/Yi-6B-Chat-8bits)
- AWQ 4bits: [01-ai/Yi-6B-Chat-4bits](https://huggingface.co/01-ai/Yi-6B-Chat-4bits)

Data:

- Prompt Length: 512 (with some random characters to avoid cache).
- Max Tokens: 200.

### Backend Benchmark

#### No Quantisation

| Backend | TPS@4 | QPS@4 | TPS@1 | QPS@1 | FTL@1 |
| ------- | ----- | ----- | ----- | ----- | ----- |
| text-generation-webui Transformer | 40.39 | 0.15 | 40.71 | 0.20 | stream failed |
| OpenLLM PyTorch | 60.79 | 0.22 | 44.91 | 0.22 | stream failed |
| TGI | - | - | - | - | - |
| vLLM | 222.63 | 1.08 | 60.18 | 0.30 | 2.73 |
| TensorRT | - | - | - | - | - |
| CTranslate2 | - | - | - | - | - |

- bs: Batch Size, bs=4 means batch size is 4.
- TPS: Tokens per Second, TPS=200 means 200 tokens per second.
- QPS: Query per Second, QPS=1.08 means 1.08 queries per second.
- FTL: First Token Latency, 2.73ms means 2.73 milliseconds. ONLY in stream mode.

#### 8Bit Quantisation

| Backend | TPS@4 | QPS@4 | TPS@1 | QPS@1 | FTL@1 |
| ------- | ----- | ----- | ----- | ----- | ----- |
| text-generation-webui GPTQ 8bits | - | - | - | - | - |

- bitsandbytes is very slow (int8 6.8 tokens/s), so we don't benchmark it.

#### 4Bit Quantisation

| Backend | TPS@4 | QPS@4 | TPS@1 | QPS@1 | FTL@1 |
| ------- | ----- | ----- | ----- | ----- | ----- |
| OpenLLM GPTQ 4bits | - | - | - | - | - |
| TGI ExLLamaV2 GPTQ 4bits | - | - | - | - | - |
| vLLM AWQ 4bits | - | - | - | - | - |
