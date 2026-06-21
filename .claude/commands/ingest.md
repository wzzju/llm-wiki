---
description: "用于收集新资料、放入资料、把 URL/文件/文本放进维基的请求。对应「把这个放进维基」「收集这份资料」「抓取这个 URL」「放入这个 PDF」之类的请求。ingest 只把资料保存到 inbox，精炼为维基页面由 /compile 负责，提问用 /query，巡检用 /lint。"
---

# /ingest — 收集 (只保存)

把资料作为新文件**只保存**到 `10-inbox/`。**不创建维基页面** —— 那是 `/compile` 的工作（保存与精炼分离）。保存的源以「未编译」状态堆积在 inbox，由 `/compile` 精炼为维基后再移动到 `20-raw/`。

## 用法

```text
/ingest [URL | 文件路径 | 粘贴的文本]
/ingest https://example.com/article
/ingest ~/Downloads/paper.pdf
```
> 用户也可以直接把文件丢进 `10-inbox/`（这种情况下无需 `/ingest`，直接 `/compile`）。

## 执行流程

### Step 1: 获取
- **URL** → fetch 正文并转换为 markdown。（若 WebFetch 因 SPA·反爬封锁而失败，请请求用户粘贴正文，或使用已有的抓取工具。）
- **文件路径** → 读取并取入。图片·PDF 附件保存到 `20-raw/assets/`（永久资产）。
- **文本** → 原样取入。

### Step 1.5: 格式转换 (二进制 → markdown)
docx·pptx·xlsx·复杂 PDF Claude 无法直接读取，故转换为 markdown 放入 inbox（原始二进制文件保管在 `20-raw/assets/`）。按扩展名路由 —— 正本：`conventions.md §12`：
- `.md`/`.txt`/`.html` → 原样。
- `.docx`/`.pptx`/`.xlsx` → `markitdown <文件> > 10-inbox/{slug}.md`（首选，本地·免费）。若没有则提示 `pip install 'markitdown[all]'`。
- `.pdf` → 文本型由 Claude 直接 Read，扫描/复杂表格用 markitdown。
- 表格·版式复杂 + 有 `LLAMA_CLOUD_API_KEY` → 用 LlamaParse 做高质量转换（fallback）。无密钥则用 markitdown。
- 若没有任何工具，不要卡住，而是提示安装或请求「以文本粘贴」。

### Step 2: 保存到 inbox
- 以**新文件名**保存到 `10-inbox/{YYYY-MM-DD}-{slug}.md`。
- 若是同一份资料的更新，用 `-v2` 这样的新名称（禁止覆盖）。
- 在文件顶部的 frontmatter 中留下出处（原始 URL/路径）·收集日期。

### Step 3: 通知 (不做维基化)
- **不创建维基页面** —— 只保存。
- 在 `30-wiki/log.md` 写一行 `## [YYYY-MM-DD] ingest | {标题}`。
- 提示「inbox 中有 N 个未编译源待处理 → 请用 `/compile` 维基化」。

## 触发边界

should-trigger: "把这份资料放进去", "收集一下", "抓取这个 URL", "放入这个 PDF"
NOT-trigger:
- "整理成维基" / "精炼一下" / "编译" → `/compile`
- "你了解 X 吗?" → `/query`
- "巡检一下维基" → `/lint`
- "改一下原文" → 禁止 (raw 不可变)

## 参考
- `/compile` — 把 inbox 源精炼为维基页面 + 移动到 raw
- `00-system/conventions.md` — 页面·索引·路由规约
