# UK 대학 DB 목표 리스트 (edmuhak 목록 기준, 운영사 중복 제거)

진행 표시: [x] = universities-uk.json 입력 완료

## 1차 배치 (수요 상위)
- [x] uk-loughborough 러프버러
- [x] uk-ucl UCL
- [x] uk-edinburgh 에든버러
- [x] uk-manchester 맨체스터
- [x] uk-kcl 킹스칼리지런던
- [x] uk-warwick 워릭
- [x] uk-bristol 브리스톨
- [x] uk-leeds 리즈
- [x] uk-birmingham 버밍엄
- [x] uk-nottingham 노팅엄
- [x] uk-exeter 엑시터

## 2차 배치
- [x] uk-lse LSE
- [x] uk-imperial 임페리얼
- [x] uk-bath 바스
- [x] uk-sheffield 셰필드
- [x] uk-glasgow 글래스고
- [x] uk-durham 더럼
- [x] uk-southampton 사우스햄튼
- [x] uk-newcastle 뉴캐슬
- [x] uk-lancaster 랭커스터
- [x] uk-york 요크

## 3차 배치
- [x] uk-cardiff 카디프
- [x] uk-liverpool 리버풀
- [x] uk-surrey 서리
- [x] uk-sussex 서식스
- [x] uk-leicester 레스터
- [x] uk-qmul 퀸메리런던
- [x] uk-reading 리딩
- [x] uk-royal-holloway 로열홀로웨이
- [x] uk-city 시티 세인트조지스
- [x] uk-brunel 브루넬

## 4차 배치 (옥스브리지·특수·나머지)
- [x] uk-oxford 옥스퍼드
- [x] uk-cambridge 케임브리지
- [x] uk-st-andrews 세인트앤드루스
- [x] uk-soas SOAS
- [x] uk-goldsmiths 골드스미스
- [x] uk-birkbeck 버크벡
- [x] uk-cranfield 크랜필드 (대학원)
- [x] uk-lbs 런던비즈니스스쿨 (대학원)
- [x] uk-rvc 로열수의대학
- [x] uk-aston 아스턴
- [x] uk-oxford-brookes 옥스퍼드브룩스
- [x] uk-westminster 웨스트민스터
- [x] uk-northumbria 노섬브리아
- [x] uk-middlesex 미들섹스
- [x] uk-uclan 센트럴랭커셔
- [x] uk-dmu 드몽포트
- [x] uk-anglia-ruskin 앵글리아러스킨
- [x] uk-ljmu 리버풀존무어스

---

# 작업 기록 (AU 방식 승계)

## 🟢 진단 학부 목록 22 → 47곳 + 파운데이션 운영 형태 노출 (2026-08-04)

허브 `universities-uk.json`의 `pathways`를 소스로 UG_UNIS를 다시 만들었다. 크랜필드·LBS는
석사 전용이라 뺐고 나머지 47곳이 다 들어갔다. HUB_UNI도 19곳 추가해 **47/47이 허브 상세로 연결**된다.

### ⚠ 허브도 진단도 둘 다 틀린 데가 있었다 — 그대로 옮기면 안 된다
`pathways`가 "검증된 데이터"라고 적혀 있지만 **누락과 오기가 섞여 있다.** 대조하다 나온 6건:

| 학교 | 진단(옛) | 허브 | 확인된 값 |
|---|---|---|---|
| Bath | 파운데이션 없음 | Study Group | **Study Group** (10년 협약, 캠퍼스 내 ISC) |
| St Andrews | 자체 파운데이션 | direct(없음) | **자체 IFP 운영**. UCAS 아닌 대학 직접 지원 |
| Exeter | INTO | Study Group | **INTO**. iCAS가 INTO 브랜드고 뉴캐슬과 같은 계열 |
| Sheffield | IYO 있음 | IYO 없음 | **있음**(USIC International Year One) |
| Durham·Lancaster | IYO 없음 | IYO 있음 | **있음**(허브에 금액까지 있다) |
| Leeds | Study Group만 | 자체만 | **둘 다.** 대학 IFY(IPC)와 Study Group ISC가 따로 있고 IYO는 ISC 쪽 |

→ **한 학교가 자체와 사설을 같이 두는 경우가 있어서 `grp`을 배열로 바꿨다**(리즈·리딩·맨체스터).
다음에 다른 나라를 확장할 때도 허브 pathways를 그대로 믿지 말고 최소한 파운데이션 운영 주체와
IYO 유무는 교차 확인할 것.

### 결과 화면에 나오는 것
- 학교 카드마다 **운영 형태 배지**: `대학 자체 운영`(파랑) · `Kaplan/Study Group/INTO/CEG/Navitas 온캠퍼스`(황토) ·
  `A-level · IB (식스폼)`(회색). 센터 이름은 회색 배지로 따로 붙는다(영문 고유명사라 번역 불필요).
- 필터 칩: 전체 / **대학 자체 파운데이션(19)** / **사설 기관 온캠퍼스(26)** / IYO 운영(16) / A-level·IB(5).
  합이 47을 넘는 건 자체·사설을 같이 두는 학교가 3곳이라 그렇다.
- 죽어 있던 `privateFoundations` 배열을 **파운데이션 유형 절 아래에 렌더**했다. 캠퍼스 밖 오픈 초이스
  기관(Kaplan Int'l Pathways · Kings Education · CEG ONCAMPUS · INTO · CATS/DLD)과
  **식스폼 칼리지(A-level 2년)** 줄을 같이 넣었다. 옥스브리지·임페리얼·LSE·RVC는 파운데이션이
  아예 없어서 이 줄이 그 학교들의 유일한 경로다.

### 잔가지
- QS는 **2027판(2026.6 발표)** 기준. 새로 넣은 17곳 값은 UK 전체 표와 러셀그룹 표 두 곳이 일치한 값만 썼다.
  골드스미스(701–710대)·웨스트민스터·미들섹스·UCLan·DMU·ARU·LJMU·RVC는 **`qs:null`**로 두고
  "QS 순위 미표기"로 표시한다. 정렬은 `(a.qs||9999)`로 뒤로 보낸다.
- UNI_INFO가 없는 21곳은 상세 모달이 안 열린다. 대신 UG_UNIS에 `maj`(우세 전공)를 넣어
  카드의 전공 줄은 채워진다. 모달까지 원하면 UNI_INFO에 21곳 소개문을 써야 한다.
- **미러 3곳(chongro·edm·studyabroad-uk-ai)은 7월 버전 그대로다.** 8/4 작업이 전부 uk-study-guide에만 들어갔다.
  미러를 살릴지 접을지 정해야 한다.

## 🟢 진단 카드 38건 학비 전수 대조 (2026-08-04)

**일치 11건 · 정정 27건.** 카드의 "약 £X ~ £Y" 범위 대부분이 한 해 뒤처진 값이었고
(2026-27 공시가 더 높음), **과정 자체가 개편·개명된 것이 6건** 나왔다.
정정값은 전부 대학 공시 원문이고, 확인된 카드는 정확값(단일 금액)으로 바꿨다.

### 과정 개편 — 작년 이름으로 검색하면 없는 과정이 나온다
| 옛 이름(카드) | 현재 |
|---|---|
| Leeds MA Advertising and Marketing | **MSc Marketing Management with Advertising** £31,500 |
| Leeds MSc (Eng) Civil Engineering | 단독 과정 없음 → **MSc (Eng) Structural Engineering** £33,500 |
| Leeds LLM International Law | **LLM International Law and Global Governance** £28,750 |
| Manchester MSc International Development | **MSc Global Development** 계열 £30,500 |
| Manchester MSc Electrical and Electronic Eng | 그 이름 없음 → **MSc Electrical Power Systems Engineering** £38,400 |
| Warwick MSc Business Analytics | **MSc Business Analytics & Artificial Intelligence** £38,150 |
| Lancaster MSc Accounting and Financial Mgmt | **MSc Accounting and Finance** (£30,000, 리다이렉트 확인) |
| Sheffield Civil/Structural | **MSc Civil and Structural Engineering** 통합 £32,905 |
| Birmingham MSc Sport Policy, Business and Mgmt | **MSc Sport Business, Management and Leadership** £27,090 |
| Cranfield "MSc Aerospace Engineering" | 그 이름 없음 → **Aerospace Vehicle Design** £33,045 / Automotive £29,025 |

⚠ **Leeds MA TESOL은 교육 경력 2년 필수다.** 경력 없는 지원자는 같은 학교
**TESOL Studies MA**(£28,750)로 지원한다. 카드도 그쪽으로 바꿨고 desc에 요건을 적었다.

### 큰 폭 정정 (요주의)
UCL MA Education 27~30k → **£39,200** · Edinburgh DS/AI 38.5~42k → **£45,410** ·
KCL DS·Cyber → **£40,450** · QMUL Laws LLM → **£33,000**(SQE 병행판은 £37,950) ·
Southampton Cyber·EE → **£35,000** · Glasgow 셋 다(£29,355 / £33,210 / £33,210).
Goldsmiths Media&Comms는 반대로 **내려서** £23,000.

### 학교별 조회 방법 — 다음에 그대로 쓸 것
| 학교 | 방법 |
|---|---|
| Leeds | `courses.leeds.ac.uk` 코스 페이지 same-origin fetch. `International fees £X (Total)` 패턴 |
| Manchester | 코스 페이지 fetch. `tuition fees are as follows: … International, including EU, students (per annum): £X` |
| KCL | 코스 URL 뒤에 **`/fees`**를 붙이면 fetch로 잡힌다. `Full time tuition fees international £X per year (2026/27)` |
| Glasgow | fetch로는 안 나온다(JS). **페이지를 실제로 열어** `International & EU Full-time fee: £X` |
| Edinburgh | 코스 페이지엔 금액이 없다. **registryservices.ed.ac.uk의 2026-2027 taught-masters 표**(692행)에서 찾을 것 |
| Sheffield | fetch로는 안 나온다. 실제로 열면 `£X Overseas students`. 2026 코스 목록에서 슬러그 확인 |
| Southampton | 코스 페이지에 금액 없음. **`/courses/fees/postgraduate.page` 중앙 표**(545행) |
| York | 코스 페이지 fetch. `fees for 2026/27 … Full-time (1 year) £UK £Intl` |
| UCL | 실제로 열고 **"International students" 탭 클릭** 필요. `Overseas tuition fees (2026/27)` |
| Bath | 코스 페이지에 금액 없음. **`/corporate-information/<학부>-taught-postgraduate-tuition-fees-2026-27`** |
| Goldsmiths | 코스 페이지에 있으나 **`pg-fees-2026-27.pdf`가 정답**(pdftotext -raw) |
| QMUL | 코스 페이지에 다 있다. ⚠ 옵션(SQE·파트타임)별 금액이 여럿이니 `Full-time September 2026` 블록을 볼 것 |
| Leicester | SPA라 **"Fees and funding" 탭을 클릭해야** 금액이 붙는다 (href 없는 쪽 탭) |
| Cranfield | 금액이 innerHTML에 있다. ⚠ **2025-26·2026-27이 나란히 있으니** 연도 라벨을 앞에서 확인 |
| WBS(워릭) | `wbs.ac.uk/courses/masters/<slug>/fees/` |
| Lancaster | 코스 페이지 표는 장학금 표. 학비는 그 표의 첫 금액(£30,000) |

## 🟢 진단 구조 점검 + 해외고 다이렉트 버그 수정 (2026-08-04)

**학부 5문항(학력→내신→영어→계열→목표)·석사 5문항(영어→GPA→전공 2단계→전공 일치→목표)**
구조 자체는 학생 관점에 맞게 서 있다. 영어 환산기(TOEFL·PTE), 특수 전공 직접 입력, 뒤로 가기,
공유 링크까지 있다. 고친 것 하나, 남긴 것 둘:

- **고침**: `status='intl'`(해외고 A-level·IB)이 파운데이션으로 추천되던 버그.
  A-level·IB는 영국 대학이 그대로 받는 자격이라 **다이렉트가 기본**이고 옥스브리지·G5도 이 전형이다.
  `ugRouteDecision`/`ugRouteReason`에 intl → `direct` 분기 추가, i18n 키
  `directUgTitle`/`directUgSub`/`rIntl` 신설(ko·en 짝).
- **남김 1**: 석사 트랙에 **경력 질문이 없다.** MBA(실무 4년 또는 GMAT)·비전공 전환에서 경력이
  자격 요건인데 sameMajor 질문의 note로만 언급된다. 질문 추가는 공유 링크 인코딩(#p= JSON이라
  AU보다 안전)과 함께 검토.
- **남김 2**: UG 결과의 파운데이션 유형 추천(fndTypeRecommend)이 intl(다이렉트) 학생에게도
  표시된다. 정보성이라 틀리진 않지만 direct 추천과 나란히 있으면 혼동 여지.

## 🟢 HUB_UNI 점검 결과 (2026-08-04)

**진단에 등장하는 학교는 전부 허브에 연결돼 있다**(UNI_ALIAS 포함, 누락 0).
허브 49곳 중 진단에 아예 안 나오는 20곳이 남는다:
cardiff · liverpool · surrey · reading · royal-holloway · city · brunel · soas · birkbeck ·
lbs · rvc · aston · oxford-brookes · westminster · northumbria · middlesex · uclan · dmu ·
anglia-ruskin · ljmu.
→ 이건 매핑 문제가 아니라 **진단 콘텐츠 확장** 문제다. UG_UNIS(현재 22곳)에 추가하려면
파운데이션 운영 형태(자체/제휴/기관)를 확인해야 하는데, **허브 universities-uk.json의
pathways 필드에 이미 검증된 데이터가 있다**(49/49). 그걸 소스로 쓰면 재조사가 필요 없다.

## 🟢 유학 정보 글 구조 개통 (2026-08-04)

- `build-uni.ps1`의 두 루프(`$ARTICLES_BY_CC`, `$articleLocs`)에 `'uk'` 추가.
- `guide/uk.html`에 `<div class="info-board">` 섹션 신설(자주 묻는 질문과 공식 출처 사이).
- `data/articles-uk.json` 생성, **1편: `msc-fees-2026`** — 이번 38건 대조에서 나온 축
  ("같은 1년 석사가 £23,000~£45,410, 밴드를 가르는 건 계열이다 / 유통되는 숫자는 한 해 뒤처져 있다").
- 빌드 3회 연속 게시판 행수 유지 확인(au 26 · uk 1). 대학 페이지 글 연계는 소스 도메인 자동
  매칭이라 리즈·KCL·에든버러 등 출처에 있는 학교 페이지에 자동으로 붙는다.

### 다음에 이어갈 자리
1. **coei uk 게시판(coei.com/uhak-info/rc/uk) 인벤토리** — 글이 많지 않다고 하니 AU처럼
   주제 목록만 만들고 본문은 우리 데이터로 새로 쓴다. 원저자 문제(AU와 동일)도 같은 원칙.
2. **UG(파운데이션) 기관별 요건 검증** — UG_UNIS의 fnd/iyo는 운영 형태까지만 있고
   IELTS·내신 기준이 없다. 기관(Kaplan·INTO·Study Group·CEG) 공식 페이지에서 확인할 것.
3. **PG 카드 학교 폭 확장** — 현재 19전공 38카드(학교 17곳). 허브 미등장 20곳 중
   상담 수요 있는 곳(카디프·리버풀·서리 등)을 전공별로 추가.
4. **UG 학비 데이터** — 진단 UG 결과에 학비 표가 있는데(commit 7fa8ff5) 값 검증은 아직.

---

## ⚠ 글을 쓰기 전에 — 문체·제목 규칙은 backlog-au.md에 있다

영국 글도 **호주와 같은 규칙**을 따른다. 원문은 `backlog-au.md` 아래 두 절에 있으니 먼저 읽을 것.

1. **「글 제목 규칙」** — 형식은 `[전공명] 훅 한 문장.`
   - 브래킷으로 주제를 빼서 문장을 짧게. **줄표(—)로 주제와 설명을 잇지 말 것**
   - 마침표는 붙인다. 훅 원칙은 `/anthropic-skills:hook-generator`
   - ⚠ **H2 소제목은 손대지 않는다**(2026-08-04 사용자 결정). 안내형 그대로 둔다
   - 영국 1편은 이미 적용돼 있다: `[영국 석사 학비] 같은 1년인데 £23,000부터 £45,410까지입니다.`

2. **「글 안의 표·그래프·사진」** — 표는 반드시 `table-wrap` + `fact-table`.
   다른 클래스를 쓰면 **CSS가 안 걸려 줄만 나열된 것처럼 보인다**(실제로 겪었다).
   막대그래프는 `.bar-chart`, 사진은 `images/article/`(README 참고).

### ⚠ 한/영 병기 글의 직역투
영어 문장을 먼저 잡고 한국어로 옮기면 번역투가 나온다. 사용자가 지적한 실제 사례:
"움직인 건 컴퓨터 계열입니다" · "돌아다니는 숫자는 한 해 뒤처져" · "예산을 세울 자격이 있다".
**한국어를 한국어로 먼저 쓰고 `data-en`을 나중에 붙일 것.** (메모리 `study-guide-work-style`에도 있다)
