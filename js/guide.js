/* =========================================================
 * 가이드 페이지 언어 전환
 * uni/ 상세 페이지와 같은 방식: 마크업의 data-en 속성을 통째로 스왑한다.
 * 저장 키 sgh-lang 은 허브·국가 사이트와 공유한다.
 * ========================================================= */
var LANG = 'ko';
try { if (localStorage.getItem('sgh-lang') === 'en') LANG = 'en'; } catch (e) {}

function applyLang() {
    document.documentElement.lang = LANG;
    var t = document.body.getAttribute(LANG === 'en' ? 'data-title-en' : 'data-title-ko');
    if (t) document.title = t;

    document.querySelectorAll('[data-en]').forEach(function (el) {
        if (!el.dataset.ko) el.dataset.ko = el.innerHTML;
        el.innerHTML = LANG === 'en' ? el.dataset.en : el.dataset.ko;
    });
    [['data-en-title', 'title'], ['data-en-aria', 'aria-label'], ['data-en-alt', 'alt']].forEach(function (pair) {
        document.querySelectorAll('[' + pair[0] + ']').forEach(function (el) {
            var koAttr = pair[0] + '-ko';
            if (!el.hasAttribute(koAttr)) el.setAttribute(koAttr, el.getAttribute(pair[1]) || '');
            el.setAttribute(pair[1], el.getAttribute(LANG === 'en' ? pair[0] : koAttr));
        });
    });
    document.querySelectorAll('.lang-switch button').forEach(function (b) {
        b.classList.toggle('on', b.getAttribute('data-lang') === LANG);
    });
}

function setLang(l) {
    LANG = l;
    try { localStorage.setItem('sgh-lang', l); } catch (e) {}
    applyLang();
}

applyLang();
