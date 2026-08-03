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
- [x] **6편 완료(2026-08-02). 진단 전공 5종 전부 커버.**
      pharmacy · medicine · hospitality · engineering · pathway(전공 무관, 학부 결과에 항상 노출).
      학부 결과는 전공 글 + pathway 2장, 석사는 1장이 뜬다. 10가지 조합 브라우저 검증 완료.

### ⚠ 필자가 전 직장(coei)에서 쓴 글이라는 점
사용자가 coei 게시판 글의 **원저자다.** 저작권은 전 직장에 있고, 같은 사람이 썼다는 사실 때문에
"비슷하면 오히려 문제"가 되는 상황이다. 그래서 주제만 참고하고 **제목·구성·전개 순서까지 겹치지
않게** 쓴다. 각 글의 축은 coei 방식이 아니라 **우리 데이터에서 나오는 판단**으로 새로 세웠다.

| slug | coei 방식 | 우리 축 |
|---|---|---|
| nursing | 과정·학교별 소개 | 학위가 있느냐로 경로가 갈린다 |
| pharmacy | 학교 하나씩 5편 | 세 학교가 서로 다른 벽(선수과목/영어/수능)을 세운다 |
| medicine | 파운데이션 경유 전략 | 시험 이름부터 갈린다(ISAT·UCAT vs GAMSAT), 총비용이 문턱 |
| hospitality | 산발적 | 유급 인턴십이 학위 안에 있느냐 |
| engineering | 토목·이민 | EA 인증이 학교 선택을 정한다 |
| pathway | 내신 5등급제 여러 편 | 파운데이션과 디플로마는 같은 1년이 아니다 |

- [ ] 다음 배치(진단 전공 밖, 게시판에만): 유아교육 · 물리치료 · 사회복지 · 작업치료 ·
      기술이민 비자(189/190/491) · 어학연수 · TAFE 취업 경로
- [ ] 영국·미국·캐나다도 같은 구조로 확장 가능. `$articleLocs` 루프의 `@('au')`에 국가 코드를
      추가하고 `data/articles-{cc}.json`을 만들면 된다.

### 글 추가 방법
1. `data/articles-au.json`에 항목 하나 추가(slug·제목·설명·body·sources, 한/영 모두).
2. `scripts/build-uni.ps1` 실행 → 페이지 생성 + **guide/au.html 목록 카드 자동 갱신** +
   사이트맵 등록까지 끝난다. 목록 카드는 `<div class="info-board">` 안을 통째로 갈아 끼우므로
   **그 블록은 손으로 고치지 말 것**(빌드가 덮어쓴다).
3. 진단에 띄우려면 au-study-guide의 `INFO_ARTICLES`에 전공 키로, 전공 무관이면 `INFO_COMMON`에 등록.
   `tracks`로 학부/석사를 가른다(null이면 둘 다).

## 세부 전공 재편 — **완료 (2026-08-03)**

진단의 전공 질문을 **계열 → 세부 전공** 2단계로 바꿨다. **7계열 30전공 전부 끝났다.**

| 계열 | 세부 전공 | 근거 파일 |
|---|---|---|
| 보건 | 7 (간호·물리치료·작업치료·치위생·사회복지·임상병리·족부의학) | `au-health-verified.md` |
| 약학·생명 | 3 (약학·생명공학·의료공학) | `au-life-verified.md` |
| IT·사이버보안 | 5 (IT 일반·컴퓨터사이언스·사이버보안·AI데이터·소프트웨어공학) | `au-it-verified.md` |
| 공학 | 5 (공학 일반·토목건설·건축·기계전기·항공) | `au-engineering-verified.md` |
| 의대 계열 | 3 (의대·치대·수의대) | `au-medicine-verified.md` |
| 경영 | 4 (호텔경영·비즈니스·회계금융·스포츠경영) | `au-business-verified.md` |
| 교육 **(신설)** | 3 (유아교육·초중등 교직·TESOL) | `au-education-verified.md` |

**전 30전공 × 학부/석사 60조합 브라우저 전수 검증 완료** — 렌더 오류 0, 번역 누락 0,
허브 상세 버튼 60/60, 공유 링크 코드 왕복 30/30, 레거시 한 글자 코드 6종 정상.

### 이번에 같이 고친 것
- **HUB_UNI에 플린더스·UTas·뉴캐슬 추가.** 보건 때 들어온 학교인데 매핑이 빠져서
  허브에 페이지가 있는데도 '학비·요건 상세' 버튼이 안 나가고 있었다.
- **`ielts` 필드가 `tr()`을 안 거치고 있었다.** 보건 때 "7.0 (전 영역 6.5)" 같은 한글 병기를
  넣으면서 생긴 문제로, 영어 모드 카드에 한글이 그대로 나갔다.
- **대학원만 있는 전공을 렌더할 수 있게 했다.** `masterSchools`만 두면 학부를 골라도
  석사 목록 + '석사' 라벨이 나온다(TESOL). 반대 경우(치위생)는 이미 되던 것과 대칭.
- **`IT 및 사이버보안 (IT/Cyber Security)` → `IT 일반 (Information Technology)`으로 개명.**
  사이버보안이 세부 전공으로 독립하면서 보기 목록이 겹쳐 읽혔다. 코드 `I`는 그대로.

### 다음에 이어갈 자리
- ~~빅토리아주(멜버른) 학교가 통째로 막혀 있다~~ → **같은 날 오후에 뚫었다.**
  **Claude in Chrome(실제 크롬)으로 열면 403 봇 차단이 안 걸린다.** 6개교(모나쉬·멜버른대·
  RMIT·라트로브·디킨·스윈번) 영어 요건을 전부 원문으로 읽고 카드 5장을 추가했다:
  디킨 생명공학 석사 · RMIT 의료공학 학부 · 멜버른대 의공학 석사(전공 무관 + 선수과목!) ·
  스윈번 소프트웨어공학 학부(6.0, 계열 최저) · 라트로브 치대(IELTS만 인정).
  값은 각 verified 파일에, 방법은 `au-english-general.md` 맨 위에 적었다.
- ~~모나쉬는 대학 최저만 확인했다~~ → **2026-08-03 오후 완료.**
  **모나쉬는 과정마다 English Level A~F를 붙인다**(생명공학 석사는 Level B로 듣기·읽기가 반 밴드
  높다). 대학 최저를 그대로 인용하면 틀리는 과정이 있으니 과정별로 확인할 것. 읽는 방법은
  `au-english-general.md`에 적어 뒀다. Master of Biotechnology 카드 추가(A$52,800).
  **기존 모나쉬 카드 4곳(IT 학·석사, 간호 석사, 약학 학부)은 전부 학교 공시와 일치했다.**
- ⚠ **CRICOS의 `Expired=No`는 "현재 모집 중"이 아니다.** 모나쉬 Bachelor of Biotechnology가
  등록은 살아 있는데(078846J) 학교 국제학생 코스 목록에는 없다. 학비만 보고 카드를 만들면
  없는 과정을 안내하게 된다. **새 과정은 학교 코스 목록에 실재하는지 한 번 더 볼 것.**
- **적산(QS)은 못 만들었다.** 학위명 자체가 본드대·QUT에만 있다. 건설관리로 대체했다.
- ~~새 전공 21종에는 아직 유학 정보 글이 붙어 있지 않다~~ → **2026-08-03 해결. 글 6편 추가(총 13편).**
  전공마다 글을 따로 쓰지 않고 **계열당 1편**으로 묶었다. 각 편의 축은 이번 조사에서 나온 것이다.

  | slug | 붙는 전공 | 축 |
  |---|---|---|
  | `it-cost` | IT 일반·컴퓨터사이언스·사이버보안·AI데이터·소프트웨어공학 | 같은 전공 학비 두 배, 전공 무관 석사는 UQ 사이버보안 하나 |
  | `life-entry` | 생명공학·의료공학 | 석사 들어가는 문이 셋(관련 학사 / 실무 2년 / 선수과목) |
  | `aviation-cost` | 항공 | 학비 34.8만 + **훈련비 15.45만 별도** |
  | `med-tests` | 의대·치대·수의대 | UCAT·Casper·GAMSAT이 먼저, 영어는 전 영역 7.0 |
  | `business-entry` | 비즈니스·회계금융·스포츠경영 | 회계 석사 두 곳이 정반대 조건 |
  | `teaching-english` | 유아교육·초중등교직·TESOL | 입학 영어 ≠ 등록 영어(AITSL 말하기·듣기 8.0, IELTS만) |

  EA 인증 글(`engineering`)은 **토목·건설·기계·전기에도 붙였다** — 같은 인증 체계라 그대로 맞는다.
  **건축 석사만 글이 0편이다.** 건축은 EA가 아니라 AACA 인증이라 그 글이 안 맞아서 일부러 비웠다.
  섹션이 조용히 숨을 뿐 깨지지는 않는다. 건축용 1편을 쓰면 60조합 전부 채워진다.

  ⚠ **문체는 humanizer를 돌리지 않았다.** nursing 원본 리듬(짧은 문장 + 단정)을 기준으로 직접
  썼다. 이 방향은 사용자가 2026-08-02에 재작성본 대신 원본을 고른 결정을 따른 것이다.

### 옛 기록 (2026-08-02 시작 시점)

### 구조 (au-study-guide/index.html)
- `MAJOR_TREE` = 계열 → 세부 전공 배열. **계열은 질문 화면에만 존재**한다.
- `userProfile.major`에는 **항상 세부 전공(majorData 키)** 이 들어간다.
  결과 렌더·`HUB_UNI`·`INFO_ARTICLES`가 전부 이 키로 조회하므로 기존 코드는 안 고쳐도 된다.
- 세부 전공이 **하나뿐인 계열은 질문을 건너뛴다**(`handleAnswer`의 `next === "submajor"` 분기).
  그래서 아직 손 안 댄 계열도 예전과 똑같이 동작한다.
- `questionFlow.submajor`는 `optionsFn`으로 렌더 시점에 보기를 만든다(`renderQuestion`이 지원).
- ⚠ **`MAJOR_CODES`의 기존 6개 한 글자 코드는 절대 바꾸지 말 것.** 이미 나간 공유 링크(#r=)가
  열려야 한다. 세부 전공은 두 글자로 붙인다(Pt·Ot·Oh·Sw·Lm·Pd). 레거시 링크 6종 검증 완료.
- `showsMaster` = `isMaster && !!majorInfo.masterSchools`. 석사 자격 과정이 없는 전공
  (치위생·족부의학)은 학부 목록을 보여주되 **제목도 '학부'로 맞춘다.** 목록과 라벨이 어긋나면 안 된다.

### 완료: 보건 계열 7개
간호(기존) · 물리치료 · 작업치료 · 치위생 · 사회복지 · 임상병리 · 족부의학.
데이터 근거는 `data/au-health-verified.md`, 과정 후보는 `data/au-health-courses.txt`(CRICOS 87개).

### ~~남은 6계열~~ — 2026-08-03 전부 완료
계획 대비 달라진 것 두 가지: **컴퓨터공학 → 소프트웨어공학**(호주에 그 학위명이 없다),
**적산(QS) 제외**(검증 대상 학교에 개설이 없어 건설관리로 대체). 교육 계열은 계획의
유아교육·TESOL에 **초·중등 교직**을 더해 3전공으로 만들었다.

### 데이터 만드는 방법 (보건에서 검증된 절차)
1. 학비 — `scratchpad`의 CRICOS `cricos-courses.csv`에서 뽑는다. 없으면 data.gov.au에서 재다운로드
   (방법은 이 파일 위쪽 "CRICOS 갱신 방법" 참고). 연간 = 과정 총액 ÷ (주÷52).
2. 영어 — **대학이 공개하는 영어 요건 표·PDF를 최우선**으로 본다. 마케팅용 코스 페이지는
   JS 렌더거나 403이라 못 쓴다. 자세한 내용은 `data/au-health-english.md`.
3. ⚠ **검색 스니펫이 학교 일반 기준을 과정 기준인 양 답한다.** 플린더스 물리치료 석사를
   "6.0"으로 답한 사례가 있었다(실제 7.0). 반드시 원문 표로 확인할 것.
4. **검증 못 한 학교는 카드에서 뺀다**(사용자 결정). 카드가 1~2개가 되어도 틀린 값보다 낫다.
5. 글은 `data/articles-au.json`에 추가 → 빌드하면 페이지·목록 카드·사이트맵이 자동.
   진단 연결은 `INFO_ARTICLES`(전공별) 또는 `INFO_COMMON`(전공 무관).

### 글 현황 (7편)
nursing · pharmacy · medicine · hospitality · engineering · pathway · health-english
