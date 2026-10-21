# P2 — 角色线 LoRA

- 基座：`merged-crox-p1v3`（原始基座 `Huihui-Qwen3.5-4B-abliterated`）
- 配置：LoRA r=16 / alpha=32 / dropout=0.05
- 权重：`adapter_model.safetensors`（~122 MB）在本仓库 **Releases** 附件里

## 加载

```python
from peft import PeftModel
from transformers import AutoModelForCausalLM, AutoTokenizer

base = AutoModelForCausalLM.from_pretrained("Huihui-Qwen3.5-4B-abliterated")
tok  = AutoTokenizer.from_pretrained("Huihui-Qwen3.5-4B-abliterated")
model = PeftModel.from_pretrained(base, "./p2")
```

训练时的对话模板见同目录 `chat_template.jinja`。
