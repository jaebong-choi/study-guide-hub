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
- [ ] 로고 2곳: au-ecu, au-lcb (공식 사이트에서 못 긁음 — 파일 구해서
      images/uni/{id}-logo.svg|png 투명배경으로 넣고 build-uni.ps1 재실행)
- [ ] 배너: images/uni/au-banner.jpg (영국처럼 공용 1장이면 35곳 전부 적용)
- [ ] youtube_id 전부 null (대학 공식 채널 영상 ID 채우면 섹션 자동 생성)
- [ ] qs_subject_ranks 전부 빈 배열 (검증된 것만 넣는 원칙)
- [x] au-study-guide 진단 결과 → uni 페이지 연결. **2026-08-02 전수 검증: 진단 카드 11곳
      전부 HUB_UNI 매핑 있음, id 전부 허브 페이지 실재.** 이미 돼 있던 것을 백로그가 놓치고 있었다.
