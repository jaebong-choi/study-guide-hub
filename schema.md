# 대학 DB 스키마 v1

## 필드 규칙
- id: 국가코드-학교약칭, 소문자·하이픈, 한 번 정하면 불변 (예: uk-ucl, ca-ubc)
- type: university | college | specialty
- qs_rank: 미랭킹·200위 밖은 null
- 학비: 통화기호·콤마 없이 숫자만, 없는 과정은 null
- english.accepted enum: ielts, toefl, pte, duolingo, toeic, cambridge, internal
- pathways.type enum: foundation, iyo, direct, pre-master, pathway, transfer, college
- pathways.level enum: ug(학사) | pg(석사), 생략 시 ug — 둘 다 있으면 페이지에서 학사/석사 그룹으로 표시
- type=secondary(국제 사립고)만 english.ielts_min 에 null 을 허용한다 — 공인 성적 없이 입학하고 ESL을 병행하는 학교다
- majors_heading: 전공 태그 섹션 제목을 바꾸고 싶을 때만 넣는 선택 필드. 없으면 "인기 전공".
  패스웨이 컬리지는 "패스웨이로 진학 가능한 전공", 사립고는 "개설 과목 계열"로 쓴다
- extra_facts: 학비·요건 표에 줄을 더 붙이는 선택 필드. [{ "label": "...", "value": "..." }] 배열.
  입학 시험, 첫해 납부 총액, 진학 실적처럼 그 학교에만 있는 값을 넣는다
- youtube_id: 대학 공식 채널 영상 ID만(URL 아님), 없으면 null — 있으면 하단에 임베드
- 배너 이미지: images/uni/{id}.jpg 파일이 리포에 있으면 상세 페이지 상단에 자동 표시 (스키마 필드 아님)
- 로고: images/uni/{id}-logo.png(또는 .svg), 반드시 투명 배경 — 모든 학교 동일한 160x88 박스에 표시되고 다크 모드에선 흰색 단색으로 자동 반전
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
    { "type": "foundation", "level": "ug", "provider": "자체 운영", "ielts_min": 5.5, "duration": "1년", "cost_note": "약 £19,000", "note": null },
    { "type": "direct", "level": "pg", "provider": null, "ielts_min": 6.5, "duration": "1년 (풀타임)", "cost_note": "£28,500~32,000", "note": "석사 직접 지원 · 전공별 요건 상이" }
  ],
  "intakes": ["9월", "1월"],
  "official_url": "https://www.lboro.ac.uk",
  "youtube_id": "8RHZ1K-ev2w",
  "editor_note": null,
  "related_ids": [],
  "last_verified": "2026-07"
}
