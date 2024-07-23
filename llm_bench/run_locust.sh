model_name=moe_as_en_mixtral_struct_mem_v1_0626_fp8
service_name=test_moe_as_mem_v1_0626_fp8_vllm
token='NjRhMWVhMDQ3NzllYTMxYjEyNGJmZTY2YWI3ZWNmOWU4ZTAwYzBkYg=='

locust --prompt-randomize --prompt-text "@prompt.txt" --qps 5 -u 10 -r 10 -t 40s --provider openai -H http://1893706806886638.cn-beijing.pai-eas.aliyuncs.com/api/predict/${service_name} -p 1250 -o 512 --api-key $token --model=$model_name --no-chat --stream
