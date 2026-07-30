# 대학 DB 스키마 v1

## 필드 규칙
- id: 국가코드-학교약칭, 소문자·하이픈, 한 번 정하면 불변 (예: uk-ucl, ca-ubc)
- type: university | college | specialty
- qs_rank: 미랭킹·200위 밖은 null
- 학비: 통화기호·콤마 없이 숫자만, 없는 과정은 null
- english.accepted enum: ielts, toefl, pte, duolingo, toeic, cambridge, internal
- pathways.type enum: foundation, iyo, direct, pre-master, pathway, transfer, college
- last_verified: YYYY-MM
- 2차 백로그(지금 넣지 않음): pathways.naeshin_max, 시험별 상세 점수, editor_note 본문, related_ids

## 예시 — 러프버러 (숫자는 샘플, 공식 페이지 값으로 교체 예정)
{
  "id": "uk-loughborough",
  "type": "university",
  "name_ko": "러프버러대학교",
  "name_en": "Loughborough University",
  "country": "UK",
  "city": "Loughborough",
  "qs_rank": 222,
  "qs_subject_ranks": [{ "subject": "스포츠관련학", "rank": 1 }],
  "tuition_ug_min": 27000,
  "tuition_ug_max": 31000,
  "tuition_pg_min": 28500,
  "tuition_pg_max": 32000,
  "currency": "GBP",
  "english": { "ielts_min": 6.5, "accepted": ["ielts", "toefl", "pte", "duolingo"], "note": null },
  "popular_majors": ["스포츠매니지먼트", "경영", "기계공학", "산업디자인"],
  "pathways": [
    { "type": "foundation", "provider": "자체 운영", "ielts_min": 5.5, "duration": "1년", "cost_note": "약 £19,000", "note": null }
  ],
  "intakes": ["9월", "1월"],
  "official_url": "https://www.lboro.ac.uk",
  "editor_note": null,
  "related_ids": [],
  "last_verified": "2026-07"
}
