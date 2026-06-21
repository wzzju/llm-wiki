# LLM Wiki

> Made by **gptaku** · Threads [@gptaku_ai](https://www.threads.com/@gptaku_ai)

这是一个由 LLM 直接对 raw 源进行合成·维护，并将其培育为**永久 Markdown 维基**的工作区。在 Claude Code 之上实现了 [Karpathy 的 "LLM Wiki" 模式](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)。

与每次提问都重新检索原文的 RAG 不同，它会**合成一次后持续保持最新状态并不断累积**。人负责采集·探索·提问，LLM 负责维基的所有写入、整理与交叉引用。

> 不依赖外部技能·插件。只要有这个文件夹，就能在任何 Claude Code 环境下运行。**这是一个可直接用自己的数据填充、边用边强化的起步模板** —— 不是标准答案，而是一个起点。

## 开始使用

```bash
cd llm-wiki
claude
```
> 首次运行时会自动弹出使用引导（由 SessionStart 钩子触发）。

1. **放入源** — 把文章·论文·笔记·PDF 丢进 `10-inbox/`。(URL·文件自动收集用 `/ingest <源>`)
2. **维基化** — `/compile` → 读取 inbox 源，在 `30-wiki/` 中合成为摘要·实体·概念页面，更新**路由器·索引·aliases** 后把原始文件移到 `20-raw/`。
3. **提问** — `/query 拿破仑的战术是如何演化的？` → 用两级路由召回·引用，并把好的答案留存到 `50-queries/`。
4. **巡检** — 维基变大后用 `/lint` → 巡检矛盾·孤儿·索引一致性·空白。

> **留在 inbox 的 = 未编译，在 raw 里的 = 编译完成。**

## 4-Layer 结构

| 层 | 文件夹 | 归属/负责方 |
|--------|------|------|
| **inbox** (未编译队列) | `10-inbox/` | 人放入 |
| **raw** (不可变原始文件) | `20-raw/` | compile 填充，LLM 只读 |
| **wiki** (合成结果) | `30-wiki/` | LLM 全权写入 |
| **schema** (运营规约) | `CLAUDE.md` + `00-system/conventions.md` | 人·LLM 共同演进 |

```
10-inbox/ → /ingest(收集) → /compile → 30-wiki/{topic}/{sources,entities,concepts}
                                        ├── index.md    (路由器 MOC — 意图→类型/分片)
                                        ├── indexes/    (类型索引 — 变大就按首字母分片)
                                        ├── aliases.md  (规范化 = 路由键)
                                        └── overview.md (综合概览)
                            /query → Phase A 路由 → Phase B 召回·合成 → 50-queries/ 回写
                            /lint  → 矛盾·孤儿·索引一致性巡检
                            原始文件处理后移到 20-raw/ (不可变保管)
```

## 命令

| 命令 | 角色 |
|--------|------|
| `/ingest {源}` | 把资料(URL·文件·文本)保存到 `10-inbox/` (不做维基化) |
| `/compile [源]` | 把 inbox 源合成为维基 + 更新路由器/索引/aliases + 移到 raw |
| `/query {问题}` | 用两级路由召回·引用合成，回写 |
| `/lint [主题]` | 维基健康检查 (矛盾·孤儿·索引一致性·gap) |

## 索引 = 路由器 (LLM Wiki 的核心)

核心在于：即使维基变大，**每次提问读取的 token 也保持恒定**。`index.md` 不是"所有页面的列表(目录)"，而是**"接收提问意图、决定展开哪个类型/分片的路由器(MOC)"**。

- **两级路由** — Route(只读路由器+`aliases` 决定分片，不读分片) → Search(只展开指定分片)。
- **规范化** — 把写法不一致(Parasite/寄生虫)归并为一个规范名，规范名首字母即分片键。
- **分片** — 类型索引变大时按规范名首字母以 ≤50K token 分割。
- **成长路径** — 文档增多后，可选地把外部检索(`.rag` BM25/vector)作为第一优先接入，并进一步拆分索引层来扩展。路由器→分片作为 fallback 保留。

## 了解更多

- **运营规约**: `CLAUDE.md` (身份·工作流·质量规则)
- **页面·索引·路由规约**: `00-system/conventions.md` (14 节 — frontmatter·规范化·路由器·分片·lazy/tier·provenance)
- **页面模板**: `40-templates/`

---

MIT License. 欢迎自由 fork 使用。
