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

    // ⚠ 반드시 마지막에. 위에서 innerHTML을 통째로 갈아 끼우기 때문에
    //   먼저 채워 두면 언어를 바꿀 때마다 원화가 지워진다.
    renderKrw();
}

function setLang(l) {
    LANG = l;
    try { localStorage.setItem('sgh-lang', l); } catch (e) {}
    applyLang();
}

/* =========================================================
 * 원화 환산 — 조회 시점 환율로 금액 옆에 병기한다.
 * uni/ 상세 페이지와 같은 방식이고, 통화는 <html data-country>에서 고른다.
 * 환율을 못 받으면 조용히 비워 둔다(금액만 보인다).
 * ========================================================= */
var FX_CCY = { uk: 'GBP', au: 'AUD', us: 'USD', ca: 'CAD' };
var FX_RATE = null;

function renderKrw() {
    var els = document.querySelectorAll('.krw');
    if (!els.length || !FX_RATE) return;
    var en = LANG === 'en';

    function fmt(v) {
        var man = Math.round(v * FX_RATE / 10000);
        if (en) return '₩' + (man * 10000).toLocaleString('en-US');
        if (man >= 10000) {
            var eok = Math.floor(man / 10000), rest = man % 10000;
            return eok + '억' + (rest ? ' ' + rest.toLocaleString('ko-KR') + '만' : '') + ' 원';
        }
        return man.toLocaleString('ko-KR') + '만 원';
    }

    els.forEach(function (el) {
        var min = parseFloat(el.getAttribute('data-min'));
        var max = parseFloat(el.getAttribute('data-max'));
        if (isNaN(min) && isNaN(max)) return;
        if (isNaN(min)) min = max;
        if (isNaN(max)) max = min;
        var range = min === max
            ? fmt(min)
            : (en ? fmt(min) + ' ~ ' + fmt(max) : fmt(min).replace(' 원', '') + '~' + fmt(max));
        el.textContent = (en ? 'approx. ' : '약 ') + range;
    });

    // 문구는 각 국가 진단 결과 페이지(au-study-guide 등)와 같은 것을 쓴다
    var today = new Date();
    document.querySelectorAll('.fx-date').forEach(function (el) {
        el.textContent = en
            ? 'KRW amounts converted at the rate as of ' + today.toLocaleDateString('en-GB', { year: 'numeric', month: 'short', day: 'numeric' })
            : '원화는 ' + today.getFullYear() + '. ' + (today.getMonth() + 1) + '. ' + today.getDate() + '. 환율로 환산한 참고 값입니다.';
    });
}

(function () {
    if (!document.querySelector('.krw')) return;
    var ccy = FX_CCY[document.documentElement.getAttribute('data-country')];
    if (!ccy) return;
    fetch('https://open.er-api.com/v6/latest/' + ccy)
        .then(function (r) { return r.json(); })
        .then(function (d) { FX_RATE = d && d.rates && d.rates.KRW; renderKrw(); })
        .catch(function () {});
})();

applyLang();

/* =========================================================
 * 유학 정보 게시판 — 분류·대상 필터 + 페이지 넘김
 * 마크업은 build-uni.ps1이 만든다. 게시판이 없는 페이지에서는 아무 일도 하지 않는다.
 * 필터는 행의 data-cat / data-track만 보므로 언어 전환과 서로 간섭하지 않는다.
 * ========================================================= */
(function () {
    var board = document.querySelector('.info-board');
    if (!board) return;
    var rows = [].slice.call(board.querySelectorAll('.board-row'));
    if (!rows.length) return;

    var pager = board.querySelector('.board-pager');
    var empty = board.querySelector('.board-empty');
    var trackSel = board.querySelector('.board-track');
    var PER_PAGE = 10;
    var cat = '';
    var page = 1;

    function matched() {
        var track = trackSel ? trackSel.value : '';
        return rows.filter(function (r) {
            if (cat && r.getAttribute('data-cat') !== cat) return false;
            if (track && (' ' + r.getAttribute('data-track') + ' ').indexOf(' ' + track + ' ') < 0) return false;
            return true;
        });
    }

    function render() {
        var list = matched();
        var pages = Math.max(1, Math.ceil(list.length / PER_PAGE));
        if (page > pages) page = pages;
        var start = (page - 1) * PER_PAGE;

        rows.forEach(function (r) { r.hidden = true; });
        list.slice(start, start + PER_PAGE).forEach(function (r) { r.hidden = false; });
        if (empty) empty.hidden = list.length > 0;

        if (!pager) return;
        pager.innerHTML = '';
        if (list.length <= PER_PAGE) return;
        var mk = function (label, target, opts) {
            var b = document.createElement('button');
            b.type = 'button';
            b.textContent = label;
            if (opts && opts.on) { b.className = 'on'; b.setAttribute('aria-current', 'page'); }
            if (opts && opts.off) b.disabled = true;
            b.addEventListener('click', function () { page = target; render(); board.scrollIntoView({ block: 'start' }); });
            pager.appendChild(b);
        };
        mk('‹', page - 1, { off: page === 1 });
        for (var p = 1; p <= pages; p++) mk(String(p), p, { on: p === page });
        mk('›', page + 1, { off: page === pages });
    }

    board.querySelectorAll('.board-cat').forEach(function (b) {
        b.addEventListener('click', function () {
            cat = b.getAttribute('data-c') || '';
            page = 1;
            board.querySelectorAll('.board-cat').forEach(function (o) {
                var on = o === b;
                o.classList.toggle('on', on);
                o.setAttribute('aria-pressed', on ? 'true' : 'false');
            });
            render();
        });
    });
    if (trackSel) trackSel.addEventListener('change', function () { page = 1; render(); });

    render();
})();
