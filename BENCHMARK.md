# Do benchmark

## benchmark

Use <https://github.com/fw-ai/benchmark> to benchmark.

```bash
python -m venv .venv
source .venv/bin/activate

pip install -r llm_bench/requirements.txt
```

NOTICE: Every bench run twice, the first run is warm up.

## backends

### text-generation-webui

- text-generation-webui: snapshot-2023-12-10
- transformers: 4.35.2

```bash
python server.py --api --model Yi-6B-Chat --model-dir ~/models
```

bs=4:

```bash
locust -t 30s --provider openai -u 4 -r 4 -H http://127.0.0.1:5000 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=Yi-6B-Chat --chat
=================================== Summary ====================================
Provider           : openai
Model              : Yi-6B-Chat
Prompt Tokens      : 543.0
Generation Tokens  : 200
Stream             : False
Temperature        : 1.0
Logprobs           : None
Concurrency        : 4
Time To First Token:
Latency Per Token  :
Num Tokens         : 198.25
Total Latency      : 19634.00726575128
Num Requests       : 4
Qps                : 0.14749432591086067
================================================================================
Tokens per Second = 198.25 * 1000 / 19634.00726575128 * 4 = 40.39
```

bs=1 (stream=True)

```bash
locust -t 30s --provider openai -u 1 -r 1 -H http://127.0.0.1:5000 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=Yi-6B-Chat --chat --stream
=================================== Summary ====================================
Provider           : openai
Model              : Yi-6B-Chat
Prompt Tokens      : 543.0
Generation Tokens  : 200
Stream             : True
Temperature        : 1.0
Logprobs           : None
Concurrency        : 1
Time To First Token: 344.6080265000546
Latency Per Token  : 22.378346695343428
Num Tokens         : 198.66666666666666
Total Latency      : 4790.3946911666635
Num Requests       : 6
Qps                : 0.20841500990785683
================================================================================
Tokens per Second = 198.66666666666666 * 1000 / 4790.3946911666635 = 41.47
```

Stream mode failed because of the delimiter is '\r\n\r\n'.

### text-generation-webui with flash_attention_2

bs=4

```bash
locust -t 30s --provider openai -u 4 -r 4 -H http://127.0.0.1:5000 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=Yi-6B-Chat --chat
=================================== Summary ====================================
Provider           : openai
Model              : Yi-6B-Chat
Prompt Tokens      : 543.0
Generation Tokens  : 200
Stream             : False
Temperature        : 1.0
Logprobs           : None
Concurrency        : 4
Time To First Token:
Latency Per Token  :
Num Tokens         : 199.33333333333334
Total Latency      : 13678.096362666678
Num Requests       : 6
Qps                : 0.21237510617563718
================================================================================
Tokens per Second = 199.33333333333334 * 1000 / 13678.096362666678 * 4 = 58.30
``````

bs=1 (stream=True)

```bash
locust -t 30s --provider openai -u 1 -r 1 -H http://127.0.0.1:5000 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=Yi-6B-Chat --chat --stream
=================================== Summary ====================================
Provider           : openai
Model              : Yi-6B-Chat
Prompt Tokens      : 543.0
Generation Tokens  : 200
Stream             : True
Temperature        : 1.0
Logprobs           : None
Concurrency        : 1
Time To First Token: 341.38877033338605
Latency Per Token  : 21.25158606708791
Num Tokens         : 197.83333333333334
Total Latency      : 4545.68322066666
Num Requests       : 6
Qps                : 0.21416693458287103
================================================================================
Tokens per Second = 197.83333333333334 * 1000 / 4545.68322066666 = 43.52
```

### text-generation-webui exllamav2

bs=4:

```bash
locust -t 30s --provider openai -u 4 -r 4 -H http://127.0.0.1:5000 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=Yi-6B-Chat --chat
=================================== Summary ====================================
Provider           : openai
Model              : Yi-6B-Chat
Prompt Tokens      : 545.0
Generation Tokens  : 200
Stream             : False
Temperature        : 1.0
Logprobs           : None
Concurrency        : 4
Time To First Token:
Latency Per Token  :
Num Tokens         : 200.85714285714286
Total Latency      : 11629.082029142834
Num Requests       : 7
Qps                : 0.26460306018954366
================================================================================
Tokens per Second = 200.85714285714286 * 1000 / 11629.082029142834 * 4 = 69.09
```

bs=1 (stream=True)

```bash
locust -t 30s --provider openai -u 1 -r 1 -H http://127.0.0.1:5000 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=Yi-6B-Chat --chat --stream
=================================== Summary ====================================
Provider           : openai
Model              : Yi-6B-Chat
Prompt Tokens      : 545.0
Generation Tokens  : 200
Stream             : True
Temperature        : 1.0
Logprobs           : None
Concurrency        : 1
Time To First Token: 564.7956175714301
Latency Per Token  : 16.78803703481999
Num Tokens         : 189.57142857142858
Total Latency      : 3738.303490000005
Num Requests       : 7
Qps                : 0.2666246244330199
================================================================================
Tokens per Second = 189.57142857142858 * 1000 / 3738.303490000005 = 50.71
```

### text-generation-webui llama.cpp

bs = 4:

```bash
locust -t 30s --provider openai -u 4 -r 4 -H http://127.0.0.1:5000 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=Yi-6B-Chat --chat
=================================== Summary ====================================
Provider           : openai
Model              : Yi-6B-Chat
Prompt Tokens      : 544.0
Generation Tokens  : 200
Stream             : False
Temperature        : 1.0
Logprobs           : None
Concurrency        : 4
Time To First Token:
Latency Per Token  :
Num Tokens         : 156.2
Total Latency      : 9238.212034200023
Num Requests       : 10
Qps                : 0.36761348207202127
================================================================================
Tokens per Second = 156.2 * 1000 / 9238.212034200023 * 4 = 67.63
```

bs = 1 (stream=True):

```bash
locust -t 30s --provider openai -u 1 -r 1 -H http://127.0.0.1:5000 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=Yi-6B-Chat --chat --stream
=================================== Summary ====================================
Provider           : openai
Model              : Yi-6B-Chat
Prompt Tokens      : 544.0
Generation Tokens  : 200
Stream             : True
Temperature        : 1.0
Logprobs           : None
Concurrency        : 1
Time To First Token: 331.5702535555829
Latency Per Token  : 16.997582828708413
Num Tokens         : 164.22222222222223
Total Latency      : 2898.9455936666673
Num Requests       : 9
Qps                : 0.335439284269627
================================================================================
Tokens per Second = 164.22222222222223 * 1000 / 2898.9455936666673 = 56.65

```

### vllm

- vllm: 0.2.4

```bash
python -m vllm.entrypoints.openai.api_server --model ~/models/Yi-6B-Chat --served-model-name Yi-6B-Chat --port 8000
```

bs=4:

```bash
locust -t 30s --provider openai -u 4 -r 4 -H http://127.0.0.1:8000 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=Yi-6B-Chat --chat
=================================== Summary ====================================
Provider           : openai
Model              : Yi-6B-Chat
Prompt Tokens      : 521.0
Generation Tokens  : 200
Stream             : False
Temperature        : 1.0
Logprobs           : None
Concurrency        : 4
Time To First Token:
Latency Per Token  :
Num Tokens         : 200.0
Total Latency      : 3593.354136968628
Num Requests       : 32
Qps                : 1.0800308609840037
================================================================================
Tokens per Second = 200.0 * 1000 / 3593.354136968628 * 4 = 222.63
```

bs=1 (stream=True)

```bash
locust -t 30s --provider openai -u 1 -r 1 -H http://127.0.0.1:8000 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=Yi-6B-Chat --chat --stream
=================================== Summary ====================================
Provider           : openai
Model              : Yi-6B-Chat
Prompt Tokens      : 521.0
Generation Tokens  : 200
Stream             : True
Temperature        : 1.0
Logprobs           : None
Concurrency        : 1
Time To First Token: 95.43349822221596
Latency Per Token  : 15.952094820770412
Num Tokens         : 199.0
Total Latency      : 3269.9003675555286
Num Requests       : 9
Qps                : 0.3030379118901777
================================================================================
Tokens per Second = 1000 / 15.952094820770412 = 62.69
```

### vllm awq 4bit

```bash
python -m vllm.entrypoints.openai.api_server --model ~/models/Yi-6B-Chat-4bits --served-model-name Yi-6B-Chat --port 8000
```

bs=4:

```bash
locust -t 30s --provider openai -u 4 -r 4 -H http://127.0.0.1:8000 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=Yi-6B-Chat --chat
=================================== Summary ====================================
Provider           : openai
Model              : Yi-6B-Chat
Prompt Tokens      : 521.0
Generation Tokens  : 200
Stream             : False
Temperature        : 1.0
Logprobs           : None
Concurrency        : 4
Time To First Token:
Latency Per Token  :
Num Tokens         : 200.0
Total Latency      : 27554.97828125044
Num Requests       : 4
Qps                : 0.14136221506152755
================================================================================
Tokens per Second = 200.0 * 1000 / 27554.97828125044 * 4 = 29.03
```

bs=1 (stream=True)

```bash
locust -t 30s --provider openai -u 1 -r 1 -H http://127.0.0.1:8000 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=Yi-6B-Chat --chat --stream
=================================== Summary ====================================
Provider           : openai
Model              : Yi-6B-Chat
Prompt Tokens      : 521.0
Generation Tokens  : 200
Stream             : True
Temperature        : 1.0
Logprobs           : None
Concurrency        : 1
Time To First Token: 3711.018990400771
Latency Per Token  : 8.0338363266309
Num Tokens         : 199.0
Total Latency      : 5309.75241940032
Num Requests       : 5
Qps                : 0.18570599438259272
================================================================================
Tokens per Second = 199.0 * 1000 / 5309.75241940032 = 37.48
```

### openllm

- openllm: 0.4.36
- transformers: 4.36.0

```bash
openllm start ~/models/Yi-6B-Chat --backend pt
```

bs=4:

```bash
locust -t 30s --provider openai -u 4 -r 4 -H http://127.0.0.1:3000 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=Yi-6B-Chat --chat --tokenizer ~/models/Yi-6B-Chat/
=================================== Summary ====================================
Provider           : openai
Model              : Yi-6B-Chat
Prompt Tokens      : 521.0
Generation Tokens  : 200
Stream             : False
Temperature        : 1.0
Logprobs           : None
Concurrency        : 4
Time To First Token:
Latency Per Token  :
Num Tokens         : 198.83333333333334
Total Latency      : 13084.139803166181
Num Requests       : 6
Qps                : 0.21900756315004455
================================================================================
Tokens per Second = 198.83333333333334 * 1000 / 13084.139803166181 * 4 = 60.79
```

- `--tokenizer ~/models/Yi-6B-Chat/`, to ignore wrong tokenization response from server.

bs=1 (stream=True)

```bash
locust -t 30s --provider openai -u 1 -r 1 -H http://127.0.0.1:3000 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=Yi-6B-Chat --chat --tokenizer ~/models/Yi-6B-Chat/ --stream
=================================== Summary ====================================
Provider           : openai
Model              : Yi-6B-Chat
Prompt Tokens      : 521.0
Generation Tokens  : 200
Stream             : True
Temperature        : 1.0
Logprobs           : None
Concurrency        : 1
Time To First Token: 514.5466244999474
Latency Per Token  : 19.781518579166953
Num Tokens         : 200.0
Total Latency      : 4470.850340333338
Num Requests       : 6
Qps                : 0.2137109537013542
================================================================================
Tokens per Second = 200.0 * 1000 / 4470.850340333338 = 44.73
```

stream=True failed because of the first content is null.

```bash
curl http://127.0.0.1:3000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer EMPTY" \
  -d '{
     "model": "Yi-6B-Chat",
     "messages": [{"role": "user", "content": "Say this is a test!"}],
     "temperature": 0.7,
     "stream": true
   }'
data: {"choices":[{"index":0,"delta":{"role":"assistant","content":null},"finish_reason":null}],"model":"Yi-6B-Chat","object":"chat.completion.chunk","id":"chatcmpl-5ec7180a3f114ea4a5e300fe84bb1d45","created":1141,"usage":null}

data: {"choices":[{"index":0,"delta":{"role":null,"content":"I"},"finish_reason":null}],"model":"Yi-6B-Chat","object":"chat.completion.chunk","id":"chatcmpl-5ec7180a3f114ea4a5e300fe84bb1d45","created":1141,"usage":null}
```

### openllm with ctranlate2 backend

- ctranslate2: 3.23.0

```bash
ct2-transformers-converter --model ~/models/Yi-6B-Chat --output_dir ~/models/Yi-6B-Chat-CT2
openllm start ~/models/Yi-6B-Chat-CT2 --backend ctranslate2
# ValueError: Vocabulary has size 64002 but the model expected a vocabulary of size 64000

```

### OpenLLM PyTorch AutoGPTQ 8bit

```bash
openllm start ~/models/Yi-6B-Chat-8bits --quantize gptq --backend pt
```

bs=4:

```bash
locust -t 30s --provider openai -u 4 -r 4 -H http://127.0.0.1:3000 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=Yi-6B-Chat-8bits --chat --tokenizer ~/models/Yi-6B-Chat/
=================================== Summary ====================================
Provider           : openai
Model              : Yi-6B-Chat-8bits
Prompt Tokens      : 521.0
Generation Tokens  : 200
Stream             : False
Temperature        : 1.0
Logprobs           : None
Concurrency        : 4
Time To First Token:
Latency Per Token  :
Num Tokens         : 199.6
Total Latency      : 16030.683385800512
Num Requests       : 5
Qps                : 0.16886672302718517
================================================================================
Tokens per Second = 199.6 * 1000 / 16030.683385800512 * 4 = 49.8
```

bs=1 (stream=True)

```bash
locust -t 30s --provider openai -u 1 -r 1 -H http://127.0.0.1:3000 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=Yi-6B-Chat-8bits --chat --tokenizer ~/models/Yi-6B-Chat/ --stream
=================================== Summary ====================================
Provider           : openai
Model              : Yi-6B-Chat-8bits
Prompt Tokens      : 521.0
Generation Tokens  : 200
Stream             : True
Temperature        : 1.0
Logprobs           : None
Concurrency        : 1
Time To First Token: 930.1576654997916
Latency Per Token  : 29.186903690066032
Num Tokens         : 199.25
Total Latency      : 6745.946536500924
Num Requests       : 4
Qps                : 0.14105498471447578
================================================================================
Tokens per Second = 199.25 * 1000 / 6745.946536500924 = 29.54
```

### TGI

- TGI: `ghcr.io/huggingface/text-generation-inference:1.3`

```bash
docker run --gpus all --shm-size 1g -p 8080:80 -v $HOME/models:/models ghcr.io/huggingface/text-generation-inference:1.3 --model-id /models/Yi-6B-Chat/
```

bs=4:

```bash
locust -t 30s --provider tgi -u 4 -r 4 -H http://127.0.0.1:8080 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=Yi-6B-Chat --tokenizer ~/models/Yi-6B-Chat/
=================================== Summary ====================================
Provider           : tgi
Model              : Yi-6B-Chat
Prompt Tokens      : 512.0
Generation Tokens  : 200
Stream             : False
Temperature        : 1.0
Logprobs           : None
Concurrency        : 4
Time To First Token:
Latency Per Token  :
Num Tokens         : 201.0
Total Latency      : 4174.993880417333
Num Requests       : 24
Qps                : 0.8994352935752348
================================================================================
Tokens per Second = 201.0 * 1000 / 4174.993880417333 * 4 = 192.58
```

bs=1 (stream=True)

```bash
locust -t 30s --provider tgi -u 1 -r 1 -H http://127.0.0.1:8080 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=Yi-6B-Chat --tokenizer ~/models/Yi-6B-Chat/ --stream
=================================== Summary ====================================
Provider           : tgi
Model              : Yi-6B-Chat
Prompt Tokens      : 512.0
Generation Tokens  : 200
Stream             : True
Temperature        : 1.0
Logprobs           : None
Concurrency        : 1
Time To First Token: 82.72327187569317
Latency Per Token  : 16.344612457709246
Num Tokens         : 201.0
Total Latency      : 3367.9903758752516
Num Requests       : 8
Qps                : 0.28337154388750857
================================================================================
Tokens per Second = 201.0 * 1000 / 3367.9903758752516 = 59.68
```

### TGI eetq 8bits

```bash
docker run --gpus all --shm-size 1g -p 8080:80 -v $HOME/models:/models ghcr.io/huggingface/text-generation-inference:1.3 --model-id /models/Yi-6B-Chat/  --quantize eetq
```

bs=4:

```bash
locust -t 30s --provider tgi -u 4 -r 4 -H http://127.0.0.1:8080 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=Yi-6B-Chat --tokenizer ~/models/Yi-6B-Chat/
=================================== Summary ====================================
Provider           : tgi
Model              : Yi-6B-Chat
Prompt Tokens      : 512.0
Generation Tokens  : 200
Stream             : False
Temperature        : 1.0
Logprobs           : None
Concurrency        : 4
Time To First Token:
Latency Per Token  :
Num Tokens         : 201.0
Total Latency      : 2743.3126421247835
Num Requests       : 40
Qps                : 1.412311945513493
================================================================================
Tokens per Second = 201.0 * 1000 / 2743.3126421247835 * 4 = 293.08
```


bs=1 (stream=True)

```bash
locust -t 30s --provider tgi -u 1 -r 1 -H http://127.0.0.1:8080 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=Yi-6B-Chat --tokenizer ~/models/Yi-6B-Chat/ --stream
=================================== Summary ====================================
Provider           : tgi
Model              : Yi-6B-Chat
Prompt Tokens      : 512.0
Generation Tokens  : 200
Stream             : True
Temperature        : 1.0
Logprobs           : None
Concurrency        : 1
Time To First Token: 63.688626499849
Latency Per Token  : 11.036175770314124
Num Tokens         : 201.0
Total Latency      : 2281.959956332988
Num Requests       : 12
Qps                : 0.41932061487434896
================================================================================
Tokens per Second = 201.0 * 1000 / 2281.959956332988 = 88.08
```

### TGI GPTQ 8bit

```bash
docker run --gpus all --shm-size 1g -p 8080:80 -v $HOME/models:/models ghcr.io/huggingface/text-generation-inference:1.3 --model-id /models/Yi-6B-Chat-8bits/  --quantize gptq
```

run failed:
```
  File "/opt/conda/lib/python3.10/site-packages/text_generation_server/utils/gptq/custom_autotune.py", line 110, in run
    timings = {
  File "/opt/conda/lib/python3.10/site-packages/text_generation_server/utils/gptq/custom_autotune.py", line 111, in <dictcomp>
    config: self._bench(*args, config=config, **kwargs)
  File "/opt/conda/lib/python3.10/site-packages/text_generation_server/utils/gptq/custom_autotune.py", line 93, in _bench
    except triton.compiler.OutOfResources:
AttributeError: module 'triton.compiler' has no attribute 'OutOfResources'

2023-12-13T04:50:46.327283Z ERROR warmup{max_input_length=1024 max_prefill_tokens=4096 max_total_tokens=2048}:warmup: text_generation_client: router/client/src/lib.rs:33: Server error: module 'triton.compiler' has no attribute 'OutOfResources'
Error: Warmup(Generation("module 'triton.compiler' has no attribute 'OutOfResources'"))
```

### TGI AWQ 4bit

```bash
docker run --gpus all --shm-size 1g -p 8080:80 -v $HOME/models:/models ghcr.io/huggingface/text-generation-inference:1.3 --model-id /models/Yi-6B-Chat-4bits/  --quantize awq
```

```bash
locust -t 30s --provider tgi -u 4 -r 4 -H http://127.0.0.1:8080 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=Yi-6B-Chat-4bits --tokenizer ~/models/Yi-6B-Chat/
=================================== Summary ====================================
Provider           : tgi
Model              : Yi-6B-Chat-4bits
Prompt Tokens      : 512.0
Generation Tokens  : 200
Stream             : False
Temperature        : 1.0
Logprobs           : None
Concurrency        : 4
Time To First Token:
Latency Per Token  :
Num Tokens         : 201.0
Total Latency      : 2389.495087416966
Num Requests       : 48
Qps                : 1.6070709188302736
================================================================================
Tokens per Second = 201.0 * 1000 / 2389.495087416966 * 4 = 336.47
```


bs=1 (stream=True)

```bash
locust -t 30s --provider tgi -u 1 -r 1 -H http://127.0.0.1:8080 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=Yi-6B-Chat-4bits --tokenizer ~/models/Yi-6B-Chat/ --stream
=================================== Summary ====================================
Provider           : tgi
Model              : Yi-6B-Chat-4bits
Prompt Tokens      : 512.0
Generation Tokens  : 200
Stream             : True
Temperature        : 1.0
Logprobs           : None
Concurrency        : 1
Time To First Token: 94.83826021460118
Latency Per Token  : 9.332065425378078
Num Tokens         : 201.0
Total Latency      : 1970.583410715595
Num Requests       : 14
Qps                : 0.4837730641324824
================================================================================
Tokens per Second = 201.0 * 1000 / 1970.583410715595 = 102.00
```

### llama-cpp cuda

```bash
git clone https://github.com/abetlen/llama-cpp-python.git
cd llama-cpp-python/docker/cuda_simple
docker build -t llama-cpp-python:cuda .

// or use pip
CMAKE_ARGS="-DLLAMA_CUBLAS=on" pip install llama-cpp-python

docker run --rm --cap-add SYS_RESOURCE -e USE_MLOCK=0 -e MODEL=/var/model/xxx.gguf -v $HOME/models:/var/model -t llama-cpp-python:cuda
```

8bit GGUF:
https://huggingface.co/TheBloke/Yi-6B-GGUF/resolve/main/yi-6b.Q8_0.gguf?download=true

4bit GGUF:
https://huggingface.co/TheBloke/Yi-6B-GGUF/resolve/main/yi-6b.Q4_K_M.gguf?download=true

#### 8bit GGUF

```bash
docker run --rm --cap-add SYS_RESOURCE -e USE_MLOCK=0 --gpus all -e MODEL=/var/model/yi-6b.Q8_0.gguf -v $HOME/models/Yi-6B-GGUF:/var/model -t llama-cpp-python:cuda
```

#### 4bit GGUF

```bash
docker run --rm --cap-add SYS_RESOURCE -e USE_MLOCK=0 --gpus all  -e MODEL=/var/model/yi-6b.Q4_K_M.gguf -v $HOME/models/Yi-6B-GGUF:/var/model -t llama-cpp-python:cuda
```

#### 4bit GGUF with CPU

```bash
docker run --rm --cap-add SYS_RESOURCE -e USE_MLOCK=0 --gpus all  -e MODEL=/var/model/yi-6b.Q4_K_M.gguf -v $HOME/models/Yi-6B-GGUF:/var/model -t ghcr.io/abetlen/llama-cpp-python:latest
```

### lmdeploy

```bash
# install latest lmdeploy
$ pip install -U https://github.com/InternLM/lmdeploy/releases/download/v0.1.0a2/lmdeploy-0.1.0a2-cp310-cp310-manylinux2014_x86_64.whl
# convert and serve
lmdeploy serve api_server ~/models/Yi-6B-Chat --model-name yi --instance_num 32 --tp 1

bs=4:

```bash
locust -t 30s --provider openai -u 4 -r 4 -H http://127.0.0.1:23333 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=yi --chat --tokenizer ~/models/Yi-6B-Chat/
=================================== Summary ====================================
Provider           : openai
Model              : yi
Prompt Tokens      : 521.0
Generation Tokens  : 200
Stream             : False
Temperature        : 1.0
Logprobs           : None
Concurrency        : 4
Time To First Token:
Latency Per Token  :
Num Tokens         : 200.2941176470588
Total Latency      : 3394.2972838823653
Num Requests       : 34
Qps                : 1.145362877124593
================================================================================
Tokens per Second = 200.2941176470588 * 1000 / 3394.2972838823653 * 4 = 236.03

```

bs=1 (stream=True)

```bash
locust -t 30s --provider openai -u 1 -r 1 -H http://127.0.0.1:23333 -p 512 -o 200 --prompt-randomize --api-key EMPTY --model=yi --tokenizer ~/models/Yi-6B-Chat/ --stream
=================================== Summary ====================================
Provider           : openai
Model              : yi
Prompt Tokens      : 512.0
Generation Tokens  : 200
Stream             : True
Temperature        : 1.0
Logprobs           : None
Concurrency        : 1
Time To First Token: 76.80950477775797
Latency Per Token  : 14.349937231366368
Num Tokens         : 198.44444444444446
Total Latency      : 2924.3993964444903
Num Requests       : 9
Qps                : 0.3306512429762835
================================================================================
Tokens per Second = 198.44444444444446 * 1000 / 2924.3993964444903 = 67.86
```

```bash
# 转换格式，可以看到确实保持 fp16 精度不变。
$ lmdeploy convert ~/models/Yi-6B-Chat --model-name yi --model-format hf
```
