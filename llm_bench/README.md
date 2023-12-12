# LLM Load test

## Installation

The load test relies on [Locust package](https://locust.io/). Install it from pip.

```bash
pip install -r requirements.txt
```

Then run the commands described below from the enclosing directory. Locust will pick up the settings from `locust.conf` automatically.

## Usage

The load test script exercises LLM generation endpoint under varying load. See below for the common configuration options. Check `--help` for the full list.

### Target

- `-H`: target endpoint URL (preceding `/v1/...`). E.g. `-H http://localhost` or `-H https://api.fireworks.ai/inference`. Defaults to `localhost:80`.
- (optional) `-m`: model to send requests too. Can be omitted for a local test if the server has a single model loaded only.
- (optional) `--provider`: provider name like `fireworks` or `openai`. APIs have slight differences that the script accounts for. If omitted the script tries to guess based on URI and API return information. Must be specified for non-OpenAI-compatible providers like Triton.
- `-k`: API key to be passed as `Authorization: Bearer ...`.

### Rate of requests

There are several primary modes the script can be used:

1. **Fixed concurrency**. N workers are created. Each sends a request, waits for the response and then sends the next request. Thus as concurrency increases, the server will get more loaded and latency will grow. Usually increasing concurrency beyond some point doesn't increase throughput and just leads to growing latency.
   - `-u`: the number of concurrent workers to spawn (standard Locust argument)
   - `-r`: the rate per second of spawning concurrent workers. If processing workload takes a while (more than several seconds), it makes sense to set this value to something lower than `-u` for a gradual ramp-up to avoid request bursts.
   - (optionally) `--burst <period in seconds>`: synchronizes all N workers to issue requests in one go with the specified interval. The maximum latency should be less than the period, otherwise some workers may fall behind.

2. **Fixed QPS**. The script ensures that input requests are issued at specific times to average out at the specified rate per second. If the target QPS is too high and the server is overloaded it will likely drop additional requests or stall.
   - `--qps`: the desired rate of requests per second. Can be a fractional number, e.g. `0.1`.
   - `-u <high number> -r <high number>`: needs to be set to a sufficiently high value to allow generating the target QPS. The script will complain if it's too low. Passing something like `-u 100 -r 100` is a good choice.
   - (optional) `--qps-distribution`: specify how to space out requests. Default is `constant` meaning evenly spaced out. `exponential` is an option simulating [Poisson distribution](https://en.wikipedia.org/wiki/Traffic_generation_model#Poisson_traffic_model).

### Workload

The tool currently supports only a fixed prompt specified as one of:
- `-p`: prompt length in tokens. The script will generate some prompt of this length.
- `--prompt-text`: use the specified text as a prompt instead of generating one. It can be a file reference starting with an ampersand, e.g. `@prompt.txt`.

The number of tokens to generate is sampled on every request from a given distribution:
- `-o`/`--max-tokens`: maximum number of tokens to generate. If --max-tokens-distribution is non-constant this is going to be the mean of the distribution.
- `--max-tokens-distribution`: specifies probability distribution to use.
- `--max-tokens-range` Specifies "the width" of the distribution (e.g. stddev for "normal" distribution). Specified value `alpha` is relative to `max-tokens`. Default is 0.3 so most of the range falls in "3 sigma" region.
- `--max-tokens-cap`: specify upper bound to "truncate" the probability distribution. The lower bound is always 1 token. This allows to sample from "truncated normal" or "truncated exponential" distributions.

Based on the above settings the following distributions are supported:
- `constant`: use `--max_tokens` value on every request
- `uniform`: sample from the range `[max_tokens - max_tokens * alpha, max_tokens + max_tokens * alpha]`
- `normal`: sample from gaussian distribution `N(max_tokens, max_tokens * alpha)`
- `exponential`: sample from exponential distribution with the mean `max_tokens`. `alpha` is ignored

The benchmark makes the best effort to ensure the desired `max_tokens` number is respected:
- for providers that support it, it passes `ignore_eos` or `min_tokens` parameter to avoid early stopping
- the default prompt is a lengthy code generation request that usually doesn't stop early
- it verifies the number of tokens actually generated and prints warnings on mismatch. Different providers use varying mechanisms of returning generated number of tokens. For some of them `--logprobs` might be needed in the streaming mode.
- optionally, `--tokenizer` can be passed specifying Huggingface tokenizer to be used to count the output tokens on client side.

Generation options:
- `--chat`: specify to call chat API instead of raw completions
- `--stream`: stream the result back. Enabling this gives "time to first token" and "time per token" metrics
- (optional) `--logprobs`: corresponds to `logprobs` API parameter. For some providers, it's needed for output token counting in streaming mode.
- `--max-tokens-jitter`: how much to adjust randomly the setting of `-o` at each request. When using "fixed concurrency" mode it's useful to avoid all workers implicitly synchronizing and causing periodic traffic bursts.

### Writing results

Locust prints out the detailed summary including quantiles of various metrics. Additionally, the script prints out the summary block at the very end of the output that includes the model being tested.

When comparing multiple configurations, it's useful to aggregate results together:

- `--summary-file`: Append the line with the summary to the specified CSV file. Useful for generating a spreadsheet with perf sweep results. If the file doesn't exist, it writes out the header first.
- `-t`: duration (e.g. `5min`) for which to run the test (standard Locust option). It's particularly useful when scripting multiple runs. By default, the test runs without a limit until Ctrl+C is pressed.

The typical workflow would be to run benchmark several times appending to the same CSV file. The resulting file can be imported into a spreadsheet or pandas for further analysis.

## Examples

Maintain fixed 8 requests concurrency against local deployment:

```bash
locust -u 8 -r 2 -p 512 -o 128
```

Call streaming chat API locally with the request issued every 2 seconds. Run for 1 minute and save results to `results.csv`:

```bash
locust -t 1min -u 100 -r 100 -p 512 -o 128 --stream --chat --qps 0.5 --summary-file results.csv
```

Benchmark Fireworks public deployment deployment with 1 request only:

```bash
locust -u 1 -H https://api.fireworks.ai/inference -p 128 -o 200 --api-key $FIREWORKS_API_KEY --model=accounts/fireworks/models/llama-v2-7b
```

Benchmark OpenAI deployment with 1 request only:

```bash
locust -u 1 -H https://api.openai.com -p 128 -o 200 --api-key $OPENAI_API_KEY --model=gpt-3.5-turbo --chat
```

Benchmark local Triton deployment with a given prompt at 1 QPS:

```bash
locust -u 100 -r 100  --prompt-text "$PROMPT" -o 100 --provider triton-infer -H http://localhost:8000 --tokenizer /path/to/my/hf/tokenizer --qps 1
```


## UI mode

Instead of relying on textual data, it's also possible to plot the results in Grafana.

```bash
pip install locust locust-plugins
locust-compose up
```

This starts your local Postgre and Grafana. Grafana is available at http://127.0.0.1:3000 (sometimes logs don't print out).

Then run the test as specified above with an additional argument:

```bash
locust --config locust-grafana.conf ...
```

This starts the load test locally and pushes results into Grafana in real-time. Besides the actual requests, we push additional metrics (e.g. time per token) as separate fake requests to get stats aggregation. Make sure to remove them from aggregation when viewing the graphs.

Other settings for Locust are in `./locust.conf`. You may start Locust in non-headless mode, but its UI is very basic and misses advanced stats aggregation capabilities.
