---
description: "用于把 inbox 源精炼、维基化、整理、编译为维基的请求。对应「整理成维基」「编译一下」「精炼一下」「处理 inbox」「反映到维基」之类的请求。compile 读取 inbox 中未编译的源，合成为维基页面，更新 index·aliases·overview 后把原文移到 raw。其中，资料收集用 /ingest，提问用 /query，巡检用 /lint。"
---

# /compile — 精炼 (inbox 源 → 维基)

读取 `10-inbox/` 中未编译的源，合成为维基页面，**更新路由器·类型索引·aliases·overview** 后把原文移到 `20-raw/`。这不是简单复制，而是更新既有页面·交叉引用·规范化·矛盾标注。

## 用法

```text
/compile                                   (inbox 中全部未编译源)
/compile 10-inbox/2026-06-14-article.md    (仅特定源)
```

## 执行流程

### Step 1: 现状 + 识别未编译
- 用 `30-wiki/index.md`（根路由器）·`log.md` 掌握既有主题·页面。
- `10-inbox/` 中的源 = 未编译（若有参数则仅处理该源）。
- 确定该源属于哪个**主题(topic)**（优先复用既有）。若是新主题则创建 `30-wiki/{topic}/` 骨架：`index.md`（主题路由器）·`aliases.md`·`overview.md`·`indexes/`·`sources/`·`entities/`·`concepts/`。

### Step 2: 读取源 + 核心 (苏格拉底门控)
- 读取源。若是图片/PDF 则按 `conventions.md §12` 两步读取。
- 分享 3~5 个核心 takeaway，并**指出矛盾·弱点·依据不足来反问**（批处理模式则省略）。只有打磨后的结论才提升为维基。

### Step 3: 源摘要页面
- `40-templates/source.md` → `30-wiki/{topic}/sources/{date-slug}.md`。
- frontmatter `source_file` 记录**移动后路径**（`20-raw/{文件名}`）（在 Step 7 移动）。`summary` 必填（索引复用）。

### Step 4: 实体/概念页面 (规范化 + 重复检查)
- 为源中出现的人物·组织·概念逐一创建/更新页面。**当多个源累积后，仅全局出现 ≥2 次才提升为页面**，1 次则作为上级页面的 plain text 种子（提问时 lazy）。若是单一源则以核心实体为中心。
- **创建前做重复检查**：用该类型索引（`indexes/{type}.md`）+ `aliases.md` 检查相同写法/别名 → 若已存在则**不要新建，而是更新·合并**（更新规范名·aka·aliases）。
- **决定规范名（`canonical`）** → 在 `aliases.md` 登记别名（路由键）。
- 每个事实主张后附 `[[sources/...]]` provenance（`extracted`/`inferred`/`ambiguous`）。无出处的推断标 `(推断)`。同名用 `[[type/名称|名称]]` 路径链接 + 路由器冲突注记。
- `[[链接]]` **仅在目标页面实际存在时**才用，否则用 plain text（种子）。

### Step 5: 索引·综合更新 (路由的核心)
- 在**类型索引** `indexes/{type}.md` 登记新增/变更页面行 —— 行 description 复用页面 `summary`。**若分片超过 ≤50K token 则按规范名首字母重新分片**（非拉丁文进第二分片）。
- **主题路由器** `{topic}/index.md`：仅更新各类型的**数量·同名冲突注记·页脚合计**（实体行不放进路由器）。
- **根路由器** `30-wiki/index.md`：若是新主题则添加主题行。
- 更新 `overview.md`（全局图景）。

### Step 6: self-audit
- 确认所创建的实体/概念页面 vs 类型索引登记 = **diff 0**（无遗漏）。
- `tier: auto` 页面登记到 `30-wiki/{topic}/auto-generated.md` 总账（标为未审核）。

### Step 7: 把原文移到 raw (保管)
- `mv 10-inbox/{文件} 20-raw/{文件}`。**保留文件名**（保住 Step 3 的 `source_file` 链接）。
- 留在 inbox 的 = 未编译，在 raw 的 = 编译完成。
- 同名冲突·移动失败时不要覆盖，而是通知。

### Step 8: 日志 + 提交
- 在 `log.md` 写 `## [YYYY-MM-DD] compile | {标题或规模}` + 改动页面列表。
- 若是 git repo 则 `git add -A && git commit`。

## 输出格式

```text
✅ compile 完成: {标题/规模}
主题: {topic}
- 源摘要: sources/{slug} ×N
- 实体/概念: entities/{...} ×N, concepts/{...} ×M (新增 {a} / 更新 {b})
- aliases 登记: {k} 件 · 同名冲突: {n} 件
- 索引更新: indexes/{type} (分片 {s})
- self-audit: 遗漏 0
- 原文移动: 10-inbox → 20-raw/{...}
```

## 触发边界

should-trigger: "整理成维基", "编译", "精炼一下", "处理 inbox", "反映到维基"
NOT-trigger:
- "收集/放入这份资料"（只保存） → `/ingest`
- "告诉我 X" → `/query`
- "巡检/检查矛盾" → `/lint`
- "改一下原文" → 禁止 (raw 不可变)

## 参考
- `00-system/conventions.md` §4(规范化)·§7(路由器)·§8(分片)·§10(lazy/tier)·§14(苏格拉底)
- `40-templates/` — source/entity/concept 模板
