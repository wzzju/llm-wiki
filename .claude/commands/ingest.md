---
description: "새 자료 수집, 자료 넣기, URL/파일/텍스트를 위키에 넣기 요청에 사용합니다. '이거 위키에 넣어줘', '이 자료 수집해줘', '이 URL 가져와줘', '이 PDF 넣어줘' 같은 요청에 대응합니다. ingest는 inbox에 저장만 하고, 위키 페이지로 정제하는 건 /compile, 질문은 /query, 점검은 /lint를 사용합니다."
---

# /ingest — 수집 (저장만)

자료를 `10-inbox/`에 새 파일로 **저장만** 합니다. **위키 페이지는 만들지 않습니다** — 그건 `/compile`의 일(저장과 정제를 분리). 저장된 소스는 inbox에 "미컴파일" 상태로 쌓이고, `/compile`이 위키로 정제한 뒤 `20-raw/`로 옮깁니다.

## 사용법

```text
/ingest [URL | 파일경로 | 붙여넣은 텍스트]
/ingest https://example.com/article
/ingest ~/Downloads/paper.pdf
```
> 사용자가 직접 `10-inbox/`에 파일을 떨궈도 됩니다 (그 경우 `/ingest` 없이 바로 `/compile`).

## 실행 흐름

### Step 1: 가져오기
- **URL** → 본문을 fetch해 마크다운으로 변환. (WebFetch가 SPA·봇차단으로 실패하면 사용자에게 본문 붙여넣기를 요청하거나 보유한 스크래핑 도구 사용.)
- **파일 경로** → 읽어서 가져옴. 이미지·PDF 첨부는 `20-raw/assets/`에 저장(영구 자산).
- **텍스트** → 그대로.

### Step 2: inbox에 저장
- `10-inbox/{YYYY-MM-DD}-{slug}.md`에 **새 파일명**으로 저장한다.
- 같은 자료의 갱신이면 `-v2`처럼 새 이름으로 (덮어쓰기 금지).
- 파일 맨 위 frontmatter에 출처(원본 URL/경로)·수집일을 남긴다.

### Step 3: 알림 (위키화 안 함)
- **위키 페이지는 만들지 않는다** — 저장만.
- `30-wiki/log.md`에 `## [YYYY-MM-DD] ingest | {제목}` 한 줄.
- "inbox에 미컴파일 소스 N개 대기 → `/compile`로 위키화하세요" 안내.

## 트리거 경계

should-trigger: "이 자료 넣어줘", "수집해줘", "이 URL 가져와", "이 PDF 넣어"
NOT-trigger:
- "위키로 정리해줘" / "정제해줘" / "컴파일" → `/compile`
- "X에 대해 뭐 알아?" → `/query`
- "위키 점검해줘" → `/lint`
- "원본 고쳐줘" → 금지 (raw 불변)

## 참조
- `/compile` — inbox 소스를 위키 페이지로 정제 + raw 이동
- `00-system/conventions.md` — 페이지·인덱스·라우팅 규약
