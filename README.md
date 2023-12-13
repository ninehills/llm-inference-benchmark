# llm-inference-benchmark

LLM Inference benchmark

## Inference frameworks

| Framework | Docker Image | API Server  | OpenAI API Server | WebUI | Multi Models** | Multi-node | Backends | Embedding Model |
| --------- | ------------ | ----------- | ----------------- | ----- | ------------ | ------------ | -------- | --------------- |
| [text-generation-webui](https://github.com/oobabooga/text-generation-webui) | Yes | Yes | Yes | Yes | No | No | Transformers/llama.cpp/ExLlama/ExLlamaV2/AutoGPTQ/AutoAWQ/GPTQ-for-LLaMa/CTransformers | No |
| [OpenLLM](https://github.com/bentoml/OpenLLM) | Yes | Yes | Yes | No | With [BentoML](https://github.com/bentoml/BentoML) | With [BentoML](https://github.com/bentoml/BentoML) | Transformers(int8,int4,gptq), vLLM(awq/squeezellm), TensorRT | No |
| [vLLM](https://github.com/vllm-project/vllm)* | Yes | Yes | Yes | No | No | Yes(With [Ray](https://docs.ray.io/en/latest/ray-core/starting-ray.html)) | vLLM | No |
| [Xinference](https://github.com/xorbitsai/inference) | Yes | Yes | Yes | Yes | Yes | Yes | Transformers/vLLM/TensorRT/GGML | Yes |
| [TGI](https://github.com/huggingface/text-generation-inference)*** | Yes | Yes | No | No | No | No | Transformers/AutoGPTQ/AWQ/EETP/vLLM/ExLlama/ExLlamaV2 | No |
| [ScaleLLM](https://github.com/vectorch-ai/ScaleLLM) | Yes | Yes | Yes | Yes | No | No | Transformers/AutoGPTQ/AWQ/vLLM/ExLlama/ExLlamaV2 | No |
| [FastChat](https://github.com/lm-sys/FastChat) | Yes | Yes | Yes | Yes | Yes | Yes | Transformers/AutoGPTQ/AWQ/vLLM/ExLlama/ExLlamaV2 | Yes |

- *vLLM/TGI can also be used as a backend.
- **Multi Models: Load multiple models at the same time.
- ***TGI don't support chat mode, need manually parse the prompt.

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
| [TGI](https://github.com/huggingface/text-generation-inference) | Yes | awq/eetq/gptq/bitsandbytes | Yes | Yes | Yes |

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
- GPTQ 8bit: [01-ai/Yi-6B-Chat-8bits](https://huggingface.co/01-ai/Yi-6B-Chat-8bits)
- AWQ 4bit: [01-ai/Yi-6B-Chat-4bits](https://huggingface.co/01-ai/Yi-6B-Chat-4bits)

Data:

- Prompt Length: 512 (with some random characters to avoid cache).
- Max Tokens: 200.

### Backend Benchmark

#### No Quantisation

| Backend | TPS@4 | QPS@4 | TPS@1 | QPS@1 | FTL@1 |
| ------- | ----- | ----- | ----- | ----- | ----- |
| text-generation-webui Transformer | 40.39 | 0.15 | 41.47 | 0.21 | 344.61 |
| OpenLLM PyTorch | 60.79 | 0.22 | 44.73 | 0.21 | 514.55 |
| TGI | 192.58 | 0.90 | 59.68 | 0.28 | 82.72 |
| vLLM | 222.63 | 1.08 | 62.69 | 0.30 | 95.43 |
| TensorRT | - | - | - | - | - |
| CTranslate2* | - | - | - | - | - |

- bs: Batch Size, bs=4 means batch size is 4.
- TPS: Tokens per Second.
- QPS: Query per Second.
- FTL: First Token Latency, ms. ONLY in stream mode.

- *Use CTranslate2 convert Yi-6B-Chat failed. see [issue](https://github.com/OpenNMT/CTranslate2/issues/1587).

#### 8Bit Quantisation

| Backend | TPS@4 | QPS@4 | TPS@1 | QPS@1 | FTL@1 |
| ------- | ----- | ----- | ----- | ----- | ----- |
| TGI eetq 8bit | 293.08 | 1.41 | 88.08 | 0.42 | 63.69 |
| TGT GPTQ 8bit | - | - | - | - | - |
| OpenLLM PyTorch AutoGPTQ 8bit | 49.8 | 0.17 | 29.54 | 0.14 | 930.16 |

- bitsandbytes is very slow (int8 6.8 tokens/s), so we don't benchmark it.
- eetq-8bit doesn't require specific model.
- TGT GPTQ 8bit load failed: Server error: module 'triton.compiler' has no attribute 'OutOfResources'
    - TGT GPTQ bit use exllama or triton backend.

#### 4Bit Quantisation

| Backend | TPS@4 | QPS@4 | TPS@1 | QPS@1 | FTL@1 |
| ------- | ----- | ----- | ----- | ----- | ----- |
| TGI AWQ 4bit | 336.47 | 1.61 | 102.00 | 0.48 | 94.84 |
| vLLM AWQ 4bit | 29.03 | 0.14 | 37.48 | 0.19 | 3711.0 |
