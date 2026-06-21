#!/usr/bin/env bash
# llm-wiki — SessionStart 引导/现状提示
# Claude Code SessionStart hook: 此脚本的 stdout 会被注入为会话上下文(非阻塞)。
# 无外部依赖(纯 bash + coreutils)。任何情况下都不阻塞会话,故始终 exit 0。

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." 2>/dev/null && pwd)}"
[ -n "$ROOT" ] && cd "$ROOT" 2>/dev/null || exit 0

INBOX="10-inbox"
WIKI="30-wiki"

# inbox 未处理源数量 (排除 README, 仅源文件)
inbox_count=0
[ -d "$INBOX" ] && inbox_count=$(find "$INBOX" -maxdepth 1 -type f \( -name '*.md' -o -name '*.txt' -o -name '*.pdf' \) ! -name 'README.md' 2>/dev/null | wc -l | tr -d ' ')

# 维基内容页面数量 (排除 index.md, log.md)
wiki_count=0
[ -d "$WIKI" ] && wiki_count=$(find "$WIKI" -type f -name '*.md' ! -name 'index.md' ! -name 'log.md' 2>/dev/null | wc -l | tr -d ' ')

echo "# 📚 LLM Wiki"
echo ""

if [ "${wiki_count:-0}" -eq 0 ] && [ "${inbox_count:-0}" -eq 0 ]; then
  # 首次使用 — 引导
  cat <<'EOF'
**维基为空(首次使用)。** 请把下面的开始指引转达给用户。

这个工作区是把 raw 源由 LLM 合成、培育成**永久 Markdown 维基**的地方 — 不是每次都重新检索的 RAG,而是合成一次后持续累积、保持最新。

## 如何放入数据
1. 把源文件放进 `10-inbox/` — `.md`/`.txt`/`.pdf`,文件名建议 `YYYY-MM-DD-标题-slug.md`。
   - 若是网页文章,复制正文存为 `.md`,并在文件最上方写出来源 URL。
   - 图片·figure 直接放进 `20-raw/assets/`。
   - **docx·pptx·xlsx·PDF** 由 `/ingest` 用 `markitdown` 自动转换(`pip install 'markitdown[all]'` 安装一次)。
2. (可选)URL/文件自动收集用 `/ingest <源>` → 仅保存到 `10-inbox/`。
3. 执行 `/compile` → 读取 inbox 源,在 `30-wiki/` 合成为源摘要·实体·概念,更新路由器(index)·类型索引·aliases·overview,再把原文移动到 `20-raw/`。
4. 用 `/query` 提问(两级路由·引用),用 `/lint` 巡检矛盾·孤儿·索引一致性。

**高级 — 复杂文档质量:** 表格·版式较多的 PDF/PPT 可用 LlamaParse(https://cloud.llamaindex.ai)提升转换质量 — 有免费额度,超出后收费。设置好 `LLAMA_CLOUD_API_KEY` 后,`/ingest` 会在复杂文档上自动启用,没有则回退到本地 markitdown。

**核心**: `10-inbox/` 里只要还留着文件 = 就是尚未编译的源。

现在要做的: 引导用户把第一份源放进 `10-inbox/`,或者用户给出源时,一起放入并 `/compile`。
EOF
else
  # 使用中 — 现状 (为避免反引号命令替换,使用 printf %s)
  printf '**现状**: 维基内容页面 %s 个 · inbox 未编译源 %s 个\n\n' "${wiki_count:-0}" "${inbox_count:-0}"
  if [ "${inbox_count:-0}" -gt 0 ]; then
    printf '⏳ 10-inbox/ 中有 %s 个未编译源在等待。请用 /compile 进行维基化:\n' "$inbox_count"
    find "$INBOX" -maxdepth 1 -type f \( -name '*.md' -o -name '*.txt' -o -name '*.pdf' \) ! -name 'README.md' 2>/dev/null | sed 's#^#  - #'
  else
    printf '✅ inbox 为空(无未编译)。新源用 /ingest 保存到 10-inbox,维基化用 /compile,提问用 /query。\n'
  fi
fi

# --- GitHub star opt-in (首个会话一次, 仅当有 gh 时) ---
STAR_MARKER=".claude/.star-asked"
if command -v gh >/dev/null 2>&1 && [ ! -f "$STAR_MARKER" ]; then
  cat <<'STAREOF'

---
## ⭐ (首个会话一次) GitHub star 意向
若觉得这个维基好用,请**用 AskUserQuestion**向用户只问一次:"要给这个模板 repo(fivetaku/llm-wiki)点个 GitHub ⭐ 吗?"。不要强求。
- 同意 → Bash: `gh api -X PUT user/starred/fivetaku/llm-wiki >/dev/null 2>&1 || true`
- 无论同意/拒绝,问完之后 → Bash: `touch .claude/.star-asked` (不再询问)
- 即使因 gh 未登录等原因失败,也静默跳过,不阻塞会话。
STAREOF
fi

exit 0
