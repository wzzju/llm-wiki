# 维基页面·索引·路由规约 (正本)

> `CLAUDE.md` § 领域框架的详细正本。LLM 在编写或更新页面、或向维基提问时遵循此规约。修改规约时在此处修改并记录到 `_meta/changelog.md`。

---

## 0. 核心模型 — 路由器·分片·规范化 (先读)

LLM Wiki 的检索不是"全部读取"，而是**路由**。即使维基增长到数千个页面，目标也是让**每次查询读取的 token 几乎保持恒定**。为此设有 4 根支柱：

1. **index = 路由器(MOC)**，不是目录。`index.md` 不是"所有页面的列表"，而是决定**"提问意图 → 展开哪个类型/分片"**的轻量入口。实体行不放在 index 中。
2. **按类型的子索引 + 分片。** 实际的实体目录放在 `indexes/{type}.md`。某个类型变大时，**按规范名首字母拆成 ≤50K token 的分片** (§8)。
3. **规范化(aliases)。** 把写法不一致(Parasite/寄生虫, 甜茶/Timothée Chalamet)归并到**单个规范名**。规范名即**分片路由键** (§4)。
4. **2 段路由 (Phase A / Phase B)。** 提问处理把"决定打开哪里(Route，不读分片)"与"读取指定分片·页面(Search)"分离 (§9)。路由不读分片，分片的 token 节省才能得到保障。

> 规模小时这套结构看似过度，但**只有从一开始就把机制嵌入**，数据累积时才能自然地沿着 路由器→类型索引→分片 的路径成长。小规模时，一个层级可以兼任下一个层级 (§9 成长路径)。

---

## 1. 页面类型

| 类型 | frontmatter `type` | 位置 | 1:1 对象 |
|------|--------------------|------|----------|
| 源摘要 | `source` | `30-wiki/{topic}/sources/` | 每个 raw 源 1 页 |
| 实体 | `entity` | `30-wiki/{topic}/entities/` | 人物·组织·地点·产品·作品 |
| 概念 | `concept` | `30-wiki/{topic}/concepts/` | 理论·方法论·术语 |
| 类型索引 | `index` | `30-wiki/{topic}/indexes/{type}.md` | 每个类型 1 个(+分片) |
| 主题路由器 | `index` | `30-wiki/{topic}/index.md` | 每个主题 1 个 |
| 根路由器 | `index` | `30-wiki/index.md` | 整个维基 1 个 |
| 综合概览 | `overview` | `30-wiki/{topic}/overview.md` | 每个主题 1 个(可选) |
| 规范词典 | `aliases` | `30-wiki/{topic}/aliases.md` | 每个主题 1 个 |
| query 回写 | `query` | `50-queries/` | 有价值的查询结果 |

**领域细分(可选):** `entity` 增多时可按领域分为子类型(例如：电影领域 → `people`/`works`/`series`)。此时文件夹·索引也按类型分离。默认从单个 `entity` 开始，某一种超过数十个时考虑分离。

**信任等级(tier):** 所有实体/概念页面都标注 `tier` — `reviewed`(原文提取·人工确认) 或 `auto`(网络/推理 lazy 生成、未检验)。`auto` 登记到 `auto-generated.md` 总账 (§10)。

---

## 2. frontmatter 规范 (按类型)

### source
```yaml
type: source
title: "源原标题"
source_file: 20-raw/2026-06-14-article.md   # 处理完成的原始文件反向引用 (compile 移入 raw 后的路径)
topic: "主题 slug"
summary: "1~2 句 + 检索关键词 5~10 个"   # 该句子复用为 sources/index 的行
ingested: 2026-06-14
author: ""        # 如有
url: ""           # 如有
tags: []
provenance: extracted
```

### entity / concept
```yaml
type: entity            # 或 concept
canonical: "规范名"      # 路由键 (首字母决定分片)
aka: []                 # 同一对象的其他写法 (也登记到 aliases.md)
topic: "主题 slug"
summary: "1~2 句 + 关键词 5~10 个"   # ★ 该句子原样复用为 indexes/{type}.md 的行 description
tags: []
sources: []             # 支撑本页的 raw/源 id
tier: reviewed          # reviewed | auto
provenance: extracted   # extracted | inferred | ambiguous | web-enriched
status: active          # active | stub | deprecated
updated: 2026-06-14
```

`summary` 是**索引的源头** — 写得好索引就会自动变好。务必包含 1~2 句定义 + 检索关键词。

---

## 3. 页面正文骨架 (固定章节)

为了在 ingest/compile 时让"写在哪里"有明确的位置，按类型固定章节。空章节留 `_(暂无)_` 以保持 grep 可用。

- **source**: `**TL;DR:**` → `## Key claims` → `## Entities & concepts` → `## How this updated the wiki` → `## Notable quotes`
- **entity/concept**: `**定义:**`(BLUF) → `## 摘要` → `## Key facts` → `## 关系` → `## Open questions / 矛盾` → `## Sources`

模板实物见 `40-templates/{source,entity,concept}.md`。

---

## 4. 命名 & 规范化 (aliases.md)

- 文件名 = **kebab-case slug**，稳定(一旦确定就不改 — 避免链接失效)。例：`napoleon-bonaparte.md`
- 中文实体允许中文 slug(空格→连字符)。例：`机动战.md`
- 源 slug 建议加日期 prefix：`2026-06-14-article-title.md`

### 规范名规则 (路由键)
- 每个实体确定**单个规范名**并放入 frontmatter `canonical`。**规范名首字母决定分片** (§8)。
- 同一对象的其他写法**不要新建文件**，而是登记到 frontmatter `aka` + 中央 `aliases.md`。
- **规范化 = 检索入口。** 即使提问以"Parasite"到来，也先在 `aliases.md` 中换成 `寄生虫` 再路由。

### aliases.md (按主题的规范词典)
在 `30-wiki/{topic}/aliases.md` 中累积 `别名/写法 → 规范名` 映射。
```markdown
| 写法/别名 | 规范名 | 类型 |
|-----------|--------|------|
| Parasite, 寄生蟲, 寄生虫 | 寄生虫 | entity(work) |
| 甜茶, Chalamet | Timothée Chalamet | entity(person) |
```
compile 创建新实体时若看到别名就加到此处。query 在路由前先读此表。

---

## 5. 链接 & 交叉引用

- 维基内部引用用 `[[相对路径/slug]]`。例：`[[entities/napoleon-bonaparte]]`、`[[sources/2026-06-14-article]]`
- 所有**事实主张**后接 provenance 链接：`拿破仑出身于科西嘉 [[sources/2026-06-14-article]]`
- 无出处的推理·合成用 `(推断)`/`待确认` 标注。
- **链接只在目标页面实际存在时**才建。不存在的实体保留为 plain text(种子)，查询时按需（lazy）提升 (§10) — 不批量产生死链接。

### 同名 disambiguation (路径明示链接)
同一名称存在于多个类型/文件夹时(例如 `entities/Dune` 同时有作品页和系列页)用**路径明示链接**区分：
```markdown
[[works/Dune|Dune]]  (单一作品)  vs  [[series/Dune|Dune]]  (系列作品)
```
并在**路由器(index)的「同名冲突」笔记中登记该名称**，使路由时两个分片都展开。

---

## 6. 矛盾处理

新源与既有主张冲突时**不要覆盖**，保留并明示两方：
```markdown
## Open questions / 矛盾
> ⚠️ Contradiction: [[sources/A]] 说 X，[[sources/B]] 说 Y。未解决。
```
`/lint` 用 `grep -rn "⚠️ Contradiction" 30-wiki/` 全量追踪。(同名 disambiguation 不是矛盾，而是用 §5 的路径链接处理 — 须区分。)

---

## 7. index.md = 路由器 (MOC, 非目录)

**核心：index 不是"用来读取的列表"，而是"决定去往何处的路由器"。** 实体行不放在 index 中 — 那是 `indexes/{type}.md` 的工作。

### 根路由器 (`30-wiki/index.md`)
- frontmatter `tags: [index, moc, router]`。
- 仅放主题列表 + 各主题页面数 + 全局枢纽(overview·aliases)链接。
- "提问属于哪个主题" → 转送到对应主题路由器。

### 主题路由器 (`30-wiki/{topic}/index.md`)
- **意图 → 类型索引路由表**为主体：

| 意图 | 要读的子索引 | 分割键 | 数量 |
|------|------------------|---------|------|
| 人物·组织 | `[[indexes/entities]]` (或分片) | 规范名首字母 | N |
| 概念·理论 | `[[indexes/concepts]]` | (单一) | M |
| 原始出处 | `[[sources/index]]` | (单一) | K |

- **同名冲突笔记** (需确认两个分片的名称列表)。
- **已保存查询**链接 (`50-queries/`)。
- 页脚放各类型合计。

路由规则(在路由器正文中明示)："类型+首字母明确则只 1 个分片 / 类型模糊则候选分片同时 / 找不到则 grep → lazy"。

---

## 8. 按类型的子索引 + 分片

`30-wiki/{topic}/indexes/{type}.md` = 该类型实体的**目录**。每行：
```markdown
- [[entities/napoleon-bonaparte]] — 法国军人·皇帝。机动战·大军团。关键词: 科西嘉, 1804 加冕, 滑铁卢。
```
行 description **原样复用页面 frontmatter 的 `summary`**(§2)。用此行进行"展开哪个页面"的初步筛选。

### 分片 (≤50K token)
- 某个类型索引变大时，**按规范名首字母做 token 均衡分片**：`indexes/entities-a-m.md`、`indexes/entities-n-z.md`。
- **中文规范名归入第二个分片**(`-n-z` 侧)(字母之后)。
- 各分片保持 ≤50K token。超出则重新划分边界。
- 把路由器的分割键表与分片同步(`/lint` 巡检)。

---

## 9. 检索成长路径 (3 段) + Phase A/B 路由

| 规模 | 索引结构 | 路由 |
|------|-------------|--------|
| ~数十页面 | 主题路由器兼任目录 (`indexes/` 可省略) | 读 1 个路由器直达页面 |
| ~数百页面 | 按类型分离 `indexes/{type}.md` | 路由器 → 1 个类型索引 → 页面 |
| 数千+页面 | 类型索引按首字母**分片** | 路由器 → 1 个分片 → 页面 (+可选：外部检索 `.rag`) |

> 外部混合检索(`.rag` BM25/vector)是**可选的派生基础设施**。有则作为 query 找候选的首选，**没有则回退到 路由器→分片 tiered-read**(OMC·零外部依赖为默认)。原始文件·维基不可变，`.rag` 是随时可重新生成的派生物。

### 2 段路由 (所有规模通用)
- **Phase A — Route (不读页面):** 从提问中抽取实体+类型意图+操作(查询/比较/综合)，用 `aliases.md` 规范化后，**仅看路由器**确定要打开的分片最小集合。绝不读分片 (~2K token)。
- **Phase B — Search (读分片+页面):** 仅展开指定分片做候选筛选 → 只读正文并用 `[[链接]]` 补充 1 跳 → 仅以依据引用作答。未命中时走**扩大检索阶梯**：兄弟分片 → `30-wiki/` 全文 grep → lazy 生成或"无"。

**核心不变式：** 不把 index/分片整体放入上下文。始终通过路由只引入**少数候选** → 把维基大小与每次 query 的 token 成本分离。

---

## 10. lazy 生成 + tier 提升

- **仅高频才预先建页。** 仅对在语料全局中出现 **≥2 次**的实体建独立页面(compile 通过全局聚合判定)。出现 1 次的留作上级页面的 plain text **种子**，提问到来时再生成(lazy)。
- **lazy 生成:** Phase B 中连 grep 也找不到时 — 若 `20-raw/`·`sources/` 中**有种子**，则用 raw+网络即时生成(`tier: auto`、`provenance: web-enriched`) → 登记到 `auto-generated.md` 总账 + 对应首字母分片(路由器仅更新数量·同名笔记)。**若连种子都没有，不要凭空捏造，标注"维基中无相关内容 — 请先 /ingest"。**
- **tier 提升:** 人工确认 `auto` 页面后提升为 `reviewed`，并使 frontmatter·`auto-generated.md` 总账·类型索引三处保持一致(`/lint` 巡检)。

---

## 11. overview.md (综合入口)

`30-wiki/{topic}/overview.md` = 横跨全部源的全局图景。用一页呈现"这个维基知道什么"。宏观·探索性提问(Phase B)先读 overview 再下钻到相关分片。由 compile 更新。

---

## 12. 文件转换·图片·PDF

### 文档转换 (二进制 → markdown)
Claude 无法直接读取 docx·pptx·xlsx 等二进制。`/ingest` 看扩展名转换为 markdown 后放入 inbox。**原始二进制保管在 `20-raw/assets/`**(保留出处)，仅转换后的 `.md` 作为 compile 对象。

| 输入 | 首选 (本地·免费) | 回退 (opt-in) |
|------|-------------------|----------------|
| `.md`/`.txt`/`.html` | 原样 | — |
| `.pdf` | Claude PDF Read(文本型) / `markitdown` | LlamaParse (扫描·复杂表格) |
| `.docx`/`.pptx`/`.xlsx` | `markitdown <文件>` | LlamaParse (表格多的文档) |

- **markitdown = 主力。** 用 `pip install 'markitdown[all]'` 一个就能把 Office·PDF·图片转为 markdown。本地·免费 → 保持自足原则。
- **LlamaParse = 纯 opt-in。** 仅当存在 `LLAMA_CLOUD_API_KEY` 时触发(表格·布局复杂文档质量↑)。在免费额度内使用，超出则收费。**没有密钥则静默回退到本地(markitdown)** — 不破坏自足性。
- 任何工具都没有时不要阻断，提供安装指引或"请粘贴为文本"。

### 图片·PDF
- 原始文件本地保存在 `20-raw/assets/`(URL 可能失效，建议下载)。
- 维基页面中的图片引用：`![说明](../../20-raw/assets/figure.png)` + 标题文字。
- **两段读取:** LLM 无法一次性读取 markdown 内联图片，故先读文本，再单独 Read 所需图片。

---

## 13. provenance 等级 (可解释性)

所有主张·页面都标注出处依据：
- `extracted` — 从原文直接提取
- `inferred` — LLM 推理·合成 (禁止断言，须人工确认)
- `ambiguous` — 规范名·事实模糊 (用 pending-decisions 追踪)
- `web-enriched` — lazy 生成时网络补充 (与 `tier: auto` 配对)

`inferred`/`ambiguous` 不要断言，经 §14 门控人工确认后再确定。

---

## 14. 苏格拉底门控 (人工监督)

维基越大，某处混入 1 个幻觉的概率就越趋近于 1。因此 LLM 应作为**批判者而非被动接受者**运作：
- 当人抛出资料·想法时，**指出并反问**矛盾·弱点·依据不足。
- compile/query 的 `inferred`·`ambiguous`·矛盾不要断言，经人工确认后再确定为 `reviewed`。
- 大量自动生成(lazy/回填)后，建议用 `/lint` 抽查 dead-link·同名·幻觉·误译。
