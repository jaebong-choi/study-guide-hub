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
        docDesc: "호주·영국·캐나다 국가별 3분 AI 진단으로 내 조건에 맞는 진학 경로를 확인하세요. 어학연수는 6개국 어학원 지도로. 특정 유학원과 무관한 무료 정보 가이드.",

        headerCta: "상담 문의",
        themeDark: "다크",
        themeLight: "라이트",
        themeAria: "화면 모드 전환",
        themeTitle: "밝게 / 어둡게",
        langAria: "언어 선택",

        heroEyebrow: "Free Study Abroad Guide · AU / UK / CA / ESL",
        heroTitle: "유학, 진단에서<br>시작하세요",
        heroSub: "국가별 3분 진단으로 내 조건에 맞는 진학 경로를 확인하고,<br class=\"br-desktop\">결과 그대로 상담까지 이어가세요.",

        sectionCountries: "국가별 진단 시작하기",
        auName: "호주",
        auDesc: "학부(디플로마·파운데이션)부터 석사(GE)까지 3분 진단. 2026 대학 공식 학비 데이터 기반.",
        ukName: "영국",
        ukDesc: "학부(파운데이션·IYO)부터 석사(프리마스터)까지 진단. QS 2027 랭킹 데이터 기반.",
        caName: "캐나다",
        caDesc: "공립 컬리지 PGWP(졸업 후 취업허가)·대학 편입 진단. 2026 IRCC 정책 기준.",
        cardGo: "진단 시작",
        auAlt: "세계지도 위 호주 국기",
        ukAlt: "세계지도 위 영국 국기",
        caAlt: "세계지도 위 캐나다 국기",

        eslTitle: "🗺️ 대학 진학이 아니라 어학연수를 알아보고 있다면",
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
        priv4Body: "수집한 개인정보를 제3자에게 제공하거나 외부에 처리를 위탁하지 않습니다. (상담 신청 폼은 폼 서비스(Tally)를 통해 접수되며, 접수된 정보는 위 목적으로만 사용합니다.)",
        priv5Title: "5. 동의 철회 및 문의",
        priv5Body: "개인정보 열람·수정·삭제 및 동의 철회는 아래 이메일로 요청하실 수 있습니다.",
        privContact: "문의처:",
        privBack: "← 홈으로 돌아가기"
    },

    en: {
        langName: "English",

        docTitle: "Find your route to studying abroad | Study Guide Hub",
        docDesc: "Three-minute assessments for Australia, the UK and Canada, plus a map of language schools across six countries. Free guidance, independent of any agency.",

        headerCta: "Get in touch",
        themeDark: "Dark",
        themeLight: "Light",
        themeAria: "Switch colour mode",
        themeTitle: "Light / dark",
        langAria: "Select language",

        heroEyebrow: "Free Study Abroad Guide · AU / UK / CA / ESL",
        heroTitle: "Find your route to<br>studying abroad",
        /* 영어는 강제 줄바꿈 없이 흐르게 둔다. <br>를 넣으면 문장 중간에서 끊긴다.
           줄 길이는 CSS의 text-wrap: pretty가 고르게 맞춘다. */
        heroSub: "Take a three-minute assessment for your chosen country, see which entry pathways match your grades and goals, then take the result to an advisor.",

        sectionCountries: "Choose a destination",
        auName: "Australia",
        auDesc: "Undergraduate routes through diploma and foundation programmes, plus master's entry including graduate entry. Based on official 2026 university tuition data.",
        ukName: "United Kingdom",
        ukDesc: "Undergraduate routes through foundation and international year one, plus pre-master's entry. Based on QS 2027 ranking data.",
        caName: "Canada",
        caDesc: "Public college routes to a post-graduation work permit (PGWP), and transfer to a university degree. Based on 2026 IRCC policy.",
        cardGo: "Start assessment",
        auAlt: "Australian flag pinned to a world map",
        ukAlt: "British flag pinned to a world map",
        caAlt: "Canadian flag pinned to a world map",

        eslTitle: "🗺️ Looking for a language course rather than a degree?",
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
        priv4Body: "We do not share your information with third parties or outsource its processing. (Enquiries are received through the form service Tally, and the information submitted is used only for the purpose above.)",
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
}

function setLang(l) {
    if (l !== "ko" && l !== "en") return;
    LANG = l;
    try { localStorage.setItem("sgh-lang", l); } catch (e) {}
    applyLang();
}

document.addEventListener("DOMContentLoaded", applyLang);
