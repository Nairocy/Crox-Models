# NOTICE

## 基座模型

- **模型**：[`huihui-ai/Huihui-Qwen3.5-4B-abliterated`](https://huggingface.co/huihui-ai/Huihui-Qwen3.5-4B-abliterated)
- **上游**：[`Qwen/Qwen3.5-4B`](https://huggingface.co/Qwen/Qwen3.5-4B)
- **许可证**：`apache-2.0`（见基座模型卡的 `license` / `license_link` 字段）

## 本仓库的谱系

| 本仓库 adapter | 训练时使用的 base（合并权重） |
|---|---|
| `p2` | `merged-crox-p1v3` — P1 系列 LoRA 合并得到的中间权重 |
| `t2` | `merged-crox-t1v2` — T1 系列 LoRA 合并得到的中间权重 |

两代之间是「合并 → 再训练」的链式关系，最终都回溯到同一个基座 `Huihui-Qwen3.5-4B-abliterated`。

## 许可证

本仓库的 LoRA adapter、配置与脚本以 **Apache-2.0** 提供（见 [`LICENSE`](LICENSE)），
同时必须遵守基座模型及其上游 Qwen 的许可条款。

## 内容安全

基座经过 abliterated 处理（移除部分拒答行为），模型可能对敏感提示不设防。
使用方需自行承担内容审核与合规责任。
