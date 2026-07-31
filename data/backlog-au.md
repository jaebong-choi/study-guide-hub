# AU 대학 DB 백로그

진행 표시: [x] = universities-au.json 입력 완료

## 입력 완료 (35곳)
- [x] Go8·주요대 11곳 (unsw·melbourne·sydney·monash·uq·uts·griffith·qut·wsu + hotel-school·bmihms)
- [x] 요리·TAFE 4곳 (lcb·angliss·tafe-nsw·tafe-qld)
- [x] 사용자 PDF 목록 신규 20곳 (anu·uwa·adelaide·rmit·macquarie·curtin·wollongong·deakin·latrobe·newcastle·swinburne·utas·flinders·unisq·murdoch·canberra·ecu·vu·acu·unisc)
- 참고: PDF의 애들레이드대(8번)·UniSA(17번)는 2026-01 통합 → au-adelaide 하나로 입력

## 남은 작업 (집에서 이어서)
- [ ] **학비 조사**: 신규 20곳 중 ANU만 검증된 범위(A$39,090~53,700) 입력됨.
      나머지 19곳 + UWA는 tuition null(페이지에 "문의" 표시) — 각 대학 공식
      international fees 페이지에서 2026 UG/PG 범위 채울 것. 검증 안 된 값 넣지 말 것
- [ ] 로고 2곳: au-ecu, au-lcb (공식 사이트에서 못 긁음 — 파일 구해서
      images/uni/{id}-logo.svg|png 투명배경으로 넣고 build-uni.ps1 재실행)
- [ ] 배너: images/uni/au-banner.jpg (영국처럼 공용 1장이면 35곳 전부 적용)
- [ ] youtube_id 전부 null (대학 공식 채널 영상 ID 채우면 섹션 자동 생성)
- [ ] qs_subject_ranks 전부 빈 배열 (검증된 것만 넣는 원칙)
- [ ] au-study-guide 진단 결과 → uni 페이지 연결 (영국 HUB_UNI 패턴 참조)
