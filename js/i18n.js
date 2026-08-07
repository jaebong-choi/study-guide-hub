/* =========================================================
 * i18n — 한국어(ko) / English(en)
 * =========================================================
 * 사용법
 *  - 텍스트만 바꿀 요소:  <p data-i18n="키">…</p>
 *  - HTML(<br> 등) 포함:  <h1 data-i18n-html="키">…</h1>
 *  - 값이 끼어드는 문장은 함수형 키로 정의한다. 예) count: n => `${n} results`
 *
 * 선택한 언어는 localStorage("sgh-lang")에 저장되며, 허브·호주·영국·캐나다
 * 사이트가 같은 도메인이라 키를 공유한다. 한 곳에서 고르면 전체에 유지된다.
 * (어학연수 지도는 중국어를 포함한 자체 키 "esl-map-lang"을 따로 쓴다.)
 *
 * 영어 문구 톤: QS Top Universities 안내 페이지 기준.
 * 2인칭으로 담백하게, 과장·광고 표현 없이 사실 위주로 쓴다.
 * ========================================================= */
const I18N = {
    ko: {
        langName: "한국어",

        docTitle: "유학, 진단에서 시작하세요 | Study Guide Hub",
        docDesc: "미국·영국·호주·캐나다 국가별 3분 AI 진단으로 내 조건에 맞는 진학 경로를 확인하세요. 어학연수는 6개국 어학원 지도로. 특정 유학원과 무관한 무료 정보 가이드.",

        headerCta: "상담 문의",
        themeDark: "다크",
        themeLight: "라이트",
        themeAria: "화면 모드 전환",
        themeTitle: "밝게 / 어둡게",
        langAria: "언어 선택",

        heroEyebrow: "🌏 <strong>무료 유학 가이드</strong> · US / UK / AU / CA & ESL",
        heroTitle: "유학, 진단에서<br>시작하세요",
        heroSub: "국가별 3분 진단으로 내 조건에 맞는 진학 경로를 확인하고,<br class=\"br-desktop\">결과 그대로 상담까지 이어가세요.",

        /* 히어로 슬라이드 3장 — ① 3분 입학 진단 ② 국가별 최신 대학 정보 ③ 전문가 게시글 */
        hs1Title: "내 성적으로 갈 수 있는<br>길부터 확인하세요",
        hs1Sub: "미국·영국·호주·캐나다, 국가별 3분 대학 입학 진단을 무료로 제공합니다.",
        hs2Title: "국가별 최신 대학 정보를<br>학교 페이지로 정리했습니다",
        hs2Sub: "4개국 대학 259곳의 학비와 입학 요건을 공식 공시에서 직접 확인해 담았습니다.",
        hs3Title: "전문가가 확인한<br>최신 유학 정보 게시글",
        hs3Sub: "규정과 학비가 바뀔 때마다 공식 원문을 확인해 국가별 게시판에 올립니다.",
        heroChipsLabel: "3분 진단 바로 시작",
        heroBrowse: "학교별로 먼저 둘러보기 ↓",
        heroDotsAria: "히어로 소개 선택",
        heroDot: n => n + "번째 소개",

        /* 학교별 행 한 줄 요약 */
        rowUsSub: "아이비리그 · 패스웨이 제휴 · 커뮤니티칼리지",
        rowUkSub: "QS 순위 · 연간 학비 · IELTS · 진학 경로",
        rowAuSub: "Go8 명문 · 요리학교 · TAFE · 편입 경로",
        rowCaSub: "UofT·UBC · 공립 컬리지 · 편입·PGWP",

        /* 최신 유학 정보 */
        sectionLatest: "최신 유학 정보",
        latestMin: n => "약 " + n + "분",

        sectionUniGuide: "학교별로 알아보기",
        bannerUkTitle: "영국 대학교 49곳",
        bannerUkSub: "QS 순위·연간 학비·IELTS 기준·진학 경로를 학교별로 정리했습니다.",
        bannerAuTitle: "호주 대학교 35곳",
        bannerAuSub: "Go8 명문부터 요리학교·TAFE까지, 학비·요건·편입 경로를 한눈에.",
        bannerGo: "학교 목록 보기 →",
        bannerUkAlt: "영국 대학 미니어처와 상담 장면",
        bannerAuAlt: "호주 랜드마크 미니어처와 출국 장면",
        bannerCaTitle: "캐나다 대학·컬리지 32곳",
        bannerCaSub: "UofT·UBC부터 핵심 공립 컬리지까지, 편입·PGWP 경로를 정리했습니다.",
        bannerCaAlt: "캐나다 랜드마크 미니어처와 입국 심사 장면",
        bannerUsTitle: "미국 대학·컬리지 134곳",
        bannerUsSub: "아이비리그부터 패스웨이(조건부입학) 제휴 대학, 2+2 편입 출발점인 커뮤니티칼리지까지. QS 순위·IELTS 기준·진학 경로를 정리했습니다.",
        bannerUsAlt: "미국 랜드마크 미니어처와 유학생 장면",
        guideLinkUk: "영국 진학 가이드: 경로 · 학비 · 비자 →",
        guideLinkAu: "호주 진학 가이드: 경로 · 학비 · 비자 →",
        guideLinkCa: "캐나다 진학 가이드: 경로 · 학비 · 비자 →",
        guideLinkUs: "미국 진학 가이드: 경로 · 학비 · 비자 →",

        sectionCountries: "국가별 진단 시작하기",
        auName: "호주",
        auDesc: "학부(디플로마·파운데이션)부터 석사(GE)까지 3분 진단. 2026 대학 공식 학비 데이터 기반.",
        ukName: "영국",
        ukDesc: "학부(파운데이션·IYO)부터 석사(프리마스터)까지 진단. QS 2027 랭킹 데이터 기반.",
        caName: "캐나다",
        caDesc: "공립 컬리지 PGWP(졸업 후 취업허가)·대학 편입 진단. 2026 IRCC 정책 기준.",
        usName: "미국",
        usDesc: "Direct·패스웨이·2+2 편입 3개 경로 진단. US News 2026 랭킹 데이터 기반.",
        cardGo: "진단 시작",
        auAlt: "하버브리지에서 본 시드니 오페라하우스와 도심",
        ukAlt: "석양의 런던 타워브리지 항공 전경",
        caAlt: "호수에서 본 토론토 CN타워와 스카이라인",
        usAlt: "맨해튼 마천루 항공 전경",

        eslTitle: "대학 진학이 아니라 어학연수를 알아보고 있다면",
        eslSub: "영국 · 아일랜드 · 몰타 · 캐나다 · 호주 · 뉴질랜드, 6개국 어학원을 지도에서 한눈에 비교하세요.",
        eslGo: "지도 보기",

        contactTitle: "진단 결과, 그대로 상담받으세요",
        contactLead: "진단을 마친 뒤 궁금한 점이 있다면 편한 창구로 문의해 주세요. 특정 유학원과 무관한 무료 안내입니다.",
        btnConsult: "무료 상담 신청",
        btnKakao: "카카오톡 채널 추가",
        contactNote: "진단 결과 링크를 함께 보내주시면 더 정확한 안내가 가능합니다.",

        footerPrivacy: "개인정보처리방침",
        footerDisclaimer: "본 사이트는 특정 유학원·기관과 무관한 무료 정보 페이지입니다. 각 진단에 사용된 학비는 정규 공식 학비 기준이며, 실제 등록 비용은 프로모션·할인에 따라 달라질 수 있으므로 상담에서 확인하시기 바랍니다.",
        footerContact: "문의:",

        noticeFormPending: "상담 신청 폼은 준비 중입니다. 잠시 후 다시 시도해 주세요.",
        noticeKakaoPending: "카카오톡 채널은 준비 중입니다. 아래 무료 상담 신청을 이용해 주세요.",

        /* ---------- 문의 모달 ---------- */
        formTitle: "무료 상담 신청",
        formSub: "남겨주신 연락처로 안내드립니다. 특정 유학원과 무관한 무료 안내입니다.",
        formName: "이름",
        formContact: "연락처",
        formContactPh: "전화번호 또는 카카오톡 ID",
        formCountry: "관심 국가",
        formCountryPh: "선택해 주세요",
        formCountryEsl: "어학연수",
        formCountryEtc: "아직 못 정했어요",
        formMsg: "문의 내용 (선택)",
        formAgree: "개인정보 수집·이용에 동의합니다.",
        formAgreeLink: "처리방침 보기",
        formSubmit: "신청하기",
        formSending: "전송 중...",
        formError: "전송에 실패했습니다. 잠시 후 다시 시도해 주세요.",
        formDoneTitle: "접수되었습니다",
        formDoneSub: "남겨주신 연락처로 곧 안내드리겠습니다. 감사합니다.",
        formClose: "닫기",

        /* ---------- privacy.html ---------- */
        privDocTitle: "개인정보처리방침 | Study Guide Hub",
        privDocDesc: "Study Guide Hub 개인정보처리방침 — 수집 항목, 이용 목적, 보유 기간 안내.",
        privTitle: "개인정보처리방침",
        privDate: "시행일: 2026년 7월 27일",
        privIntro: "본 사이트는 유학 상담 안내를 위해 최소한의 개인정보만을 수집하며, 아래와 같이 처리합니다.",
        priv1Title: "1. 수집하는 개인정보 항목",
        priv1Item1: "이름",
        priv1Item2: "연락처 (전화번호 또는 카카오톡 ID)",
        priv1Item3: "(선택) 관심 국가, 남기고 싶은 말",
        priv2Title: "2. 수집 및 이용 목적",
        priv2Body: "유학 상담 안내를 위한 연락 목적으로만 이용합니다. 그 외 목적으로 이용하지 않습니다.",
        priv3Title: "3. 보유 및 이용 기간",
        priv3Body: "상담 종료 또는 동의 철회 시까지 보유하며, 최대 1년을 넘기지 않습니다. 기간이 지나면 지체 없이 파기합니다.",
        priv4Title: "4. 제3자 제공 및 처리 위탁",
        priv4Body: "수집한 개인정보를 제3자에게 제공하지 않습니다. 상담 신청은 자체 접수 시스템으로 받으며, 접수된 정보는 Cloudflare(해외 소재 클라우드 인프라)에 암호화 전송되어 저장되고 위 목적으로만 사용합니다.",
        priv5Title: "5. 동의 철회 및 문의",
        priv5Body: "개인정보 열람·수정·삭제 및 동의 철회는 아래 이메일로 요청하실 수 있습니다.",
        privContact: "문의처:",
        privBack: "← 홈으로 돌아가기"
    },

    en: {
        langName: "English",

        docTitle: "Find your route to studying abroad | Study Guide Hub",
        docDesc: "Three-minute assessments for the US, the UK, Australia and Canada, plus a map of language schools across six countries. Free guidance, independent of any agency.",

        headerCta: "Get in touch",
        themeDark: "Dark",
        themeLight: "Light",
        themeAria: "Switch colour mode",
        themeTitle: "Light / dark",
        langAria: "Select language",

        heroEyebrow: "🌏 <strong>Free Study Abroad Guide</strong> · US / UK / AU / CA & ESL",
        heroTitle: "Find your route to<br>studying abroad",
        /* 영어는 강제 줄바꿈 없이 흐르게 둔다. <br>를 넣으면 문장 중간에서 끊긴다.
           줄 길이는 CSS의 text-wrap: pretty가 고르게 맞춘다. */
        heroSub: "Take a three-minute assessment for your chosen country, see which entry pathways match your grades and goals, then take the result to an advisor.",

        /* Hero slides */
        hs1Title: "Start with the routes your grades can reach",
        hs1Sub: "Free three-minute admissions assessments for the US, the UK, Australia and Canada.",
        hs2Title: "The latest university information, country by country",
        hs2Sub: "Fees and entry requirements for 259 universities and colleges, checked against each school's official pages.",
        hs3Title: "Expert-checked study abroad updates",
        hs3Sub: "When rules or fees change, we verify the official source and post it to each country's board.",
        heroChipsLabel: "Start a three-minute assessment",
        heroBrowse: "Browse universities first ↓",
        heroDotsAria: "Choose a hero slide",
        heroDot: n => "Slide " + n,

        /* University rows */
        rowUsSub: "Ivy League, pathway partners and community colleges",
        rowUkSub: "QS rank, tuition, IELTS and entry routes",
        rowAuSub: "The Go8, culinary schools, TAFE and transfer routes",
        rowCaSub: "UofT, UBC, public colleges, transfer and PGWP",

        /* Latest updates */
        sectionLatest: "Latest updates",
        latestMin: n => n + " min read",

        sectionUniGuide: "Browse by university",
        bannerUkTitle: "49 UK universities",
        bannerUkSub: "QS rankings, annual tuition, IELTS requirements and entry routes, school by school.",
        bannerAuTitle: "35 Australian universities",
        bannerAuSub: "From the Go8 to culinary schools and TAFE: fees, requirements and transfer routes at a glance.",
        bannerGo: "Browse the list →",
        bannerUkAlt: "Miniature UK landmarks and a study consultation scene",
        bannerAuAlt: "Miniature Australian landmarks and a departure scene",
        bannerCaTitle: "32 Canadian universities and colleges",
        bannerCaSub: "From UofT and UBC to the key public colleges: transfer and PGWP routes.",
        bannerCaAlt: "Miniature Canadian landmarks and a border-arrival scene",
        bannerUsTitle: "134 US universities and colleges",
        bannerUsSub: "From the Ivy League to the conditional-entry pathway partners and the community colleges that start a 2+2 transfer: QS ranks, IELTS levels and routes in.",
        bannerUsAlt: "Miniature US landmarks and international students",
        guideLinkUk: "UK guide: routes, costs and visas →",
        guideLinkAu: "Australia guide: routes, costs and visas →",
        guideLinkCa: "Canada guide: routes, costs and visas →",
        guideLinkUs: "US guide: routes, costs and visas →",

        sectionCountries: "Choose a destination",
        auName: "Australia",
        auDesc: "Undergraduate routes through diploma and foundation programmes, plus master's entry including graduate entry. Based on official 2026 university tuition data.",
        ukName: "United Kingdom",
        ukDesc: "Undergraduate routes through foundation and international year one, plus pre-master's entry. Based on QS 2027 ranking data.",
        caName: "Canada",
        caDesc: "Public college routes to a post-graduation work permit (PGWP), and transfer to a university degree. Based on 2026 IRCC policy.",
        usName: "United States",
        usDesc: "Three routes compared — direct entry, pathways and 2+2 community-college transfer. Based on US News 2026 ranking data.",
        cardGo: "Start assessment",
        auAlt: "Sydney Harbour and the Opera House seen from the Harbour Bridge",
        ukAlt: "Aerial view of Tower Bridge, London, at sunset",
        caAlt: "The Toronto skyline and CN Tower seen from the water",
        usAlt: "Aerial view of Manhattan skyscrapers",

        eslTitle: "Looking for a language course rather than a degree?",
        eslSub: "Compare language schools across six countries — the UK, Ireland, Malta, Canada, Australia and New Zealand — on a single map.",
        eslGo: "Open the map",

        contactTitle: "Talk your result through with an advisor",
        contactLead: "Once you have your result, get in touch whichever way suits you. This is free guidance, independent of any agency.",
        btnConsult: "Request free advice",
        btnKakao: "Add KakaoTalk channel",
        contactNote: "Including the link to your result helps us give you a more precise answer.",

        footerPrivacy: "Privacy policy",
        footerDisclaimer: "This site is a free information resource and is not affiliated with any agency or institution. Tuition figures are the official published rates; what you actually pay can differ with scholarships or promotions, so confirm the amount when you speak to an advisor.",
        footerContact: "Contact:",

        noticeFormPending: "The request form is not ready yet. Please try again shortly.",
        noticeKakaoPending: "The KakaoTalk channel is not open yet. Please use the free advice request below.",

        /* ---------- Consult modal ---------- */
        formTitle: "Request free advice",
        formSub: "We will get back to you at the contact you leave. Free guidance, independent of any agency.",
        formName: "Name",
        formContact: "Contact",
        formContactPh: "Phone number or KakaoTalk ID",
        formCountry: "Country of interest",
        formCountryPh: "Choose one",
        formCountryEsl: "Language course",
        formCountryEtc: "Not decided yet",
        formMsg: "Your question (optional)",
        formAgree: "I agree to the collection and use of my personal information.",
        formAgreeLink: "Privacy policy",
        formSubmit: "Send request",
        formSending: "Sending...",
        formError: "Could not send. Please try again shortly.",
        formDoneTitle: "Request received",
        formDoneSub: "We will contact you shortly. Thank you.",
        formClose: "Close",

        /* ---------- privacy.html ---------- */
        privDocTitle: "Privacy policy | Study Guide Hub",
        privDocDesc: "Study Guide Hub privacy policy — what we collect, why, and how long we keep it.",
        privTitle: "Privacy policy",
        privDate: "Effective 27 July 2026",
        privIntro: "This site collects only the minimum personal information needed to respond to a study abroad enquiry, and handles it as set out below.",
        priv1Title: "1. Information we collect",
        priv1Item1: "Name",
        priv1Item2: "Contact details (phone number or KakaoTalk ID)",
        priv1Item3: "Optional: country of interest, and anything you would like to add",
        priv2Title: "2. Why we collect it",
        priv2Body: "We use it only to contact you with study abroad guidance. We do not use it for any other purpose.",
        priv3Title: "3. How long we keep it",
        priv3Body: "We keep it until your enquiry is closed or you withdraw consent, and for no longer than one year. It is deleted promptly once that period ends.",
        priv4Title: "4. Sharing and processing by others",
        priv4Body: "We do not share your information with third parties. Enquiries are received through our own form, transmitted over an encrypted connection, stored on Cloudflare infrastructure, and used only for the purpose above.",
        priv5Title: "5. Withdrawing consent and contacting us",
        priv5Body: "To view, correct or delete your information, or to withdraw consent, email us at the address below.",
        privContact: "Contact:",
        privBack: "← Back to home"
    }
};

/* 현재 언어. 허브의 기본값은 한국어다(브라우저 언어와 무관하게 항상 동일).
 * 저장된 선택이 없으면 "ko"를 저장까지 해서, 이어서 여는 국가별 사이트
 * (같은 도메인·같은 키)에도 그대로 이어지게 한다. */
let LANG = (function () {
    try {
        var saved = localStorage.getItem("sgh-lang");
        if (saved === "ko" || saved === "en") return saved;
        localStorage.setItem("sgh-lang", "ko");
    } catch (e) {}
    return "ko";
})();

/* 번역 조회. 키가 없으면 한국어로 대체한다. */
function t(key) {
    var dict = I18N[LANG] || I18N.ko;
    return dict[key] !== undefined ? dict[key] : I18N.ko[key];
}

/* 화면 전체에 현재 언어를 반영한다. */
function applyLang() {
    document.documentElement.lang = LANG;

    var titleKey = document.body.dataset.docTitleKey || "docTitle";
    document.title = t(titleKey);
    var descKey = document.body.dataset.docDescKey || "docDesc";
    var desc = document.querySelector('meta[name="description"]');
    if (desc && t(descKey)) desc.setAttribute("content", t(descKey));

    document.querySelectorAll("[data-i18n]").forEach(function (el) {
        var v = t(el.dataset.i18n);
        if (v !== undefined) el.textContent = v;
    });
    document.querySelectorAll("[data-i18n-html]").forEach(function (el) {
        var v = t(el.dataset.i18nHtml);
        if (v !== undefined) el.innerHTML = v;
    });
    document.querySelectorAll("[data-i18n-aria]").forEach(function (el) {
        var v = t(el.dataset.i18nAria);
        if (v !== undefined) el.setAttribute("aria-label", v);
    });
    document.querySelectorAll("[data-i18n-title]").forEach(function (el) {
        var v = t(el.dataset.i18nTitle);
        if (v !== undefined) el.setAttribute("title", v);
    });
    document.querySelectorAll("[data-i18n-alt]").forEach(function (el) {
        var v = t(el.dataset.i18nAlt);
        if (v !== undefined) el.setAttribute("alt", v);
    });

    /* 언어 버튼 활성 표시 */
    document.querySelectorAll(".lang-switch button").forEach(function (b) {
        var on = b.dataset.lang === LANG;
        b.classList.toggle("on", on);
        b.setAttribute("aria-pressed", on ? "true" : "false");
    });

    /* 다크/라이트 라벨도 언어를 따라간다 */
    if (typeof syncThemeLabel === "function") syncThemeLabel();

    /* 동적으로 그려지는 UI(히어로 점 라벨·최신 글 목록)도 다시 그린다 */
    if (window.langHooks) window.langHooks.forEach(function (fn) { try { fn(); } catch (e) {} });
}

function setLang(l) {
    if (l !== "ko" && l !== "en") return;
    LANG = l;
    try { localStorage.setItem("sgh-lang", l); } catch (e) {}
    applyLang();
}

document.addEventListener("DOMContentLoaded", applyLang);
