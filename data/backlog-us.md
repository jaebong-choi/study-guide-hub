# US 대학 DB 백로그

## 🔜 새 세션 인계 (2026-08-06 저녁 — 앱 크래시로 중단, 4번째)
**하다 만 일**: coei 미국 게시판 기반 글 3편 + 사진 7장. 주제 수집·선정·근거 확보까지 끝났고
본문만 안 썼다. **`data/coei-us-topics.md`에 40편 목록·선정 3편·확보된 근거·사진 계획이 다 있다.
다음 세션은 그 파일부터 열 것.** 사진은 Envato(사용자 세션 필요) — CA 때와 같은 방식.

## 이번 세션 완료분 (2026-08-06)
이번 세션에서 넷을 처리했다.
- **다크 모드가 결과 페이지에 닿는다.** us-study-guide의 `.section-light` 8곳·apple-card·학교 모달·`#home-extra`가
  다크에서 밝게 남던 문제. 이 사이트는 기본 테마가 라이트라 `html[data-theme="dark"]` 스코프로 넣었다(복원 규칙 불요).
  ⚠ a.apple-card는 뒤에 로드되는 시트가 배경을 되돌려서 `!important`가 필요했다.
- **진단 학비표를 허브 실측으로 교체.** 사립 $55K~68K → **$59,486~68,017**, 주립 $30K~50K → **$31,688~43,842**.
  옛 값은 이 백로그가 "넣지 말 것"이라 한 RESEARCH.md 카테고리 범위였다.
- **유학 정보 글 4편 시작** — `data/articles-us.json`(학비·패스웨이vs조건부·CC편입 TAG·F-1).
  build-uni.ps1 foreach에 'us' 추가, guide/us.html에 `.info-board` 컨테이너, 진단이 `articles-us-index.json`을
  fetch해 결과 하단에 띄운다(CA와 같은 방식). **다음 글감**: 영어 요건(english 분류가 아직 0편), OPT/STEM 연장,
  주립대 유학생 추가 부담금 실태.
- **학교 137곳** — 오하이오주립(QS 201)·UC 리버사이드(QS 398)·UC 머시드(QS 종합 없음→null) 추가.
  학비는 Scorecard API 단건 조회(벌크 zip과 같은 데이터): OSU $40,022 / UCR $49,806 / 머시드 $49,823.
  **TAG 6개 캠퍼스가 전부 편입 카드를 갖게 됐고**, 진단 HUB_UNI에 Ohio State 연결(미연결 0곳).
  ⚠ 새 3곳은 **youtube·로고가 아직 없다**(섹션 자동 생략). ⚠ UC 캠퍼스들의 intakes가 기본값(8월·1월)인데
  UC 신입은 가을 입학만인 캠퍼스가 많다 — 기존 데이터부터 전수 확인할 것.

## 파일 구조 — 미국만 생성 방식이 다르다
미국은 126곳이라 손편집이 아니라 **생성 방식**이다. 다른 국가는 `universities-{cc}.json`을 직접 고치지만
미국은 아래 두 소스를 고친 뒤 스크립트를 돌린다.

    data\us-source.tsv   4년제 126곳 — 한국어명·도시·QS·IELTS·전공·제휴사·US News
    data\us-cc.tsv       커뮤니티칼리지 8곳 — 학비·영어요건·편입 설명·편입 도착지까지 한 파일에
    data\us-urls.tsv     학교별 공식 홈페이지 (id → URL) · 134곳 전부
        ↓  powershell -ExecutionPolicy Bypass -File scripts\gen-us.ps1
    data\universities-us.json   (직접 고치지 말 것 — 다음 생성 때 덮어써진다)

**CC를 왜 따로 뒀나**: 4년제 학비는 교육부 College Scorecard 일괄 공시지만 CC는 각 칼리지
international 페이지 공시라 출처 성격이 다르다. 한 파일에 섞으면 어느 값이 어느 출처인지
구분이 안 된다. 페이지 푸터 학비 문구도 `type=college`면 CC 전용 문구로 갈린다
(build-uni.ps1의 `$FEE_NOTE_US_CC`).

공식 페이지로 직접 확인한 학교의 상세 문구(영어요건 note·에디터 노트)는 `gen-us.ps1`의 `$OVERRIDE` 해시에 있다.

## 기준 메모
- **순위**: QS World University Rankings **2027**(2026-06-18 발표). topuniversities.com 각 학교
  프로필 페이지에서 수집했다. 밴드(`1001-1200` 등)는 하한값을 넣는다(호주 ACU 851과 같은 방식).
- **애그리게이터 금지**: collegedunia·yocket·shiksha는 값이 서로 어긋난다. 스토니브룩이 468과 510으로
  다르게 나왔고 공식 QS 페이지가 468이었다. 순위·학비 모두 공식 소스로만 확인할 것.
- **US News**: 스키마 필드가 없어 editor_note 문장에 넣는다. 현재 6곳만 값이 있고 전부 Shorelight 공시
  기준이다(스토니브룩 59·UIC 84·아메리칸 88·어번 102·UCF 117·유타 151).
- **첨부 PDF 순위는 쓰지 않았다**: 사용자 제공 `미국대학 PDF 파일.zip`의 01~100 번호는 프린스턴 1·하버드 2·
  예일 3·MIT 7 순으로, US News 2016년 판에 가깝다. 현재 판(프린스턴 1·MIT 2·하버드 3·칼텍 11)과 크게
  달라 순위로 쓰지 않고 **학교 목록으로만** 사용했다.
- **TOEFL 척도 변경**: 2026-01-21부터 iBT가 120점제에서 구간 점수제로 바뀌었다. 학교 페이지가 신·구를
  병기하는 경우가 많으니 english.note에 둘 다 적는다.

## 입력 완료 — 126곳 (2026-08-01)
- 첨부 PDF 상위 100곳 중 99곳 (SUNY-ESF는 QS 프로필이 없어 제외)
- 패스웨이 제휴교 27곳 추가 (100위 밖이지만 사용자 결정으로 순위 무관 전량 포함)
- 제휴사별: Shorelight 18곳 · INTO 6곳 · Kaplan 5곳

## 남은 작업

### 영어 요건 출처 격상
- [ ] **IELTS 126곳 중 4곳만 공식 페이지 확인분**(ASU·스토니브룩·유타·UCF). 나머지 122곳은
      topuniversities.com 프로필의 입학 정보다. 공식 대조한 4곳은 QS 값과 전부 일치했지만
      (스토니브룩 6.5·유타 6.5·UCF 6.5·ASU 6.0) QS는 2차 출처이므로 순차적으로 공식 확인할 것.
- [ ] `english.accepted`가 대부분 `["ielts","toefl"]` 기본값이다. 듀오링고·PTE 인정 여부는
      학교별 확인이 필요해서 넣지 않았다(미확인 시험을 인정한다고 쓰면 거짓이 된다).
- [ ] 스탠퍼드는 QS에 IELTS 값이 없어 6.5로 넣었다. 실제로는 영어 시험을 요구하지 않는 경우가 많으니
      공식 확인 후 english.note에 반영할 것.

### 학비 — 입력 완료(2026-08-01), 다만 출처 성격을 알고 있을 것
- [x] **126곳 전부 입력.** 출처는 **미국 교육부 College Scorecard 2026-06-10판**
      (`Most-Recent-Cohorts-Institution.csv`, 6,273개교). `data/us-tuition.tsv`로 보관.
- **⚠ 이건 international 요율이 아니라 out-of-state 요율이다.**
      사립(CONTROL=2)은 주내=주외라 이 값이 모든 학생에게 같은 실제 금액이다.
      주립(CONTROL=1)은 주외 요율이고 유학생이 대체로 이 금액을 내지만, 학교에 따라 유학생
      추가 부담금이 붙는다. 이 사실은 uni 페이지 푸터에 문구로 밝혀 두었다
      (build-uni.ps1의 `$FEE_NOTE` 해시 — 국가별 학비 출처 문구, 미국만 별도).
- [ ] 상담 수요가 높은 학교부터 각 대학 공식 international tuition 페이지로 대조해 격상할 것.
- 대학 공식 학비 페이지는 대부분 Cloudflare 뒤라 WebFetch·브라우저 모두 403이다(스토니브룩 확인).
      개별 조사는 사실상 막혀 있어서 정부 공시 데이터로 간 것이다.
- RESEARCH.md의 카테고리 범위(사립 $55,000~68,000 · 주립 $30,000~50,000)와 coei의 CC 연 $12,000은
      학교별 값이 아니므로 넣지 말 것.

### 학비 데이터 갱신 방법
College Scorecard는 연 1회 갱신된다. 새 판이 나오면:
1. https://collegescorecard.ed.gov/data/ 에서 `Most-Recent-Cohorts-Institution_*.zip` 주소 확인
   (다운로드 호스트가 `ed-public-download.app.cloud.gov` → `ed-public-download.scorecard.network`로
   바뀐 적이 있으니 주소를 하드코딩하지 말고 페이지에서 링크를 읽을 것)
2. CSV에서 INSTURL(8) 도메인으로 `data/us-urls.tsv`와 매칭, TUITIONFEE_OUT(379) 사용
3. `data/us-tuition.tsv` 갱신 → `scripts/gen-us.ps1` → `scripts/build-uni.ps1`
- ⚠ **API(api.data.gov)는 쓰지 말 것**: DEMO_KEY가 시간당 30회라 13페이지도 못 받고,
      429 재시도 자체가 할당량을 깎아 더 막힌다. 벌크 zip은 키도 제한도 없다.

### 경로 데이터
- [ ] 패스웨이 카드의 `ielts_min`·`cost_note`가 전부 null이다. Shorelight·INTO·Kaplan 랜딩에는
      수치가 없고 프로그램별 하위 페이지("Tuition and dates")로 들어가야 한다.
- [ ] **제휴사 목록 재확인 필요**: kaplanpathways.com 현재 미국 파트너는 ASU·Pace·Simmons·UConn·
      University of Oregon으로, RESEARCH.md의 Tulsa는 빠졌다. Shorelight 18곳·INTO 6곳은
      RESEARCH.md 기록분이라 각 제휴사 사이트로 다시 대조할 것.
- [ ] **coei가 패스웨이로 언급한 위스콘신 매디슨·델라웨어·제임스매디슨은 패스웨이로 넣지 않았다.**
      제휴사 공식 목록에서 확인되지 않아 direct만 넣었다. 확인되면 us-source.tsv의 provider 열에 추가.
- [x] **커뮤니티칼리지 8곳 입력 완료(2026-08-02)**. 소스는 `data/us-cc.tsv`로 분리했다 —
      4년제는 Scorecard 공시지만 CC는 각 칼리지 international 페이지 공시라 출처 성격이 다르기 때문이다.
      샌타모니카·디앤자·디아블로밸리·어바인밸리·벨뷰·에드먼즈·시애틀센트럴·그린리버.
      `type: college` · `pathways: [transfer]` · `related_ids`로 편입 도착지 대학 연결.
- [x] **편입 도착지 대학 8곳에 transfer 경로 카드 추가**. gen-us.ps1의 `$TRANSFER` 해시.
      UC TAG 참여교(데이비스·어바인·샌타바버라·샌타크루즈) + TAG 미참여 CC 편입 대형교
      (UCLA·버클리·샌디에이고) + UW. **UC 머시드·리버사이드는 TAG 참여교지만 DB에 없어 빠졌다** —
      두 학교를 추가하면 `$TRANSFER`에도 같이 넣을 것.
- [ ] **벨뷰 칼리지 학비 미확인**. bellevuecollege.edu 전체가 Cloudflare 뒤라 WebFetch·브라우저 모두
      막힌다(브라우저는 차단 페이지 렌더링 중 앱이 죽었다). 검색 결과의 연 $29,665는 생활비 포함
      추정치라 쓰지 않았다 — 다른 7곳은 수업료+필수학교비만 담았으므로 성격이 어긋난다.
      us-cc.tsv의 tuition 칸이 비어 있고, 페이지에서는 학비 행이 그냥 안 나온다.
- [x] **`guide/us.html` 작성 완료(2026-08-01)**. 경로 4종(다이렉트·패스웨이·CC 2+2 편입·조건부 입학),
      학비표, F-1 6단계, FAQ 5문항, 공식 출처 6곳. edmuhak 페이지는 다룰 주제만 참고하고
      **본문은 국무부·국토안보부·교육부·UC 공식 자료로 새로 작성**(uk/au/ca와 같은 원칙).
      학비표는 일반 추정치가 아니라 **우리 DB 126곳의 실제 공시 학비 25~75% 구간**을 쓴다.
      연결: `$locs`에 guide/us.html 추가 · `PW_GUIDE_PAGE`에 `us-pathway` 매핑 ·
      `New-PathwayCard`가 US pathway에 guideKey 부여 · `PW_GUIDES`에 us-pathway 모달 ·
      허브 index `guide-links`에 4번째 링크.
- [x] **`us-transfer` 모달 완료(2026-08-02)**. `New-PathwayCard`에 US+transfer 분기,
      `PW_GUIDES`에 2+2 편입 설명(플로우 4단계 + 본문 2문단, ko/en), `PW_GUIDE_PAGE`는
      `../guide/us.html#cc`로 CC 카드에 바로 앵커한다. CC 8곳 페이지와 편입 도착지 대학 8곳
      양쪽에서 같은 모달이 뜬다.
- [ ] 미국 direct 경로는 모달 없이 진단으로 직행한다(다른 국가의 direct와 동일).
      **조건부 입학**은 아직 학교 데이터에 pathway 타입으로 안 들어가 있어 모달이 없다.

### 콘텐츠
- [ ] editor_note가 7곳만 있다(나머지 null이면 섹션 자체가 안 나온다). 상담 수요 높은 학교부터 채울 것.
- [x] **에디터 노트 전량 작성 완료(2026-08-02)**. 미국 134곳 포함 **4개국 235곳 전부** 노트를 갖췄다.
      미국 노트는 `data/us-notes.tsv`에 있다 — `$OVERRIDE` 해시에 126개를 넣으면 스크립트를 읽을 수 없고,
      `universities-us.json`은 생성물이라 직접 넣을 수도 없어서 파일을 분리했다.
      영국·호주·캐나다는 각 `universities-{cc}.json`의 `editor_note`를 직접 고쳤다.
- [x] **에디터 노트 2차 humanizer 완료(2026-08-02)**. 1차 초안이 `QS N위. A와 B가 강합니다. 학비는
      연 N달러 선입니다.` 한 틀로 찍혀 있었다. 개별 문장은 멀쩡한데 연달아 보면 기계로 찍은 티가 났다.
      **고친 것은 문장이 아니라 틀이다** — 사실은 그대로 두고 순서·길이·마무리만 바꿨다.
      `QS`로 시작하는 노트 **106 → 9곳**. 어미 쏠림도 흩었다(`~선입니다` 19 → 10, `~달러대입니다` 17 → 1).
      **판단 한 줄로 끝나는 노트가 16 → 134곳 전부**가 됐다.
      손대지 않은 16곳은 1차 때 이미 판단이 들어가 있던 것들이다(MIT·UCLA·퍼듀·스토니브룩·ASU·BYU·
      조지아텍·로체스터·아이오와·콜로라도마인스·클리블랜드주립·털사·SMC·디앤자·IVC·벨뷰).
      i18n 영어도 118건 같이 갈았다. 빌드에서 누락 0건.
- 노트 톤 기준: **us-stony-brook 노트**. 상담사가 말하는 어투, 짧은 문장 변주, 순위·학비 수치는 유지.
      /anthropic-skills:humanizer 로 검수했다. 명사구 + 2문장이 반복되면 기계로 찍은 티가 나므로
      길이와 마무리를 섞을 것. 사실 나열로 끝내지 말고 **판단을 한 줄 얹는다**
      (예: "신입으로 붙기 어려우면 이쪽부터 봅니다", "포트폴리오를 일찍 시작해야 합니다").
- ⚠ **근거는 DB에 있는 값만 쓴다**: QS 종합·과목 순위, 도시, 학비, IELTS, 제휴사, 개설 경로.
      학교별 특기 사항을 새로 조사하지 않고 지어내면 안 된다. 대신 DB 값끼리 비교하면 쓸 말이 나온다
      (퍼듀 QS 100위에 학비 2만 9천 달러, 러프버러 종합 225위인데 스포츠 세계 1위 같은 식).
- ⚠ **노트를 고치면 `data/i18n-uni.json`에 영어 번역도 같이 고칠 것.** 빌드가 누락을 알려준다.
- [x] **로고 105/126** (2026-08-01). 출처는 **위키데이터 P154(로고) → Wikimedia Commons 파일**.
      Commons 호스팅만 받았으므로 자유 라이선스다(en.wikipedia의 비자유 fair-use 파일은 받지 않음).
      수집: 위키데이터 SPARQL로 미국 대학 1,103건의 로고+공식 URL을 받아 `us-urls.tsv` 도메인으로 매칭.
- ⚠ **위 "21곳" 목록은 낡았다.** 이후 대부분 채워졌다. 파일 기준으로 세는 게 정확하다
      (`images/uni/{id}-logo.(png|svg)` 존재 여부 = 빌드가 보는 것과 같다).
- [x] **미국 129/134 (2026-08-02)**. 커먼즈로 못 채운 곳을 각 학교 공식 사이트에서 받았다.
      **UCF 포함** — `/brand/brand-assets/logo-identity-system/`의 페가수스+UCF 마크다.
      **운동부 로고 교체분 3곳도 정식 로고로 바꿨다**: 코넬(공식 씰, cornell.css의 `logo-red.png`) ·
      곤자가(GONZAGA UNIVERSITY 워드마크) · 제임스매디슨(검정 JMU 학사 로고, 보라·금 Dukes 아님).
      수집 절차는 `backlog-ca.md`의 "로고 수집 방법"에 적어 뒀다.
- [ ] **데이턴·UNC는 흰색 판만 공개한다.** 데이턴 `footer-logo.svg`는 전체가 `fill:#fff`,
      UNC `University_Signature_White_Navy_rgb_h.svg`는 NC 마크가 `#fff`+글자만 `#13294b`라
      라이트 모드에서 마크가 사라진다. 색을 바꿔 쓰는 건 브랜드 자산 변형이라 하지 않았다.
      **두 곳은 아직 운동부 마크가 걸려 있다**(코넬·곤자가·제임스매디슨만 교체 완료).
- [ ] **미국 130/134 — 남은 4곳**: 디앤자·벨뷰(Cloudflare 403, **헤드리스 렌더로도 안 뚫림**) ·
      시애틀센트럴(로고가 이미지가 아니라 **아이콘 폰트 글리프** `content:"\e903"`라 긁을 수 없음) ·
      그린리버(흰색 판만 공개). DVC는 헤드리스 DOM에서 스프라이트 심볼을 꺼내 해결했다.
      SMC·어바인밸리·에드먼즈도 받았다.
- ⚠ **자동 수집에서 걸러낸 것들** — 같은 방식으로 보충할 때 반드시 확인할 것:
  - **씰·문장 6개 제외**(upenn·yale·columbia·wisconsin·georgia-tech·baylor). 다크 모드에서 로고를
    밝은 판 위에 얹는 구조라 다색 씰은 뭉개지고, 컬럼비아 문장은 SVG 하나가 1.3MB였다.
  - **운동부 로고 8개 제외**(unc=Tar Heels, iowa=Hawkeyes, wake-forest, william-mary, vermont,
    tulsa, san-diego=Toreros, gonzaga=Bulldogs). 이름 검색이 물어온 것으로, 대학 로고가 아니다.
  - **엉뚱한 대학 1개 제외**: `us-saint-louis`에 벨기에 **UCLouvain Saint-Louis Bruxelles** 로고가
    받아졌다. 이름 검색(wbsearchentities)은 동명 대학을 물어오니 파일명을 반드시 눈으로 확인할 것.
  - jpg/jpeg는 투명 배경이 아니라 제외(cornell·jhu). jhu는 이후 png로 재확보.
- [ ] **운동부 로고 교체 (2026-08-02 전수 육안 감사)**. 사용자 지시: 전 국가 모두 운동부 마크가 아니라
      정식 대학 로고를 쓸 것. 220개를 국가별 contact sheet로 렌더해 눈으로 확인했다.
      **영국 49 · 호주 34 · 캐나다 17은 전부 정식 로고였고, 미국 120곳에서만 문제가 나왔다.**
  - **교체 확정 5곳**: us-cornell(붉은 CORNELL 블록) · us-dayton(붉은 이탤릭=Flyers) ·
    us-gonzaga(아치형 운동부 서체) · us-james-madison(보라·금 JMU 블록=Dukes) · us-unc(NC 인터로킹=Tar Heels)
- ⚠ **1차 감사에서 5곳을 잘못 지목했다 — 되돌렸다.** us-iowa · us-lsu · us-tcu · us-purdue · us-missouri는
      운동부 마크처럼 보이지만 **각 대학 공식 홈페이지 헤더가 바로 그 마크를 쓰고 있다**(iowa.edu의 검정 IOWA
      블록, purdue.edu의 Motion P, tcu.edu의 TCU, lsu.edu의 LSU, missouri.edu의 금색 MU).
      미국 대학은 학사 로고와 운동부 서체가 같은 계열인 경우가 흔하므로 **"블록체=운동부"로 단정하지 말 것.**
      판별 기준은 서체가 아니라 **그 학교 공식 사이트 헤더에 무엇이 걸려 있는가**다.
- [ ] **판단 보류 4곳** — 같은 이유로 그대로 두었다(공식 사이트에서도 쓰는 마크):
      us-asu(피치포크) · us-texas-am(ATM 블록) · us-wyoming(버킹호스) · us-oregon-state(주황 OSU).
- ⚠ **감사 방법**: 헤드리스 Edge로 로고 contact sheet를 PNG로 렌더해서 봤다. SVG는 XML만 봐서는
      판별이 안 되고(내부에 운동부 단서 텍스트가 없다), 인앱 브라우저는 응답이 없거나 앱을 죽인다.
      `msedge.exe --headless=new --screenshot=... --window-size=1280,980` 방식이 유일하게 동작했다.
- ⚠ **커먼즈로는 못 채운다**: 로고 없는 6곳(emory·ucf·wake-forest·william-mary·san-diego·marquette)은
      위키데이터 **P154(공식 로고) 속성이 전부 비어 있고**, 커먼즈 검색 결과도 운동부 로고이거나
      산하기관(Emory Law·Medical School)·동명 타교(Emory & Henry)뿐이다. 교체분 10곳도 사정이 같다.
      **각 대학 공식 브랜드 페이지에서 받아야 하고, 그러면 기존 120개의 커먼즈 자유 라이선스 근거가
      이 16개에는 적용되지 않는다.** 진행 전 사용자 확인 필요.
- [x] **youtube_id 134/134 완료(2026-08-02)**. 소스는 `data/us-youtube.tsv`(id → videoId),
      gen-us.ps1의 `YtMap`이 읽는다. JSON은 생성물이라 직접 넣지 말 것.
      공식 채널(본채널·입학처·국제처) 영상만 골라 oEmbed로 채널·제목을 전수 검증했다.
      1차 수집 오답이 많았다 — UT오스틴 자리에 교회 채널, 미주리 자리에 컬럼비아대,
      벨뷰 칼리지 자리에 네브래스카 벨뷰대, 운동부 채널 여럿(Gamecocks·Stevens Ducks 등).
      **토큰 매칭만 믿지 말고 채널명 필수/금지어 필터 + oEmbed 검증까지 돌릴 것.**
- [ ] `popular_majors`는 어휘를 고정해서 넣었다(i18n 사전 폭증 방지). 새 전공어를 쓰면
      빌드가 `data/i18n-uni-missing.txt`로 알려주니 i18n-uni.json에 추가할 것.
- [x] us-study-guide 진단 결과 → uni 페이지 연결. **2026-08-02 전수 검증: 진단 대학 28곳 중
      27곳 매핑 + CC 8곳 `hub` 필드, id 전부 허브 페이지 실재.** 유일한 미연결은
      **Ohio State** — 허브 DB에 학교 자체가 없어서 규칙대로 버튼을 안 만든다.
      오하이오주립을 DB에 추가하면 us-study-guide의 HUB_UNI에도 같이 넣을 것.

### us-study-guide(진단 사이트)와 맞춘 것 — 2026-08-02
CC 영어요건을 공식 페이지로 대조하면서 진단 사이트 `ccColleges`의 값 3건이 틀린 것을 확인해 양쪽을 고쳤다.
- 벨뷰: IELTS 5.5 → **6.0**(모든 영역 5.5 이상)
- 시애틀센트럴: IELTS 5.5 → **6.0**(라이팅 5.0). 5.5는 단기 certificate 기준이었다
- 그린리버: '점수 없이 입학 가능' → **Academic Transfer는 IELTS 5.5**(밴드 5.0 미만 없음).
  점수가 없으면 IEP부터 시작하는 구조라 '점수 없이 입학'은 과장이었다
진단 사이트 CC 카드에 허브 상세 페이지 링크(`hub` 필드)도 추가했다. **한쪽만 고치면 두 사이트가 어긋난다.**

### 참고 링크
- edmuhak 대학 검색은 **영국만** 있다. 사용자가 준 `country=1`은 미국이 아니라 영국이고,
  `country=2`는 대학(일반) 0건이다. 미국 학교 목록 소스로는 쓸 수 없다.
- coei university-admissions 페이지: 경로 4종(패스웨이·조건부입학·CC 편입·대학원)과 제휴교 목록.

### 완료
- [x] 배너: 국가 공용 us-banner.jpg 적용 · 허브 index.html에 미국 배너(4장째) + `.uni-banner--us` CSS + i18n 키
- [x] 공식 홈페이지 126곳 전수 확인(HTTP 또는 DNS). Cloudflare 뒤 13곳은 403이라 DNS로 확인함
