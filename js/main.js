/* =========================================================
 * 사이트 설정 — 여기 값만 바꾸면 전체 사이트에 반영됩니다.
 * =========================================================
 * BRAND_NAME        : 허브 브랜드명 (헤더·푸터·타이틀에 표시)
 * TALLY_FORM_ID     : Tally 폼 ID (예: "wABC12"). 비어 있으면 상담 버튼이 "준비 중" 안내로 동작.
 *                     ※ Tally 폼에는 아래 히든 필드를 미리 만들어 두세요:
 *                        - source  (허브에서는 "hub"로 전달)
 *                        - country (Phase 2: 국가 사이트에서 전달 예정)
 *                        - result  (Phase 2: 진단 결과 요약 전달 예정)
 *                        - link    (Phase 2: 진단 결과 URL 전달 예정)
 *                     ※ 개인정보 수집·이용 동의(필수 체크박스)도 Tally 폼 안에 구성:
 *                        "[필수] 개인정보 수집·이용 동의 — 항목: 이름, 연락처 / 목적: 유학 상담
 *                         안내 연락 / 보유: 상담 종료 또는 동의 철회 시까지(최대 1년)"
 *                        + privacy.html 링크
 * KAKAO_CHANNEL_URL : 카카오톡 채널 URL (예: "https://pf.kakao.com/_xxxxxx"). 비어 있으면 버튼 숨김.
 * CONTACT_EMAIL     : 문의용 이메일 (푸터·privacy.html에 표시)
 * GA4_ID            : GA4 측정 ID (예: "G-XXXXXXXXXX"). index.html 하단 GA4 주석 참고.
 * ========================================================= */
const CONFIG = {
    BRAND_NAME: "Study Guide Hub",          // {{BRAND_NAME}}
    // 자체 문의 접수 API (Cloudflare Worker). 관리자: {CONTACT_API}/admin
    CONTACT_API: "https://sgh-contact.studyguidehub.workers.dev",
    KAKAO_CHANNEL_URL: "",                  // {{KAKAO_CHANNEL_URL}}
    CONTACT_EMAIL: "",                      // {{CONTACT_EMAIL}}
    GA4_ID: ""                              // {{GA4_ID}}
};

/* ---------- 화면 모드(다크/라이트) 전환 ----------
 * 기본값은 다크. 사용자가 고른 값은 localStorage("sgh-theme")에 저장되고,
 * 각 페이지 <head>의 인라인 스크립트가 렌더링 전에 적용해 깜빡임을 막는다.
 */
function applyTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme);
    syncThemeLabel();
}

/* 스위치의 aria 상태와 라벨을 현재 테마·언어에 맞춘다.
 * 언어를 바꿀 때도 라벨을 다시 써야 하므로 i18n.js에서 이 함수를 호출한다. */
function syncThemeLabel() {
    const isLight = document.documentElement.getAttribute("data-theme") === "light";
    document.querySelectorAll(".theme-switch").forEach(btn => {
        btn.setAttribute("aria-checked", isLight ? "true" : "false");
    });
    document.querySelectorAll("[data-theme-label]").forEach(el => {
        el.textContent = isLight ? t("themeLight") : t("themeDark");
    });
}

function toggleTheme() {
    const next = document.documentElement.getAttribute("data-theme") === "light" ? "dark" : "light";
    applyTheme(next);
    try { localStorage.setItem("sgh-theme", next); } catch (e) {}
}

/* <head> 인라인 스크립트가 먼저 적용한 값에 스위치 상태(라벨·aria)를 맞춘다. */
document.addEventListener("DOMContentLoaded", () => {
    applyTheme(document.documentElement.getAttribute("data-theme") === "light" ? "light" : "dark");
});

/* ---------- 브랜드명 반영 ---------- */
document.addEventListener("DOMContentLoaded", () => {
    document.querySelectorAll("[data-brand]").forEach(el => {
        el.textContent = CONFIG.BRAND_NAME;
    });

    /* 카카오톡 채널 버튼 */
    const kakaoBtn = document.getElementById("kakao-btn");
    if (kakaoBtn) {
        if (CONFIG.KAKAO_CHANNEL_URL) {
            kakaoBtn.href = CONFIG.KAKAO_CHANNEL_URL;
        } else {
            kakaoBtn.classList.add("is-disabled");
            kakaoBtn.addEventListener("click", e => {
                e.preventDefault();
                showNotice(t("noticeKakaoPending"));
            });
        }
    }

    /* 문의 이메일 표시 */
    document.querySelectorAll("[data-contact-email]").forEach(el => {
        if (CONFIG.CONTACT_EMAIL) {
            el.textContent = CONFIG.CONTACT_EMAIL;
            el.href = "mailto:" + CONFIG.CONTACT_EMAIL;
        } else {
            el.closest("[data-contact-email-row]")?.classList.add("hidden");
        }
    });

    /* 연도 자동 표시 */
    document.querySelectorAll("[data-year]").forEach(el => {
        el.textContent = new Date().getFullYear();
    });
});

/* ---------- 자체 문의 모달 ----------
 * Tally 팝업을 대체한다(2026-08). 접수는 CONFIG.CONTACT_API 워커로 간다.
 * 마크업은 처음 열 때 한 번 만들고, 언어 전환은 langHooks로 다시 그린다. */
function consultModalHTML() {
    return `
        <div class="consult-backdrop" data-close></div>
        <div class="consult-card" role="dialog" aria-modal="true" aria-labelledby="consult-title">
            <button type="button" class="consult-x" data-close aria-label="닫기">&times;</button>
            <h3 id="consult-title">${t("formTitle")}</h3>
            <p class="consult-sub">${t("formSub")}</p>
            <form id="consult-form">
                <label>${t("formName")}<input type="text" name="name" required maxlength="60" autocomplete="name"></label>
                <label>${t("formContact")}<input type="text" name="contact" required maxlength="120" autocomplete="tel" placeholder="${t("formContactPh")}"></label>
                <label>${t("formCountry")}
                    <select name="country">
                        <option value="">${t("formCountryPh")}</option>
                        <option value="us">${t("usName")}</option>
                        <option value="uk">${t("ukName")}</option>
                        <option value="au">${t("auName")}</option>
                        <option value="ca">${t("caName")}</option>
                        <option value="esl">${t("formCountryEsl")}</option>
                        <option value="etc">${t("formCountryEtc")}</option>
                    </select>
                </label>
                <label>${t("formMsg")}<textarea name="message" rows="4" maxlength="2000"></textarea></label>
                <input type="text" name="website" class="consult-hp" tabindex="-1" autocomplete="off" aria-hidden="true">
                <label class="consult-agree"><input type="checkbox" name="agree" required>
                    <span>${t("formAgree")} <a href="privacy.html" target="_blank" rel="noopener">${t("formAgreeLink")}</a></span></label>
                <button type="submit" class="btn btn-primary consult-submit">${t("formSubmit")}</button>
                <p class="consult-err" id="consult-err"></p>
            </form>
            <div class="consult-done" hidden>
                <p class="consult-done-title">${t("formDoneTitle")}</p>
                <p class="consult-done-sub">${t("formDoneSub")}</p>
                <button type="button" class="btn btn-primary" data-close>${t("formClose")}</button>
            </div>
        </div>`;
}

function openConsultForm() {
    let modal = document.getElementById("consult-modal");
    if (!modal) {
        modal = document.createElement("div");
        modal.id = "consult-modal";
        modal.className = "consult-modal";
        document.body.appendChild(modal);
        modal.addEventListener("click", (e) => {
            if (e.target.closest("[data-close]")) closeConsultForm();
        });
        langHooks.push(() => {
            // 언어가 바뀌면 다음에 열 때 새로 그린다 (열려 있으면 그대로 둔다)
            if (!modal.classList.contains("show")) modal.innerHTML = "";
        });
    }
    if (!modal.innerHTML) modal.innerHTML = consultModalHTML();
    modal.querySelector("#consult-form").onsubmit = submitConsultForm;
    modal.classList.add("show");
    document.body.style.overflow = "hidden";
    setTimeout(() => modal.querySelector("input[name=name]").focus(), 50);
}

function closeConsultForm() {
    const modal = document.getElementById("consult-modal");
    if (!modal) return;
    modal.classList.remove("show");
    document.body.style.overflow = "";
    // 완료 화면이었다면 다음에 열 때 빈 폼부터
    if (!modal.querySelector(".consult-done").hidden) modal.innerHTML = "";
}

async function submitConsultForm(e) {
    e.preventDefault();
    const form = e.target;
    const btn = form.querySelector(".consult-submit");
    const err = form.querySelector("#consult-err");
    err.textContent = "";
    btn.disabled = true;
    btn.textContent = t("formSending");
    try {
        const r = await fetch(CONFIG.CONTACT_API + "/api/inquiries", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                name: form.name.value,
                contact: form.contact.value,
                country: form.country.value,
                message: form.message.value,
                website: form.website.value,   // 허니팟
                source: "hub"
            })
        });
        if (!r.ok) throw new Error();
        form.closest(".consult-card").querySelector(".consult-done").hidden = false;
        form.hidden = true;
    } catch (_) {
        err.textContent = t("formError");
        btn.disabled = false;
        btn.textContent = t("formSubmit");
    }
}

/* 언어 전환 때 다시 그려야 하는 동적 UI의 콜백 목록.
 * i18n.js의 applyLang()이 끝에서 순회한다. (var — window 전역이어야 한다) */
var langHooks = [];

/* ---------- 히어로 슬라이드 ----------
 * 문구(.hero-slide)와 사진(.hero-photo)을 같은 인덱스로 전환한다.
 * 모션 축소 설정에서는 자동 재생을 끄고 점(dot) 클릭 전환만 남긴다. */
const REDUCE_MOTION = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;

document.addEventListener("DOMContentLoaded", () => {
    const slides = document.querySelectorAll(".hero-slide");
    const photos = document.querySelectorAll(".hero-photo");
    const dotsWrap = document.getElementById("hero-dots");
    if (!slides.length || !dotsWrap) return;

    let cur = 0;
    let timer = null;

    slides.forEach((_, i) => {
        const b = document.createElement("button");
        b.type = "button";
        if (i === 0) b.classList.add("on");
        b.addEventListener("click", () => { goTo(i); restart(); });
        dotsWrap.appendChild(b);
    });
    const dots = dotsWrap.querySelectorAll("button");
    syncDotLabels();

    function goTo(i) {
        cur = i;
        slides.forEach((s, k) => s.classList.toggle("is-on", k === i));
        photos.forEach((p, k) => p.classList.toggle("is-on", k === i));
        dots.forEach((d, k) => d.classList.toggle("on", k === i));
    }
    function next() { goTo((cur + 1) % slides.length); }
    function restart() {
        if (REDUCE_MOTION) return;
        clearInterval(timer);
        timer = setInterval(next, 6500);
    }

    /* 점 라벨은 언어를 따라간다 — i18n.js가 언어 전환 때 onLangChange()를 부른다 */
    function syncDotLabels() {
        dots.forEach((d, i) => d.setAttribute("aria-label", t("heroDot")(i + 1)));
    }
    langHooks.push(syncDotLabels);

    /* 히어로 위에 마우스가 있거나 탭이 백그라운드면 잠시 멈춘다 */
    const hero = document.querySelector(".hero--split");
    if (hero) {
        hero.addEventListener("mouseenter", () => clearInterval(timer));
        hero.addEventListener("mouseleave", restart);
    }
    document.addEventListener("visibilitychange", () => {
        if (document.hidden) clearInterval(timer); else restart();
    });
    restart();
});

/* ---------- 스크롤 리빌 ----------
 * JS가 있을 때만 숨겼다가(html.js-reveal) 화면에 들어오면 .in을 붙인다. */
document.documentElement.classList.add("js-reveal");

const revealIO = ("IntersectionObserver" in window)
    ? new IntersectionObserver(entries => {
        entries.forEach(e => {
            if (e.isIntersecting) { e.target.classList.add("in"); revealIO.unobserve(e.target); }
        });
    }, { threshold: 0.15, rootMargin: "0px 0px -5% 0px" })
    : null;

function observeReveals(root) {
    const els = (root || document).querySelectorAll(".reveal:not(.in)");
    if (!revealIO) { els.forEach(el => el.classList.add("in")); return; }
    els.forEach((el, i) => {
        el.style.setProperty("--rd", (Math.min(i, 5) * 0.07) + "s");
        revealIO.observe(el);
    });
}
document.addEventListener("DOMContentLoaded", () => observeReveals(document));

/* 안전장치: 옵저버가 어떤 이유로든 안 돌면(구형 브라우저·특수 환경)
 * 내용이 숨은 채 남지 않도록 2초 뒤 전부 표시한다. */
window.addEventListener("load", () => {
    setTimeout(() => {
        if (!document.querySelector(".reveal.in")) {
            document.querySelectorAll(".reveal").forEach(el => el.classList.add("in"));
        }
    }, 2000);
});

/* ---------- 최신 유학 정보 ----------
 * 빌드가 만드는 4개국 게시판 색인에서 나라별 최근 2편을 모아 보여준다.
 * 색인 순서가 곧 발행 순서라 뒤에서부터 집는다. 하나도 못 받으면 섹션째 숨긴다. */
const LATEST_CCS = ["ca", "us", "uk", "au"];
const LATEST_BADGE = { ca: "CA", us: "US", uk: "UK", au: "AU" };
let latestItems = [];

document.addEventListener("DOMContentLoaded", () => {
    const section = document.getElementById("latest");
    const list = document.getElementById("latest-list");
    if (!section || !list) return;

    Promise.all(LATEST_CCS.map(cc =>
        fetch("data/articles-" + cc + "-index.json")
            .then(r => r.ok ? r.json() : null)
            .then(idx => {
                if (!idx) return [];
                return Object.entries(idx).slice(-2).reverse()
                    .map(([slug, a]) => ({ cc, slug, ko: a.ko, en: a.en, min: a.min }));
            })
            .catch(() => [])
    )).then(groups => {
        /* 나라별 최근 글을 번갈아 배치한다 (ca1, us1, uk1, au1, ca2, ...) */
        latestItems = [];
        for (let i = 0; i < 2; i++) groups.forEach(g => { if (g[i]) latestItems.push(g[i]); });
        if (!latestItems.length) return;
        renderLatest();
        section.hidden = false;
        observeReveals(section);
    });

    function renderLatest() {
        list.innerHTML = latestItems.map(item => `
            <a class="latest-item reveal" href="guide/${item.cc}-info-${item.slug}.html">
                <span class="country-badge badge--${item.cc}">${LATEST_BADGE[item.cc]}</span>
                <span class="latest-title">${LANG === "en" && item.en ? item.en : item.ko}</span>
                <span class="latest-min">${t("latestMin")(item.min)}</span>
            </a>`).join("");
    }
    langHooks.push(() => { if (latestItems.length) { renderLatest(); list.querySelectorAll(".reveal").forEach(el => el.classList.add("in")); } });
});

/* ---------- 간단 알림 토스트 ---------- */
let noticeTimer = null;
function showNotice(msg) {
    let el = document.getElementById("site-notice");
    if (!el) {
        el = document.createElement("div");
        el.id = "site-notice";
        el.className = "site-notice";
        el.setAttribute("role", "status");
        document.body.appendChild(el);
    }
    el.textContent = msg;
    el.classList.add("show");
    clearTimeout(noticeTimer);
    noticeTimer = setTimeout(() => el.classList.remove("show"), 3200);
}
