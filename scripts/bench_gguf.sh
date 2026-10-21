#!/usr/bin/env bash
# 显存画像 + 速度实测：对给定 GGUF 跑 ctx 4k/8k/16k 的 buffer 日志与 llama-bench
# 用法: bash scripts/bench_gguf.sh <gguf文件> [标签]
set -u
BIN="D:/Other/LLM/llama_bin/cuda"
F="$1"
L="${2:-$(basename "$F")}"
echo "############ $L ############"
for C in 4096 8192 16384; do
  echo "== probe ctx=$C =="
  "$BIN/llama-cli.exe" -m "$F" -ngl 99 -c "$C" -st -p "一" -n 2 2>&1 \
    | grep -E "buffer size|KV self|n_ctx " | head -12
done
echo "== bench (pp512 / tg128, ngl=99) =="
"$BIN/llama-bench.exe" -m "$F" -ngl 99 -p 512 -n 128
echo BENCH_DONE
