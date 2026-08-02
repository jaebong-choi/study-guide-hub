# US 대학 DB 백로그

## 파일 구조 — 미국만 생성 방식이 다르다
미국은 126곳이라 손편집이 아니라 **생성 방식**이다. 다른 국가는 `universities-{cc}.json`을 직접 고치지만
미국은 아래 두 소스를 고친 뒤 스크립트를 돌린다.

    data\us-source.tsv   학교별 한국어명·도시·QS·IELTS·전공·제휴사·US News
    data\us-urls.tsv     학교별 공식 홈페이지 (id → URL)
        ↓  powershell -ExecutionPolicy Bypass -File scripts\gen-us.ps1
    data\universities-us.json   (직접 고치지 말 것 — 다음 생성 때 덮어써진다)

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
- [ ] 커뮤니티칼리지 2+2 편입(transfer) 경로 미입력. UC TAG 6개 캠퍼스와 Santa Monica·De Anza·
      Bellevue 등은 us-study-guide/docs/RESEARCH.md에 정리돼 있다.
- [x] **`guide/us.html` 작성 완료(2026-08-01)**. 경로 4종(다이렉트·패스웨이·CC 2+2 편입·조건부 입학),
      학비표, F-1 6단계, FAQ 5문항, 공식 출처 6곳. edmuhak 페이지는 다룰 주제만 참고하고
      **본문은 국무부·국토안보부·교육부·UC 공식 자료로 새로 작성**(uk/au/ca와 같은 원칙).
      학비표는 일반 추정치가 아니라 **우리 DB 126곳의 실제 공시 학비 25~75% 구간**을 쓴다.
      연결: `$locs`에 guide/us.html 추가 · `PW_GUIDE_PAGE`에 `us-pathway` 매핑 ·
      `New-PathwayCard`가 US pathway에 guideKey 부여 · `PW_GUIDES`에 us-pathway 모달 ·
      허브 index `guide-links`에 4번째 링크.
- [ ] 미국 direct 경로는 모달 없이 진단으로 직행한다(다른 국가의 direct와 동일). CC 편입·조건부
      입학은 학교 데이터에 pathway 타입으로 안 들어가 있어 모달이 없다. transfer 경로를 넣게 되면
      `us-transfer` 키를 만들어 매핑할 것.

### 콘텐츠
- [ ] editor_note가 7곳만 있다(나머지 null이면 섹션 자체가 안 나온다). 상담 수요 높은 학교부터 채울 것.
- [ ] **에디터 노트 humanizer 일괄 적용(사용자 요청 2026-08-02)**: 상담사가 직접 말하는 톤으로 전부 재작성.
      샘플은 gen-us.ps1 $OVERRIDE의 us-stony-brook note(주석 표시됨) — 짧은 문장 변주, "~라 자주 씁니다"처럼
      경험에서 말하는 어미, 순위·수치는 유지. 재작성 시 /anthropic-skills:humanizer 스킬을 로드해 검수하고,
      바꾼 문구마다 data/i18n-uni.json에 영어 번역을 같이 추가할 것(빌드가 누락을 알려줌).
- [x] **로고 105/126** (2026-08-01). 출처는 **위키데이터 P154(로고) → Wikimedia Commons 파일**.
      Commons 호스팅만 받았으므로 자유 라이선스다(en.wikipedia의 비자유 fair-use 파일은 받지 않음).
      수집: 위키데이터 SPARQL로 미국 대학 1,103건의 로고+공식 URL을 받아 `us-urls.tsv` 도메인으로 매칭.
- [ ] **로고 없는 21곳**: us-emory, us-georgia, us-ucf, us-marquette, us-dayton, us-cornell,
      us-upenn, us-yale, us-columbia, us-wisconsin, us-georgia-tech, us-baylor, us-unc, us-iowa,
      us-wake-forest, us-william-mary, us-vermont, us-tulsa, us-san-diego, us-gonzaga, us-saint-louis
- ⚠ **자동 수집에서 걸러낸 것들** — 같은 방식으로 보충할 때 반드시 확인할 것:
  - **씰·문장 6개 제외**(upenn·yale·columbia·wisconsin·georgia-tech·baylor). 다크 모드에서 로고를
    밝은 판 위에 얹는 구조라 다색 씰은 뭉개지고, 컬럼비아 문장은 SVG 하나가 1.3MB였다.
  - **운동부 로고 8개 제외**(unc=Tar Heels, iowa=Hawkeyes, wake-forest, william-mary, vermont,
    tulsa, san-diego=Toreros, gonzaga=Bulldogs). 이름 검색이 물어온 것으로, 대학 로고가 아니다.
  - **엉뚱한 대학 1개 제외**: `us-saint-louis`에 벨기에 **UCLouvain Saint-Louis Bruxelles** 로고가
    받아졌다. 이름 검색(wbsearchentities)은 동명 대학을 물어오니 파일명을 반드시 눈으로 확인할 것.
  - jpg/jpeg는 투명 배경이 아니라 제외(cornell·jhu). jhu는 이후 png로 재확보.
- [ ] youtube_id 전부 null.
- [ ] `popular_majors`는 어휘를 고정해서 넣었다(i18n 사전 폭증 방지). 새 전공어를 쓰면
      빌드가 `data/i18n-uni-missing.txt`로 알려주니 i18n-uni.json에 추가할 것.
- [ ] us-study-guide 진단 결과 → uni 페이지 연결 (uk/au의 HUB_UNI 패턴)

### 참고 링크
- edmuhak 대학 검색은 **영국만** 있다. 사용자가 준 `country=1`은 미국이 아니라 영국이고,
  `country=2`는 대학(일반) 0건이다. 미국 학교 목록 소스로는 쓸 수 없다.
- coei university-admissions 페이지: 경로 4종(패스웨이·조건부입학·CC 편입·대학원)과 제휴교 목록.

### 완료
- [x] 배너: 국가 공용 us-banner.jpg 적용 · 허브 index.html에 미국 배너(4장째) + `.uni-banner--us` CSS + i18n 키
- [x] 공식 홈페이지 126곳 전수 확인(HTTP 또는 DNS). Cloudflare 뒤 13곳은 403이라 DNS로 확인함
