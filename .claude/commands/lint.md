---
description: "用于维基巡检、检查矛盾、查找孤儿页面、检查空白/遗漏、检查索引/路由器一致性的请求。对应「巡检一下维基」「看看有没有矛盾」「找出缺漏」「检查孤儿页面」「看看索引对不对」之类的请求。其中，资料收集用 /ingest，维基化用 /compile，提问用 /query。"
---

# /lint — 巡检 (健康检查)

巡检维基健康。维基越大，矛盾·孤儿·空白·索引不一致越会堆积，故定期执行。可自动修复部分（高信任）就修复，需要人判断的项目则留为报告。

## 用法

```text
/lint            (维基全体)
/lint [主题]     (仅特定主题)
```

## 执行流程

### Step 1: 完整性 — 链接·矛盾·孤儿
- **矛盾**：用 `grep -rn "⚠️ Contradiction" 30-wiki/` 全量收集未解决的矛盾。stale 主张（未反映最新源）也算。
- **失效链接**：`[[X]]` 指向的页面不存在 → 降级为 plain text 或（若有种子）作为 lazy 候选报告。
- **孤儿页面**：入站 `[[链接]]` 为 0。
- **同名冲突**：同一名称存在于多个文件夹/类型 → 用 `[[type/名称|名称]]` 路径链接 disambiguate + 确认是否**毫无遗漏地登记到路由器同名冲突注记**。

### Step 2: 索引·路由器一致性 (★ 路由完整性)
- **索引不一致**：页面不在类型索引 `indexes/{type}.md`（源在 `sources/index.md`）中，或索引里有但文件不存在。类型↔文件夹对齐。
- **路由器↔索引一致性**：主题路由器 `index.md` 各类型的**数量·页脚合计**是否与实际条目数一致，路由表里的索引/分片链接是否都存在，**条目是否按首字母在正确的分片**中（边界违规 0）。
- **分片 token 上限**：各索引分片是否 **≤50K token**（超出则建议/执行按首字母边界重新分片）。
- **aliases 一致性**：实体 `canonical`/`aka` 是否登记到 `aliases.md`。

### Step 3: tier·provenance 同步
- `tier: auto` 页面是否都登记到 `auto-generated.md` 总账 + 对应类型索引。reviewed 提升时三处一致。
- 无 provenance 的事实主张，`inferred`/`ambiguous` 未解决项目。

### Step 4: 空白 — 概念遗漏
- 在 `20-raw/`·`sources/` 出现 ≥2 次但维基中没有页面的实体/概念（提升候选）。
- `status: stub` 中需要补强的部分。

### Step 5: drift — 命令↔schema
- `.claude/commands/*.md` 流程是否与 `CLAUDE.md`·`conventions.md` 规约不符（例如 query 是否读 aliases，compile 是否更新 overview/index）。
- **(有 .rag 时)** 用 state↔维基 diff 探测未索引·stale，做 eval 回归巡检。无 `.rag` 则 skip。

### Step 6: 卫生
- frontmatter（`summary`/`tier`/`provenance`）缺失、无 BLUF 的页面、超过 ~1,500 token 的页面。

### Step 7: 报告 + 修复
- 可自动修复部分（索引登记遗漏、明显的链接错字、降级为 plain text）立即修复。
- 需要人判断部分（矛盾、废弃候选、疑似幻觉、调查建议）以列表形式留在 `30-wiki/{topic}/reports/{YYYY-MM-DD}-lint.md`（或 90-archive 邻近处）。
- 在 `log.md` 添加 `## [YYYY-MM-DD] lint | {发现 N / 修复 M}`。

## 输出格式

```text
🔍 lint 报告 ({范围})

完整性: 矛盾 {n} · 失效链接 {n} · 孤儿 {n} · 同名 {n}
索引·路由器: 不一致 {n} · 数量 mismatch {n} · 分片超限 {n} · aliases 缺失 {n}
tier/provenance: auto 未登记 {n} · 无 provenance 的主张 {n}
空白: 提升候选 {n} · stub {n}
drift: 命令↔schema {n}
卫生: frontmatter 缺失 {n} · 过大页面 {n}

自动修复: {m} 件 / 需人判断: {列表}
```

## 触发边界

should-trigger: "巡检一下维基", "检查矛盾", "找出孤儿页面", "看看索引对不对", "看看一致性"
NOT-trigger:
- "把这个源放进去" → `/ingest`
- "整理成维基" → `/compile`
- "告诉我 X" → `/query`

## 参考
- `00-system/conventions.md` §5·§6·§7·§8·§10·§13 — 链接·矛盾·路由器·分片·tier·provenance
- `30-wiki/log.md` — 最近作业历史
