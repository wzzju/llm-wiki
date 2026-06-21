# Template Deviation Log

本文件记录工作区与 `20-archetypes/knowledge-base` 模板有何不同。
Quick Path 生成中，"保留基本模板"是默认记录，
Custom Path 中只记录用户明确同意的变更项。

## Reflected Harness Metadata (生成时点)

| 项 | 值 | 来源 |
|------|----|------|
| target runtime | Claude Code (CLAUDE.md) | Workspace_Builder 专用 |
| harness_type | basic | 18-HARNESS_CONCEPTS.md |
| state_model | enabled=True, path=_meta | _meta 位置 |
| doctor_checks | structure, instructions, commands, security, harness-contract | validator 推荐组合 |

## Deviation Table

| 日期 | 原型 | 偏离事由 | 影响 |
|------|----------|-----------|------|
| 2026-06-14 | knowledge-base | Custom Path：KB 本体模型 → 重构为 Karpathy LLM-wiki 模型。移除文件夹 10-schema/20-data/30-relations/50-exports/frameworks，新建 00-system/20-raw/30-wiki/40-templates。命令 specify/implement/validate → ingest/query/lint。将 CLAUDE.md 重写为维基运营 schema。（用户明确请求："实现包含基本 LLM-wiki 运行方式的版本"） | 结构·命令全面变更。核心 KB DNA（结构化·验证·provenance）保留，表层替换为维基化工作流 |
| 2026-06-14 | knowledge-base | 仅 base_archetype 为 knowledge-base，表层全部 custom。structure.json 反映实际结构而更新 | 自校验一致性 |
