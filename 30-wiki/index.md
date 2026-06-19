---
type: index
scope: root
tags: [index, moc, router]
updated: 2026-06-14
---

# Wiki Index — 루트 라우터 (MOC)

> **이건 카탈로그가 아니라 라우터다.** 질문이 오면 여기를 **가장 먼저** 읽고, 어느 **주제**로 갈지만 정한다. 개별 엔티티 줄은 여기 두지 않는다 — 그건 주제 라우터(`{topic}/index.md`)와 타입 인덱스(`{topic}/indexes/{type}.md`)의 일.

## 🧭 라우팅 (2단)

```
질문 → [루트 라우터] 어느 주제? → [{topic}/index.md] 어느 타입/샤드? → 페이지
```

- **Phase A (Route, 페이지 안 읽음):** 질문에서 엔티티·타입 의도·연산을 뽑고 → `{topic}/aliases.md`로 정본화 → 라우터만 보고 **열 샤드의 최소 집합**을 정한다.
- **Phase B (Search, 샤드만 읽음):** 정해진 샤드만 펼쳐 후보 선별 → 본문 + `[[링크]]` 1홉 → 근거로만 인용 답. 미스 시 형제 샤드 → grep → lazy 생성/없음.

상세 규약: `00-system/conventions.md` §0·§7·§9.

## 주제 (Topics)

_(아직 없음 — `/ingest`로 소스를 `10-inbox/`에 넣고 `/compile`하면 주제가 생깁니다.)_

<!-- compile이 채우는 형식 (주제별 한 줄, 개별 엔티티는 여기 두지 않음):
- [[ai-history/index]] — AI 역사 (소스 12 · 엔티티 30 · 개념 18)
- [[napoleon/index]] — 나폴레옹 전쟁 (소스 5 · 엔티티 14 · 개념 7)
-->

## 전역 허브

_(주제를 가로지르는 종합 페이지가 생기면 여기 링크. 각 주제의 큰 그림은 `{topic}/overview.md`.)_
