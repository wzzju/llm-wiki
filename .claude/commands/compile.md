---
description: "inbox 소스를 위키로 정제, 위키화, 정리, 컴파일 요청에 사용합니다. '위키로 정리해줘', '컴파일해줘', '정제해줘', 'inbox 처리해줘', '위키에 반영해줘' 같은 요청에 대응합니다. compile은 inbox의 미컴파일 소스를 읽어 위키 페이지로 합성하고 index·aliases·overview를 갱신한 뒤 원본을 raw로 옮깁니다. 단, 자료 수집은 /ingest, 질문은 /query, 점검은 /lint를 사용합니다."
---

# /compile — 정제 (inbox 소스 → 위키)

`10-inbox/`의 미컴파일 소스를 읽어 위키 페이지로 합성하고, **라우터·타입 인덱스·aliases·overview를 갱신**한 뒤 원본을 `20-raw/`로 옮깁니다. 단순 복사가 아니라 기존 페이지 갱신·교차참조·정본화·모순 표시.

## 사용법

```text
/compile                                   (inbox의 미컴파일 소스 전부)
/compile 10-inbox/2026-06-14-article.md    (특정 소스만)
```

## 실행 흐름

### Step 1: 현황 + 미컴파일 식별
- `30-wiki/index.md`(루트 라우터)·`log.md`로 기존 주제·페이지를 파악.
- `10-inbox/`의 소스 = 미컴파일 (인자가 있으면 그 소스만).
- 소스가 어느 **주제(topic)**인지 정한다 (기존 재사용 우선). 새 주제면 `30-wiki/{topic}/` 골격 생성: `index.md`(주제 라우터)·`aliases.md`·`overview.md`·`indexes/`·`sources/`·`entities/`·`concepts/`.

### Step 2: 소스 읽기 + 핵심 (소크라테스 게이트)
- 소스를 읽는다. 이미지/PDF면 `conventions.md §12` 2단계 읽기.
- 핵심 takeaway 3~5개를 공유하고 **모순·약점·근거 부족을 짚어 되묻는다** (배치 모드면 생략). 다듬어진 결론만 위키로 승격.

### Step 3: 소스요약 페이지
- `40-templates/source.md` → `30-wiki/{topic}/sources/{date-slug}.md`.
- frontmatter `source_file`은 **이동 후 경로**(`20-raw/{파일명}`)로 기록(Step 7에서 이동). `summary` 필수(인덱스 재사용).

### Step 4: 엔티티/개념 페이지 (정본화 + 중복 점검)
- 소스에 등장한 인물·조직·개념마다 페이지 생성/갱신. **여러 소스가 쌓이면 전역 ≥2회 등장만 페이지 승격**, 1회는 상위 페이지 plain text 씨앗(질문 시 lazy). 단일 소스면 핵심 엔티티 중심.
- **생성 전 중복 점검**: 해당 타입 인덱스(`indexes/{type}.md`) + `aliases.md`로 동일 표기/별칭 점검 → 이미 있으면 **새로 만들지 말고 갱신·병합**(정본명·aka·aliases 갱신).
- **정본명(`canonical`) 결정** → `aliases.md`에 별칭 등재 (라우팅 키).
- 모든 사실 주장 뒤 `[[sources/...]]` provenance(`extracted`/`inferred`/`ambiguous`). 출처 없는 추론은 `(추론)`. 동명은 `[[type/이름|이름]]` 경로 링크 + 라우터 충돌 노트.
- `[[링크]]`는 **대상 페이지가 실제 있을 때만**, 없으면 plain text(씨앗).

### Step 5: 인덱스·종합 갱신 (라우팅의 핵심)
- **타입 인덱스** `indexes/{type}.md`에 신규/변경 페이지 줄 등재 — 줄 description은 페이지 `summary` 재사용. **샤드가 ≤50K 토큰 넘으면 정본명 첫 글자로 재분할**(한글은 둘째 샤드).
- **주제 라우터** `{topic}/index.md`: 타입별 **개수·동명 충돌 노트·푸터 합계만** 갱신(엔티티 줄은 라우터에 넣지 않음).
- **루트 라우터** `30-wiki/index.md`: 새 주제면 주제 줄 추가.
- `overview.md` 갱신(큰 그림).

### Step 6: self-audit
- 만든 엔티티/개념 페이지 vs 타입 인덱스 등재 = **diff 0** 확인(누락 없음).
- `tier: auto` 페이지는 `30-wiki/{topic}/auto-generated.md` 대장에 등록(미검수 표시).

### Step 7: 원본을 raw로 이동 (보관)
- `mv 10-inbox/{파일} 20-raw/{파일}`. **파일명 유지**(Step 3의 `source_file` 링크 보존).
- inbox에 남은 = 미컴파일, raw에 있는 = 컴파일 완료.
- 동명 충돌·이동 실패 시 덮어쓰지 말고 알린다.

### Step 8: 로그 + 커밋
- `log.md`에 `## [YYYY-MM-DD] compile | {제목 또는 규모}` + 건드린 페이지 목록.
- git repo면 `git add -A && git commit`.

## 출력 형식

```text
✅ compile 완료: {제목/규모}
주제: {topic}
- 소스요약: sources/{slug} ×N
- 엔티티/개념: entities/{...} ×N, concepts/{...} ×M (신규 {a} / 갱신 {b})
- aliases 등재: {k}건 · 동명 충돌: {n}건
- 인덱스 갱신: indexes/{type} (샤드 {s})
- self-audit: 누락 0
- 원본 이동: 10-inbox → 20-raw/{...}
```

## 트리거 경계

should-trigger: "위키로 정리해줘", "컴파일", "정제해줘", "inbox 처리해줘", "위키에 반영"
NOT-trigger:
- "이 자료 수집/넣어줘"(저장만) → `/ingest`
- "X 알려줘" → `/query`
- "점검/모순 확인" → `/lint`
- "원본 고쳐줘" → 금지 (raw 불변)

## 참조
- `00-system/conventions.md` §4(정본화)·§7(라우터)·§8(샤딩)·§10(lazy/tier)·§14(소크라테스)
- `40-templates/` — source/entity/concept 템플릿
