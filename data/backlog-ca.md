# CA 컬리지 DB 백로그

진행 표시: [x] = universities-ca.json 입력 완료

## 입력 완료 — 사용자 PDF 8곳 (2026-07-31)
- [x] ca-seneca 세네카 폴리테크닉
- [x] ca-humber 험버 폴리테크닉
- [x] ca-george-brown 조지브라운 폴리테크닉
- [x] ca-centennial 센테니얼 컬리지
- [x] ca-sheridan 셰리든 컬리지
- [x] ca-fanshawe 팬쇼 컬리지
- [x] ca-niagara 나이아가라 컬리지
- [x] ca-vcc 밴쿠버 커뮤니티 컬리지

## 남은 작업 (집에서 이어서)
- [ ] **학비 조사**: 8곳 전부 tuition null(페이지에 "문의" 표시).
      ca-study-guide/data/canada_colleges_data.json의 원칙대로 **각 컬리지 공식
      international fees 페이지 기준으로만** 채울 것 (애그리게이터 값 금지).
      온타리오 디플로마 대략 CA$16,000~20,000/년 수준이지만 공식 확인 후 입력
- [ ] 나머지 컬리지 36곳: ca-study-guide 결과에 등장하는 44곳 중 미입력분.
      목록·전공·URL은 ca-study-guide/data/canada_colleges_data.json에 있음
- [ ] 배너: images/uni/ca-banner.jpg (한 장이면 캐나다 전체 적용, 영국·호주와 동일 톤 권장)
- [ ] ca-study-guide 진단 결과 → uni 페이지 연결 (uk/au의 HUB_UNI 패턴)
- [ ] youtube_id 전부 null (공식 채널 영상 ID 채우면 섹션 자동 생성)
