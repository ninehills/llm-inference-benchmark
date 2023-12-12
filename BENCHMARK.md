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

### openllm int8

```bash
openllm start ~/models/Yi-6B-Chat --backend pt --quantize int8
```

not work ...

### TGI

- TGI: `ghcr.io/huggingface/text-generation-inference:1.3`
