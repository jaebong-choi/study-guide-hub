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
    TALLY_FORM_ID: "0Qz7E6",                // https://tally.so/r/0Qz7E6
    KAKAO_CHANNEL_URL: "",                  // {{KAKAO_CHANNEL_URL}}
    CONTACT_EMAIL: "",                      // {{CONTACT_EMAIL}}
    GA4_ID: ""                              // {{GA4_ID}}
};

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
                showNotice("카카오톡 채널은 준비 중입니다. 아래 무료 상담 신청을 이용해 주세요.");
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

/* ---------- Tally 팝업 ---------- */
function openConsultForm() {
    if (!CONFIG.TALLY_FORM_ID) {
        showNotice("상담 신청 폼은 준비 중입니다. 잠시 후 다시 시도해 주세요.");
        return;
    }
    if (window.Tally) {
        // 허브에서 열 때는 source=hub 전달.
        // 국가 사이트(Phase 2)에서는 country / result / link를 함께 전달할 예정.
        window.Tally.openPopup(CONFIG.TALLY_FORM_ID, {
            layout: "modal",
            width: 420,
            hiddenFields: { source: "hub" }
        });
    } else {
        // 위젯 스크립트가 아직 로드되지 않았을 때 폴백: 새 탭으로 폼 열기
        window.open(
            "https://tally.so/r/" + CONFIG.TALLY_FORM_ID + "?source=hub",
            "_blank",
            "noopener"
        );
    }
}

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
