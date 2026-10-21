#!/usr/bin/env bash
# 正式导出：adapter → merged(bf16) → f16 GGUF → q8_0 + q4_k_m
# 用法: bash scripts/gguf_export.sh [adapter_dir] [tag]
#   默认: adapter=out/lora-v1  tag=v1
# 可续跑：已完成步骤按产物存在跳过
set -u
cd "D:/Other/LLM/finetune"
PY=venv/Scripts/python.exe
CONV="D:/Other/LLM/llama.cpp/convert_hf_to_gguf.py"
BIN="D:/Other/LLM/llama_bin/cuda"
ADAPTER="${1:-out/lora-v1}"
TAG="${2:-v1}"
BASE="${3:-models/Huihui-Qwen3-4B-Instruct-2507-abliterated}"
MERGED="out/merged-$TAG"
GG="out/gguf-$TAG"
mkdir -p "$GG"

[ -f "$MERGED/model.safetensors.index.json" ] || [ -f "$MERGED/model.safetensors" ] || {
  echo "== [1/4] merge adapter -> $MERGED =="
  "$PY" scripts/merge_adapter.py --base "$BASE" \
      --adapter "$ADAPTER" --out "$MERGED" || exit 1
}
[ -f "$GG/m-$TAG-f16.gguf" ] || {
  echo "== [2/4] convert -> f16 =="
  "$PY" "$CONV" "$MERGED" --outfile "$GG/m-$TAG-f16.gguf" --outtype f16 || exit 1
}
[ -f "$GG/m-$TAG-q8_0.gguf" ] || {
  echo "== [3/4] quantize -> q8_0 =="
  "$BIN/llama-quantize.exe" "$GG/m-$TAG-f16.gguf" "$GG/m-$TAG-q8_0.gguf" q8_0 || exit 1
}
[ -f "$GG/m-$TAG-q4_k_m.gguf" ] || {
  echo "== [4/4] quantize -> q4_k_m =="
  "$BIN/llama-quantize.exe" "$GG/m-$TAG-f16.gguf" "$GG/m-$TAG-q4_k_m.gguf" q4_k_m || exit 1
}
echo GGUF_EXPORT_DONE
