# AU 대학 DB 백로그

진행 표시: [x] = universities-au.json 입력 완료

## 입력 완료 (35곳)
- [x] Go8·주요대 11곳 (unsw·melbourne·sydney·monash·uq·uts·griffith·qut·wsu + hotel-school·bmihms)
- [x] 요리·TAFE 4곳 (lcb·angliss·tafe-nsw·tafe-qld)
- [x] 사용자 PDF 목록 신규 20곳 (anu·uwa·adelaide·rmit·macquarie·curtin·wollongong·deakin·latrobe·newcastle·swinburne·utas·flinders·unisq·murdoch·canberra·ecu·vu·acu·unisc)
- 참고: PDF의 애들레이드대(8번)·UniSA(17번)는 2026-01 통합 → au-adelaide 하나로 입력

## 남은 작업 (집에서 이어서)
## 학비 조사 — 2026-08-02 진행분

**호주 대학은 학교 단위 연간 학비를 대체로 공시하지 않는다.** 과정별 계산기로만 준다.
미국·영국과 다르고 캐나다 컬리지와 비슷하다. 그래서 **공시 PDF 요금표가 있는 학교만** 채울 수 있다.

### 입력 완료 (2곳)
- [x] **au-wollongong** UG 36,672~42,816 / PG 33,792~42,000.
      출처는 `2026 International Tuition Fees` PDF(documents.uow.edu.au/.../uow273695.pdf).
      **PDF가 세션당 금액이라 ×2 해서 연간으로 바꿨다**(연 2세션). Bachelor 40건·Master 46건의
      25~75% 구간이다. 각 행의 **마지막 금액이 세션당**이고 앞의 큰 금액은 과정 총액이니 헷갈리지 말 것.
- [x] **au-flinders** UG 36,300~43,600 / PG 39,900~45,400.
      출처는 `International Commencing Tuition Fee Schedule 2026`(2026년 1월판) PDF.
      **`pdftotext -layout`은 2단 편집이라 이름과 금액이 어긋난다.** `-raw`로 뽑아 읽기 순서대로
      Bachelor/Master 블록에 금액을 붙였다. 전체 278건 기준 39,000~44,800과도 어긋나지 않는다.

### 조사해 보니 이런 상태였다 (다음에 이어갈 때 참고)
- **계산기만 있고 표가 없다**: UWA(fees.uwa.edu.au 계산기) · 맥쿼리 · RMIT · 커틴 · 디킨.
  WebFetch로는 금액이 안 나오고 헤드리스로 렌더해도 표가 안 뜬다. **과정별로 하나씩 조회해야 해서
  대표 전공 몇 개를 뽑는 방식이 아니면 학교 단위 범위를 못 만든다**(캐나다 험버·VCC와 같은 상황).
- **PDF는 있는데 국내학생용이었다**: 스윈번. `2026-undergraduate-indicative-full-course-fees.pdf`가
  제목과 달리 Domestic이다. **CSP·FFP는 국내 요금 표시다. 받으면 첫 줄부터 확인할 것.**
- **PDF 있음, 아직 안 받음**: UTas(2026 요율 PDF 204KB) · 뉴캐슬.
- ⚠ **뉴캐슬은 검색 스니펫에 "연 $36,000~$53,000"이 나왔지만 넣지 않았다.**
  fees-and-scholarships 페이지가 WebFetch 403이고 헤드리스로 렌더해도 금액이 안 잡혀서
  **원문을 못 봤다.** 검증 안 된 값은 넣지 않는다는 원칙대로 비워 뒀다.
- **latrobe.edu.au는 WebSearch가 거부한다**(크롤러 차단 도메인). 다른 경로로 접근해야 한다.

- [x] **남은 22곳은 CRICOS 등록부로 채웠다(2026-08-02). 35/35 완료.**
      사용자 결정: 대학이 학비를 과정별로만 공시해 요금표가 없는 곳은 **호주 정부 CRICOS
      등록부** 기준으로 넣고 사이트에 밝힌다. build-uni.ps1의 `$FEE_NOTE['AU']`가 그 문구다.

### CRICOS 갱신 방법 — 다음에 그대로 쓸 것
1. data.gov.au의 CRICOS 데이터셋에서 `cricos-courses.csv`를 받는다(약 7MB, 26,000행).
   과정별 **Tuition Fee(과정 총액)·Duration(주)·Course Level·Expired**가 다 들어 있다.
   웹(cricos.education.gov.au)은 ASP.NET 포스트백이라 긁지 말 것 — CSV가 정답이다.
2. Expired=No만 쓴다. 연간 학비 = Tuition Fee ÷ (Duration주/52). 26주 미만 과정은 제외.
3. 학교 단위 값은 **25~75% 구간**(캐나다 컬리지와 같은 원칙), 100단위 반올림.
   UG = Bachelor (Honours 포함) · PG = Masters (Coursework) · 컬리지 = Diploma+Advanced Diploma.
4. **CSV의 기관명은 사이트 표기와 다르다**: RMIT는 `Royal Melbourne Institute of Technology`,
   TAFE NSW는 `Technical and Further Education Commission`(00591E), UWA·맥쿼리 등은
   `(UWA)` 같은 괄호가 붙는다. BMIHMS는 `Torrens University Australia Limited` 소속이라
   과정명 Hotel|Hospitality|Culinary 필터로 걸렀다(n=4).
5. 공식 요금표 PDF가 있는 학교(UOW·플린더스)는 PDF 값을 유지한다 — CRICOS보다 학교 공시가 우선.
- ⚠ **PowerShell 함정**: `foreach ($id in $V.Keys) { $V[$id] }`가 5.1에서 둘째 키부터
  null을 돌려줘 **22곳 전부에 첫 학교 값이 들어가는 사고**가 났다(git checkout으로 복구).
  해시테이블 순회는 반드시 `GetEnumerator()`로 할 것.
- [x] ~~로고 2곳: au-ecu, au-lcb~~ **이 항목은 낡았다** — 두 파일 모두 images/uni/에 있고
      페이지에 나가고 있다(2026-08-02 확인). 마지막 남았던 **au-bmihms도 같은 날 채워서
      호주 로고 35/35 완료.** BMIHMS 사이트(bluemountains.edu.au)의 미디어 CDN은 SVG 요청에
      HTML을 돌려주는데, **같은 미디어 경로를 torrens.edu.au 도메인으로 바꾸면** 진짜 SVG가
      나온다(토렌스 계열 공통 Sitecore 미디어라이브러리).
- [ ] 배너: images/uni/au-banner.jpg (영국처럼 공용 1장이면 35곳 전부 적용)
- [x] youtube_id 35/35 완료(2026-08-02). 유튜브 검색을 긁어 공식 채널 영상만 골랐고 oEmbed로 채널·제목을 전수 검증했다. 1차 수집이 헤이그 호텔스쿨·UOW 두바이·웰링턴 빅토리아대를 물어와서, 채널명 필수/금지어 필터로 재수집해 잡았다. 이름이 흔한 학교는 반드시 채널명으로 검증할 것.
- [ ] qs_subject_ranks 전부 빈 배열 (검증된 것만 넣는 원칙)
- [x] au-study-guide 진단 결과 → uni 페이지 연결. **2026-08-02 전수 검증: 진단 카드 11곳
      전부 HUB_UNI 매핑 있음, id 전부 허브 페이지 실재.** 이미 돼 있던 것을 백로그가 놓치고 있었다.

## 유학 정보 글 (data/articles-au.json → guide/au-info-*.html)

coei 게시판(coei.com/uhak-info/rc/au, 5페이지 50편)은 **다룰 주제 목록으로만** 쓴다.
본문은 인증기관·정부·대학 공식 자료로 새로 쓴다. 미국 guide/us.html과 같은 원칙이다.

- [x] **1편 완료(2026-08-02): au-info-nursing** — 학사 3년 vs GE 석사 2년.
      진단(au-study-guide)의 간호 결과 "호주 진학 경로 가이드" 아래에 카드로 뜬다.
- ⚠ **문체 기준은 이 글 그대로다.** humanizer로 한 번 더 다듬은 판을 만들어 비교했고
      **사용자가 원본을 골랐다(2026-08-02).** 재작성본은 줄표를 없애고 연출 문장을 평서문으로
      풀었는데, 문장이 길어지면서 상담 톤의 힘이 빠졌다. **이 방향으로 다시 고치지 말 것.**
      humanizer는 초안 검수용으로만 쓰고, 최종 판단은 원본 쪽 리듬(짧은 문장 + 단정)을 유지한다.
- [ ] **다음 5편** (진단 전공 5종 커버): 약대 총정리(coei 5편 통합) · 의치수 파운데이션 ·
      내신 5등급제/검정고시 전략(전공 무관, 전 결과 노출) · 호텔경영 · 공학+EA 인증
- [ ] 그 뒤 배치(진단 전공 밖, 게시판에만): 유아교육 · 물리치료 · 사회복지 · 작업치료 ·
      기술이민 비자(189/190/491) · 어학연수 · TAFE 취업 경로
- 글 추가 방법: `data/articles-au.json`에 항목 하나 넣고 `scripts/build-uni.ps1` 실행.
  페이지 생성·사이트맵 등록까지 자동이다. 목록 카드는 `guide/au.html`의 `.info-board`에 수동 추가.
  진단에 띄우려면 au-study-guide의 `INFO_ARTICLES` 해시에 전공 키로 등록한다.
