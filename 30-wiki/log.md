# Wiki Log

> append-only 运行记录。一条记录 = 一次操作。遵守统一 prefix `## [YYYY-MM-DD] {op} | {标题}`。
> 查看最近操作：`grep "^## \[" 30-wiki/log.md | tail -5`
> op 值：`ingest` | `compile` | `query` | `lint`

<!-- 示例(缩进仅为说明用 — 实际记录从行首的 "## [" 开始):
    ## [2026-06-14] ingest | 拿破仑战术的演进
    - sources/2026-06-14-article 创建
    - entities/napoleon 更新, concepts/机动战 强化
    - 登记 1 条 contradiction
-->
