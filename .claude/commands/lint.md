---
description: "위키 점검, 모순 확인, 고아 페이지 찾기, 빈틈/누락 점검, 인덱스/라우터 정합 검사 요청에 사용합니다. '위키 점검해줘', '모순 없나 확인', '빠진 거 찾아줘', '고아 페이지 확인', '인덱스 맞나 봐줘' 같은 요청에 대응합니다. 단, 자료 수집은 /ingest, 위키화는 /compile, 질문은 /query를 사용합니다."
---

# /lint — 점검 (건강검진)

위키 건강을 점검합니다. 위키가 커질수록 모순·고아·갭·인덱스 불일치가 쌓이므로 주기적으로 실행합니다. 자동 수정 가능분(고신뢰)은 고치고, 사람 판단이 필요한 항목은 리포트로 남깁니다.

## 사용법

```text
/lint            (위키 전체)
/lint [주제]     (특정 주제만)
```

## 실행 흐름

### Step 1: 무결성 — 링크·모순·고아
- **모순**: `grep -rn "⚠️ Contradiction" 30-wiki/`로 미해결 모순 전수 수집. stale 주장(최신 소스 미반영)도.
- **죽은 링크**: `[[X]]`가 가리키는 페이지 없음 → plain text 강등 또는(씨앗 있으면) lazy 후보 리포트.
- **고아 페이지**: 인바운드 `[[링크]]` 0.
- **동명 충돌**: 같은 이름이 여러 폴더/타입에 존재 → `[[type/이름|이름]]` 경로 링크로 disambiguate + **라우터 동명 충돌 노트에 빠짐없이 등재**됐는지 확인.

### Step 2: 인덱스·라우터 정합 (★ 라우팅 무결성)
- **인덱스 불일치**: 페이지가 타입 인덱스 `indexes/{type}.md`(소스는 `sources/index.md`)에 없거나, 인덱스엔 있는데 파일이 없음. 타입↔폴더 정합.
- **라우터↔인덱스 정합**: 주제 라우터 `index.md`의 타입별 **개수·푸터 합계**가 실제 엔트리 수와 일치하는지, 라우팅 표의 인덱스/샤드 링크가 모두 존재하는지, **엔트리가 첫 글자 기준 올바른 샤드**에 있는지(경계 위반 0).
- **샤드 토큰 상한**: 각 인덱스 샤드가 **≤50K 토큰**인지(초과 시 첫 글자 경계 재분할 권고/실행).
- **aliases 정합**: 엔티티 `canonical`/`aka`가 `aliases.md`에 등재됐는지.

### Step 3: tier·provenance 동기화
- `tier: auto` 페이지가 `auto-generated.md` 대장 + 해당 타입 인덱스에 모두 등재됐는지. reviewed 승격 시 세 곳 정합.
- provenance 없는 사실 주장, `inferred`/`ambiguous` 미해결 항목.

### Step 4: 갭 — 개념 누락
- `20-raw/`·`sources/`엔 ≥2회 등장하는데 위키에 페이지 없는 엔티티/개념(승격 후보).
- `status: stub` 중 보강 필요분.

### Step 5: drift — 커맨드↔schema
- `.claude/commands/*.md` 절차가 `CLAUDE.md`·`conventions.md` 규약과 어긋나는지(예: query가 aliases를 읽는지, compile이 overview/index를 갱신하는지).
- **(.rag 있을 때)** state↔위키 diff로 미색인·stale 탐지, eval 회귀 점검. `.rag` 없으면 skip.

### Step 6: 위생
- frontmatter(`summary`/`tier`/`provenance`) 누락, BLUF 없는 페이지, ~1,500 토큰 초과 페이지.

### Step 7: 리포트 + 수정
- 자동 수정 가능분(인덱스 등록 누락, 명백한 링크 오타, plain text 강등)은 바로 고친다.
- 사람 판단 필요분(모순, 폐기 후보, 할루 의심, 조사 제안)은 `30-wiki/{topic}/reports/{YYYY-MM-DD}-lint.md`(또는 90-archive 인접)에 목록으로 남긴다.
- `log.md`에 `## [YYYY-MM-DD] lint | {발견 N / 수정 M}` 추가.

## 출력 형식

```text
🔍 lint 리포트 ({범위})

무결성: 모순 {n} · 죽은 링크 {n} · 고아 {n} · 동명 {n}
인덱스·라우터: 불일치 {n} · 개수 mismatch {n} · 샤드 초과 {n} · aliases 누락 {n}
tier/provenance: auto 미등재 {n} · provenance 없는 주장 {n}
갭: 승격 후보 {n} · stub {n}
drift: 커맨드↔schema {n}
위생: frontmatter 누락 {n} · 과대 페이지 {n}

자동 수정: {m}건 / 사람 판단 필요: {목록}
```

## 트리거 경계

should-trigger: "위키 점검해줘", "모순 확인", "고아 페이지 찾아줘", "인덱스 맞나 봐줘", "일관성 봐줘"
NOT-trigger:
- "이 소스 넣어줘" → `/ingest`
- "위키로 정리해줘" → `/compile`
- "X 알려줘" → `/query`

## 참조
- `00-system/conventions.md` §5·§6·§7·§8·§10·§13 — 링크·모순·라우터·샤딩·tier·provenance
- `30-wiki/log.md` — 최근 작업 이력
