# Crox Models

> 两条基于 Qwen3.5-4B 的 LoRA 微调线：**P2**（角色化对话）与 **T2**（通用对话）。
> 同一条数据链路上训练出的两个「人格/风格」分支。

这两个 adapter 是 [Crox](https://github.com/Nairocy/Crox)（Android 客户端）背后的本地模型线的公开部分。
完整权重是 4B 级的 F16 GGUF（~8.4 GB）与 Q4_K_M（~2.7 GB），本仓库只放 **adapter 与可复现的训练/导出脚本**。

## 谱系

```
Qwen3.5-4B-abliterated
├── P1 → P1v2 → P1v3 → P2     角色线（persona，带情绪标签）
└── T1 → T1v2 → T2            通用线
```

- **P2**：在 `merged-crox-p1v3` 上继续训练，面向角色化/带情绪的对话
- **T2**：在 `merged-crox-t1v2` 上继续训练，面向通用对话

两代之间是「合并 → 再训练」的链式关系，所以 P2 的 base 不是原始基座，而是 P1v3 的合并权重
（P1 系列未单独发布；如需严格复现链条，请按 `scripts/merge_adapter.py` 自行合并）。

## 训练配置（实测值）

| 项 | 值 |
|---|---|
| 方法 | LoRA（PEFT，`CAUSAL_LM`） |
| rank `r` | 16 |
| `lora_alpha` | 32 |
| `lora_dropout` | 0.05 |
| `bias` | none |
| target_modules | `q_proj` · `k_proj` · `v_proj` · `o_proj` · `gate_proj` · `up_proj` · `down_proj` · `in_proj_qkv` · `in_proj_z` · `out_proj`（含 Qwen3.5 混合层的投影） |
| 基座 | `Huihui-Qwen3.5-4B-abliterated`（[HF](https://huggingface.co/huihui-ai/Huihui-Qwen3.5-4B-abliterated)） |

## 文件

```
p2/   adapter_config.json · chat_template.jinja · tokenizer*  （权重在 Releases）
t2/   同上
scripts/  merge_adapter.py · gguf_export.sh · bench_gguf.sh
```

**`adapter_model.safetensors`（~122 MB/个）在 [Releases](../../releases) 里**——它超过 GitHub 单文件 100 MB 限制。

## 用法

### 1. 合并成完整权重

```bash
python scripts/merge_adapter.py \
  --base  Huihui-Qwen3.5-4B-abliterated \
  --adapter ./p2 \
  --out   ./merged-crox-p2
```

### 2. 导出 GGUF（llama.cpp）

```bash
bash scripts/gguf_export.sh ./merged-crox-p2 crox-p2
# 产出 m-crox-p2-f16.gguf（~8.4G）与 m-crox-p2-q4_k_m.gguf（~2.7G）
```

### 3. 直接推理

```bash
llama-cli -m m-crox-p2-q4_k_m.gguf -p "你好" -n 256
```

或按 `p2/chat_template.jinja` 的模板构造 prompt——**不要换模板**，训练时就是这一份。

## 没有放进仓库的东西

- **训练语料**：包含私人对话记录，不公开
- **合并后的权重与 GGUF**：体积过大，走 Releases / 外部存储

## 基座与许可证

- **基座**：[`huihui-ai/Huihui-Qwen3.5-4B-abliterated`](https://huggingface.co/huihui-ai/Huihui-Qwen3.5-4B-abliterated)
  （uncensored 版 [`Qwen/Qwen3.5-4B`](https://huggingface.co/Qwen/Qwen3.5-4B)，其模型卡标注 `license: apache-2.0`）
- **本仓库**：LoRA adapter 与脚本随基座一并以 [Apache-2.0](LICENSE) 提供

使用时请同时遵守基座模型与其上游 Qwen 的许可条款。
