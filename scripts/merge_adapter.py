#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""合并 LoRA adapter 到基座 → 完整 HF 模型目录（默认 bf16，CPU 上进行，省显存）。

用法（工作目录 D:/Other/LLM/finetune）:
  venv/Scripts/python.exe scripts/merge_adapter.py \
      --base models/Huihui-Qwen3-4B-Instruct-2507-abliterated \
      --adapter out/lora-v1 \
      --out out/merged-v1

说明:
- 16G 内存下 4B bf16 合并可行（约 10G 峰值），显存不参与
- 产物用于 convert_hf_to_gguf.py 转 GGUF
"""
import argparse

import torch
from peft import PeftModel
from transformers import AutoModelForCausalLM, AutoTokenizer


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", required=True, help="基座模型目录")
    ap.add_argument("--adapter", required=True, help="LoRA adapter 目录")
    ap.add_argument("--out", required=True, help="输出目录（完整模型）")
    ap.add_argument("--dtype", default="bf16", choices=["bf16", "fp16"])
    args = ap.parse_args()

    dt = torch.bfloat16 if args.dtype == "bf16" else torch.float16
    print(f"[merge] base={args.base} adapter={args.adapter} dtype={args.dtype} (CPU)")
    kw = dict(low_cpu_mem_usage=True)
    try:
        model = AutoModelForCausalLM.from_pretrained(args.base, dtype=dt, **kw)
    except TypeError:
        model = AutoModelForCausalLM.from_pretrained(args.base, torch_dtype=dt, **kw)

    model = PeftModel.from_pretrained(model, args.adapter)
    model = model.merge_and_unload()
    model.save_pretrained(args.out, safe_serialization=True)
    AutoTokenizer.from_pretrained(args.base).save_pretrained(args.out)
    print(f"MERGED -> {args.out}")


if __name__ == "__main__":
    main()
