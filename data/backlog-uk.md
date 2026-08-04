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

### 캠퍼스 밖 사설 파운데이션 인정 여부 (`ext`) — 같은 날 추가

사용자 지적: **"보통의 경우 사설 일반 파운데이션을 통해서 진학 가능한 학교들도 있다."**
위의 `grp`은 "그 캠퍼스에서 뭘 운영하나"만 담아서, Kings·CATS·Kaplan 런던 같은
**캠퍼스 밖 파운데이션을 마치고 UCAS로 지원할 때 받아주는가**가 빠져 있었다. `ext` 필드로 넣었다.

`ext`는 `'open'`이 기본이고, **학교 공식 안내를 직접 확인한 곳만 다른 값을 준다**(= `extNote`가 있는 학교).

| 학교 | ext | 확인 내용 |
|---|---|---|
| 임페리얼 | **limited** | **UCL UPCSE·워릭 IFP 두 과정만.** 사설 기관 파운데이션은 아예 안 받는다 |
| LSE | **limited** | 영국에서 이수한 것만. 실제 사례는 런던대 IFP·UCL·KCL·워릭 등 대학 운영 과정 |
| 옥스퍼드 | **no** | 내용이 A-level과 같은 수준임을 증명해야 함. 대학도 A-level·IB를 권한다 |
| 케임브리지 | **no** | 인정 목록을 공개하지 않는다 |
| RVC | **no** | 수의학은 A-level 생물·화학 필수 |
| KCL | open | 개별 심사. ⚠ **다른 대학 통합형(Year 0)과 영국 밖 파운데이션은 불가** |
| 세인트앤드루스 | open | 타 영국 대학 파운데이션을 학위 자격으로 인정(그래서 자체 IFP엔 지원 불가) |
| 엑서터 | open | 인정 기관 명단 공개 — CATS·Kings·Kaplan·EF·NCUK 등 50곳 이상 |

⚠ **RVC는 grp도 고쳤다.** direct인 줄 알았는데 국제학생용
**BVetMed with Integrated Foundation Year를 신설**했다. 그래서 direct는 4곳(옥스·케임·임페리얼·LSE)이 됐다.

⚠ **KCL의 "통합형 불가"가 우리 목록과 직접 부딪힌다.** 웨스트민스터·버크벡·UCLan·RVC가
통합형(Year 0)이라 그 파운데이션으로는 KCL에 못 간다. 상담에서 쓸 것.

**나머지 39곳은 `open`(영국 일반 기준 = 과목 내용·성적 개별 심사)으로 뒀고 개별 확인은 안 했다.**
엑서터가 러셀그룹인데도 50곳 넘게 받는 걸 보면 이게 표준이지만, 상위권을 더 확인하려면
워릭·더럼·에든버러·맨체스터·브리스톨 순으로 볼 것.

결과 화면에는 **제한이 있는 학교만 배지**를 붙였다(전부 칠하면 걸러야 할 학교가 안 보인다).
필터에 '사설 파운데이션으로 지원 가능'(42곳)을 넣었고, 모달에는 `extNote` 원문을 띄운다.

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
1. ~~coei uk 게시판 인벤토리~~ → **완료. `data/coei-uk-topics.md`** (23편, 3페이지)
2. **UG(파운데이션) 기관별 요건 검증** — UG_UNIS의 fnd/iyo는 운영 형태까지만 있고
   IELTS·내신 기준이 없다. 기관(Kaplan·INTO·Study Group·CEG) 공식 페이지에서 확인할 것.
3. **PG 카드 학교 폭 확장** — 현재 19전공 38카드(학교 17곳). 허브 미등장 20곳 중
   상담 수요 있는 곳(카디프·리버풀·서리 등)을 전공별로 추가.
4. **UG 학비 데이터** — 진단 UG 결과에 학비 표가 있는데(commit 7fa8ff5) 값 검증은 아직.

## 🟢 coei 인벤토리 + 글 2편째 `foundation-accepted` (2026-08-04)

**coei 영국 게시판은 23편뿐이다**(호주 193편). `data/coei-uk-topics.md`에 정리했고
원저자·저작권 원칙은 호주와 같다. 빈 자리가 많아서 우리 데이터로 채울 여지가 크다.

**2편: `foundation-accepted`** — coei의 파운데이션 글(/393)과 축을 다르게 잡았다.

| | coei /393 | 우리 |
|---|---|---|
| 축 | "목표 대학이 정해져 있는가"로 오픈 vs 대학 파운데이션을 **고르라** | 고르기 전에 **갈 수 있는지부터 확인하라** |
| 근거 | 일반론(입학 요건·비용·FAQ) | 47곳 입학 페이지 실측 — 임페리얼 2과정만, 옥스·케임 사실상 불가, KCL 통합형 거부 |

출처 9곳(임페리얼·LSE·옥스·케임·KCL·엑서터·세인트앤드루스·바스·RVC) 덕에
**대학 페이지 9곳에 자동으로 붙었다.** 도메인 매칭이라 손으로 연결할 게 없다.

문체 검수(humanizer)에서 잡아 고친 것 셋: 영문 줄표 2개, 마무리의 부정 대구문
("A foundation is not the destination. It is…" → 평서문), 도입부의 "사실 이것이".
⚠ **출처 라벨(`label_ko`)의 줄표는 기존 관례라 그대로 뒀다.**

## 🟢 3편 `iyo-second-year` + 1편 줄표 소급 정리 (2026-08-04)

**3편: IYO(2학년 편입).** coei 편입 글(/257)의 축은 "기간 단축"인데, 우리 축은
**"1년을 받고 무엇을 내주는가"**로 잡았다. 근거 두 개가 결정적이다.

- **엑서터**: 파운데이션은 **150개가 넘는 학위**로 이어진다고 학교가 안내한다.
- **셰필드**: IYO는 **세 갈래뿐**이다(경영·회계 / 경제 / 심리).
→ 같은 학교 안에서 150+ 대 3이라는 대비가 그대로 글의 뼈대가 됐다.

영어 요건도 정리했다. **IYO 12곳은 전부 IELTS 5.5**고, 그중 8곳은 파운데이션이 5.0이라
같은 학생이 0.5를 더 올려야 한다(노팅엄·엑서터·요크·카디프·랭커스터·뉴캐슬·로열홀로웨이·시티).
나머지 4곳은 파운데이션도 5.5라 차이가 없다. ⚠ "IYO가 파운데이션보다 0.5 높다"고
뭉뚱그리면 틀린다 — 12곳 중 8곳이다.

**1편 msc-fees-2026의 문장 속 줄표 5개를 소급해서 없앴다.** 줄표 규칙이 그 글보다 나중에
정해져서 남아 있었다. 남은 줄표는 손대지 않았다 — 연도·금액 범위(2026–27, £23,000–£29,000)와
표 라벨(`Goldsmiths — MA Media & Communications`)은 관례다.

## 🟢 Chrome으로 학비 뚫음 + 글 4·5편 (2026-08-04)

아래에 "출처를 댈 수 없어 못 썼다"고 적었던 파운데이션 학비를 **Claude in Chrome으로 해결했다.**
WebFetch가 막히던 운영사 사이트가 실제 크롬에서는 그냥 열린다.

### 센터 학비 페이지 주소 규칙 — 다음에 그대로 쓸 것
| 운영사 | 규칙 | 확인한 값 (2026-27) |
|---|---|---|
| Study Group | **`<대학약칭>isc.com/how-to-apply/fees`** | 더럼 `durhamisc.com` £26,500~28,750 · LJMU `ljmuisc.com` £16,500 |
| Kaplan | `kaplanpathways.com/where-to-study/<센터>/fees-and-dates/` | 글래스고 £23,170~25,480 |
| 대학 자체 | 대학 도메인 안에 있다 | 에든버러 `cahss.ed.ac.uk/...` £29,600 |

⚠ **LJMU 학비표는 아코디언이라 클릭해야 숫자가 나온다.** get_page_text로는 안 잡히고
버튼을 눌러 `read_page`로 읽어야 한다.

**허브 `pathways`의 금액이 네 곳 모두 정확했다.** 7월 조사가 맞았다는 뜻이라 나머지도 신뢰할 만하다.

### 새로 나온 사실 (허브에 없던 것)
- **더럼 단기형(Accelerated) £20,250** — 같은 센터 표준 과정보다 £6,250~8,500 싸다.
- **계열이 가격을 가른다** — 더럼 인문 £26,500 / 경영 £27,500 / 이공 £28,750,
  글래스고 경영 £23,170 / 인문 £23,870 / 이공 £25,480. **운영사가 달라도 이공계가 가장 비싸다.**
- **입학이 1년에 세 번이다** — 더럼 9·11·1월, LJMU 10·11·1월(**9월 없음**),
  글래스고 가을·봄·여름.
- **LJMU는 세 입학 모두 2027-08-13에 끝난다.** 10월 시작은 열 달, 1월 시작은 일곱 달.
  늦게 시작하면 학위가 밀리는 게 아니라 과정이 압축된다.
- 11월 입학은 3주 사전 과정 뒤 1월 본과정 합류라 **사실상 1월 시작**이다.

**4편 `foundation-fees`** (cost) — 축은 "가격은 운영사가 아니라 목표 대학이 정한다".
같은 Study Group인데 LJMU £16,500, 더럼 £28,750. 막대그래프 포함.
**5편 `foundation-intakes`** (pathway) — 축은 "끝나는 날이 같다".

### ⚠ 아래는 위 문제를 겪던 시점의 기록이다 (2026-08-04, 해결됨)

축은 좋았다. 허브 데이터로 보면 파운데이션 1년이 **DMU £12,350부터 에든버러 £29,600까지**고,
**같은 운영사 안에서도 갈린다**(Study Group: LJMU £16,500 ↔ 더럼 £26,500~28,750 /
INTO: 시티 £18,500~ ↔ 뉴캐슬 ~£29,500). "가격은 기관이 아니라 대학이 정한다"는 축이 나온다.

**못 쓴 이유는 출처다.** 파운데이션 학비는 대학 페이지에 없고 운영사(Study Group·INTO·
Kaplan·Oxford International) 사이트에 있는데, 이쪽은 fetch로 금액이 안 잡힌다.
에든버러·더럼·랭커스터·DMU 네 곳을 시도했지만 전부 금액까지 못 갔다.
학비가 축인 글은 숫자마다 출처가 붙어야 한다(1편이 그래서 성립했다).

→ **다음에 할 때는 Claude in Chrome으로 운영사 사이트를 직접 열 것.** 메모리의
`claude-in-chrome-403-bypass`와 같은 상황이다. 더럼 대학 페이지도 WebFetch에 403이 났다.
→ ✅ **위에 적힌 대로 해결했다.** 주소 규칙은 이 절 위쪽 표에 정리.

---

# 영국 글 현황 (5편) 과 남은 것

| # | slug | 분류 | 축 |
|---|---|---|---|
| 1 | `msc-fees-2026` | 학비·석사 | 같은 1년 석사가 £23,000~£45,410, 계열이 가른다 |
| 2 | `foundation-accepted` | 진학 경로·학부 | 파운데이션을 마쳐도 못 가는 학교가 있다 |
| 3 | `iyo-second-year` | 진학 경로·학부 | IYO는 1년을 주고 전공 폭을 가져간다 |
| 4 | `foundation-fees` | 학비·학부 | 가격은 운영사가 아니라 목표 대학이 정한다 |
| 5 | `foundation-intakes` | 진학 경로·학부 | 늦게 시작해도 끝나는 날은 같다 |

## 🟢 학부 학비 검증 + 진단 표 정정 + 6편 (2026-08-04)

**허브 값은 확인한 7곳 전부 정확했다.** 파운데이션 4곳(더럼·LJMU·에든버러·글래스고)에 이어
학부도 옥스퍼드 `£37,380~62,820`, 임페리얼 컴퓨팅 `£45,500`이 공시와 그대로 맞았고,
LJMU 실제 과정 하나가 `£17,750`으로 우리 범위(£16,000~18,250) 안에 들어왔다.
**7월 조사의 신뢰도가 확인됐으니 나머지 40곳은 전수 재조사 대상이 아니다.**

### ⚠ 틀린 건 허브가 아니라 진단 화면이었다
`uk-study-guide`의 UG 결과 학비 표(commit 7fa8ff5)가 넓은 어림값을 쓰고 있었다.

| 항목 | 이전 | 정정 |
|---|---|---|
| 파운데이션 | £20,000 ~ 30,000 | **£16,500 ~ 29,600** (LJMU ~ 에든버러, 실측) |
| 학부 | £20,000 ~ 45,000 | **£16,000 ~ 45,500** (LJMU ~ 임페리얼) |
| 생활비 | 월 £1,529 / £1,171 | **그대로** (gov.uk와 일치, LJMU 페이지에서도 재확인) |

`costFndNote`를 "기관·계열별 차이" → **"운영사보다 대학이 가릅니다"**로,
`costUgNote`를 "실험·임상 계열이 상단" → **"의대·옥스퍼드는 £62,820까지"**로 바꿨다.
`costFoot`에 의대·치대·수의대가 범위 위에 있다는 단서를 넣었다.

⚠ **£62,820을 표 범위에 넣지 않았다.** 옥스퍼드 임상 의학은 그보다도 위라 범위로 잡으면
표가 왜곡된다. 범위는 £45,500에서 끊고 각주로 처리했다.

### 새로 확인한 사실
- **옥스퍼드는 학교 하나 안에서 £25,440이 벌어진다**(£37,380~62,820). 전공이 학교보다 크게 가른다.
- **임페리얼은 하단이 £42,700**이다. 이공계 아닌 과정이 거의 없어서 학교 전체가 비싼 구간이다.
- **대학 페이지도 UKVI 기준액을 틀리게 적는다.** 더럼 ISC는 아직 런던 외 £1,136으로 안내한다
  (현재 £1,171). 생활비는 gov.uk를 직접 볼 것.

**6편 `ug-fees-2026`** — 축은 "학교보다 전공이 크게 가른다". 옥스퍼드 내부 £25,440 격차가 훅이다.
생활비 증빙액 표도 같이 넣어 비자 계산까지 한 글에서 끝나게 했다.

## 남은 글감 — 상태별

**조사만 하면 되는 것**
- ~~학부 학비 전수 검증~~ → **완료(표본 검증). 진단 표도 정정했다.**
- **파운데이션 영어 요건** — 4.5~5.5 분포는 허브에 있는데 센터 공식값 확인이 안 됐다.
  Study Group은 `<대학>isc.com/how-to-apply/entry-requirements`에 있다(주소 규칙 확인함).
- **IYO 개설 계열 전수** — 지금 글은 5곳 표다. 16곳 다 채우면 표가 완성된다.

**데이터가 아예 없는 것 (coei 게시판에는 있다)**
- **약대** — coei 최다 주제(6편). 노팅엄·버밍엄·리버풀·브라이튼 + MMI 면접 + 52주 실무수련.
  브라이튼은 우리 DB에 학교 자체가 없다.
- **검정고시·내신 기준**, **랭킹 대비 취업률**, **Top-up 편입** — 각각 근거 자료부터 만들어야 한다.

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
