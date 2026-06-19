# Template Deviation Log

이 파일은 워크스페이스가 `20-archetypes/knowledge-base` 템플릿과 어떻게 다른지를 기록합니다.
Quick Path 생성에서는 "기본 템플릿 유지"가 기본 기록이고,
Custom Path에서는 사용자가 명시적으로 동의한 변경 사항만 기록합니다.

## Reflected Harness Metadata (생성 시점)

| 항목 | 값 | 출처 |
|------|----|------|
| target runtime | Claude Code (CLAUDE.md) | Workspace_Builder 전용 |
| harness_type | basic | 18-HARNESS_CONCEPTS.md |
| state_model | enabled=True, path=_meta | _meta 위치 |
| doctor_checks | structure, instructions, commands, security, harness-contract | validator 권장 묶음 |

## Deviation Table

| 날짜 | 아키타입 | 일탈 사유 | 영향 |
|------|----------|-----------|------|
| 2026-06-14 | knowledge-base | Custom Path: KB 온톨로지 모델 → Karpathy LLM-wiki 모델로 재구성. 폴더 10-schema/20-data/30-relations/50-exports/frameworks 제거, 00-system/20-raw/30-wiki/40-templates 신설. 커맨드 specify/implement/validate → ingest/query/lint. CLAUDE.md를 위키 운영 schema로 재작성. (사용자 명시 요청: "기본적인 LLM-wiki 동작방식을 담아서 구현") | 구조·커맨드 전면 변경. 핵심 KB DNA(구조화·검증·provenance)는 유지, 표면을 위키화 워크플로우로 치환 |
| 2026-06-14 | knowledge-base | base_archetype만 knowledge-base, 표면 전부 custom. structure.json은 실제 구조 반영해 갱신 | 자기검증 정합 |
