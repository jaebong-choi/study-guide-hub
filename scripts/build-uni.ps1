# 대학 상세 페이지 정적 생성 스크립트
# 사용법:  powershell -ExecutionPolicy Bypass -File scripts\build-uni.ps1
# data\universities-*.json 을 읽어 uni\{id}.html 을 생성한다.
# 실행 전 scripts\validate-uni.ps1 로 스키마 검증을 통과해야 한다.

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$outDir   = Join-Path $repoRoot 'uni'
$SITE     = 'https://jaebong-choi.github.io/study-guide-hub/'

# ---------- 표시용 매핑 ----------
$TYPE_LABEL = @{
    'university' = '종합대학'
    'college'    = '컬리지'
    'specialty'  = '특수대학'
}
$PATHWAY_LABEL = @{
    'foundation' = '파운데이션'
    'iyo'        = 'IYO (국제 1학년)'
    'direct'     = '직접 입학'
    'pre-master' = '프리마스터'
    'pathway'    = '패스웨이'
    'transfer'   = '편입'
    'college'    = '컬리지'
}
$ENGLISH_LABEL = @{
    'ielts'     = 'IELTS'
    'toefl'     = 'TOEFL iBT'
    'pte'       = 'PTE Academic'
    'duolingo'  = '듀오링고'
    'toeic'     = 'TOEIC'
    'cambridge' = '케임브리지'
    'internal'  = '자체 시험'
}
$CURRENCY_SYMBOL = @{
    'GBP' = [char]0x00A3; 'USD' = '$'; 'AUD' = 'A$'; 'CAD' = 'C$'; 'EUR' = [char]0x20AC; 'NZD' = 'NZ$'
}
# 국가별 3분 진단 사이트
$DIAG_URL = @{
    'UK' = 'https://jaebong-choi.github.io/uk-study-guide/'
    'AU' = 'https://jaebong-choi.github.io/studyabroad-au-ai/'
    'CA' = 'https://jaebong-choi.github.io/ca-study-guide/'
    'US' = 'https://jaebong-choi.github.io/us-study-guide/'
}

function Esc([string]$s) {
    if ($null -eq $s) { return '' }
    return $s.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;')
}

function New-PathwayCard($pw, [string]$diagUrl) {
    $pwLabel = if ($PATHWAY_LABEL.ContainsKey($pw.type)) { $PATHWAY_LABEL[$pw.type] } else { $pw.type }
    $provider = if ($pw.provider) { '<span class="pw-provider">' + (Esc $pw.provider) + '</span>' } else { '' }
    $facts = ''
    if ($null -ne $pw.ielts_min) { $facts += '<span>IELTS <b>' + $pw.ielts_min + '</b></span>' }
    if ($pw.duration)  { $facts += '<span>기간 <b>' + (Esc $pw.duration) + '</b></span>' }
    if ($pw.cost_note) { $facts += '<span>비용 <b>' + (Esc $pw.cost_note) + '</b></span>' }
    $noteHtml = if ($pw.note) { '<p class="pw-note">' + (Esc $pw.note) + '</p>' } else { '' }
    return @"
                <div class="pathway-card">
                    <div class="pw-head"><span class="pw-type">$(Esc $pwLabel)</span>$provider</div>
                    <div class="pw-facts">$facts</div>
                    $noteHtml
                    <a class="pw-link" href="$diagUrl">이 경로로 진단 &rarr;</a>
                </div>
"@
}

function Fmt-Tuition($min, $max, [string]$symbol) {
    if ($null -eq $min -and $null -eq $max) { return $null }
    if ($null -ne $min -and $null -ne $max) {
        if ($min -eq $max) { return ('{0}{1:N0}' -f $symbol, $min) }
        return ('{0}{1:N0} ~ {0}{2:N0}' -f $symbol, $min, $max)
    }
    $v = if ($null -ne $min) { $min } else { $max }
    return ('{0}{1:N0}' -f $symbol, $v)
}

# ---------- HTML 템플릿 ----------
$TEMPLATE = @'
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{NAME_KO}} ({{NAME_EN}}) | Study Guide Hub</title>
    <meta name="description" content="{{NAME_KO}} 학비·입학 요건·진학 경로 정리. {{COUNTRY}} 3분 진단으로 내 조건에 맞는 경로를 확인하세요.">
    <link rel="canonical" href="{{SITE}}uni/{{ID}}.html">
    <meta property="og:type" content="article">
    <meta property="og:site_name" content="Study Guide Hub">
    <meta property="og:title" content="{{NAME_KO}} ({{NAME_EN}}) | Study Guide Hub">
    <meta property="og:description" content="{{NAME_KO}} 학비·입학 요건·진학 경로 정리. 공식 요강 기준 무료 정보 가이드.">
    <meta property="og:url" content="{{SITE}}uni/{{ID}}.html">
    <meta property="og:image" content="{{OG_IMAGE}}">
    <meta property="og:image:width" content="1200">
    <meta property="og:image:height" content="630">
    <meta property="og:locale" content="ko_KR">
    <meta name="twitter:card" content="summary_large_image">

    <!-- 화면 모드를 렌더링 전에 적용 (허브와 같은 키 sgh-theme 공유) -->
    <script>
        (function () {
            var t = 'light';
            try {
                var saved = localStorage.getItem('sgh-theme');
                if (saved === 'light' || saved === 'dark') t = saved;
                else localStorage.setItem('sgh-theme', t);
            } catch (e) {}
            document.documentElement.setAttribute('data-theme', t);
        })();
    </script>

    <link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css">
    <style>
        :root {
            --bg: #0b0b0f; --surface: #1d1d1f; --text: #f5f5f7; --body-text: #c7c7cc;
            --mute: #86868b; --line: rgba(255,255,255,0.14); --card-bg: rgba(255,255,255,0.05);
            --accent: #FFDE59; --accent-text: #1d1d1f; --link: #2997ff;
            --header-bg: rgba(0,0,0,0.8);
        }
        :root[data-theme="light"] {
            --bg: #ffffff; --surface: #f5f5f7; --text: #1d1d1f; --body-text: #4a4a4f;
            --mute: #6e6e73; --line: rgba(0,0,0,0.12); --card-bg: #ffffff;
            --accent: #A87E00; --accent-text: #ffffff; --link: #0066cc;
            --header-bg: rgba(255,255,255,0.82);
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Pretendard Variable', Pretendard, -apple-system, BlinkMacSystemFont, system-ui, sans-serif;
            background: var(--bg); color: var(--text); line-height: 1.6;
            -webkit-font-smoothing: antialiased;
        }
        .container { max-width: 880px; margin: 0 auto; padding: 0 20px; }
        a { color: var(--link); text-decoration: none; }

        .site-header {
            position: sticky; top: 0; z-index: 10; backdrop-filter: blur(14px);
            background: var(--header-bg); border-bottom: 1px solid var(--line);
        }
        .site-header .container { display: flex; align-items: center; justify-content: space-between; height: 52px; }
        .brand { font-weight: 700; color: var(--text); font-size: 15px; }
        .header-actions { display: flex; align-items: center; gap: 14px; }
        .header-cta { font-size: 13px; font-weight: 600; }
        .theme-btn {
            width: 34px; height: 34px; border-radius: 50%; cursor: pointer;
            border: 1px solid var(--line); background: none; font-size: 15px; line-height: 1;
        }
        .theme-btn::before { content: '\1F319'; }
        :root[data-theme="dark"] .theme-btn::before { content: '\2600\FE0F'; }

        .uni-hero { padding: 48px 0 36px; }
        .crumb { font-size: 13px; color: var(--mute); margin-bottom: 18px; }
        .meta-badges { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 14px; }
        .meta-badge {
            font-size: 12px; font-weight: 600; color: var(--body-text);
            border: 1px solid var(--line); border-radius: 999px; padding: 4px 12px;
        }
        .hero-banner { margin-bottom: 22px; border-radius: 16px; overflow: hidden; }
        .hero-banner img { width: 100%; height: 240px; object-fit: cover; display: block; }
        .hero-top { display: flex; justify-content: space-between; align-items: flex-start; gap: 20px; }
        /* 로고는 모든 학교 동일한 160x88 박스(contain). 투명 PNG/SVG 전제.
           다크 모드에서는 흰색 단색으로 반전시켜 배경에 녹인다. */
        .uni-logo { flex-shrink: 0; width: 160px; height: 88px; object-fit: contain; }
        :root[data-theme="dark"] .uni-logo { filter: brightness(0) invert(1); opacity: .92; }
        @media (max-width: 720px) { .uni-logo { width: 110px; height: 64px; } }
        .uni-hero h1 { font-size: clamp(28px, 5vw, 40px); letter-spacing: -0.02em; }
        .en-name { font-size: 17px; color: var(--mute); margin: 4px 0 18px; }
        .rank-badges { display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 26px; }
        .rank-badge--subject {
            background: var(--accent); color: var(--accent-text);
            font-size: 14px; font-weight: 700; border-radius: 10px; padding: 8px 14px;
        }
        .rank-badge--overall {
            font-size: 13px; font-weight: 600; color: var(--mute);
            border: 1px solid var(--line); border-radius: 10px; padding: 8px 14px; align-self: center;
        }
        .hero-actions { display: flex; flex-wrap: wrap; gap: 10px; }
        .map-wrap { margin-top: 28px; height: 300px; border-radius: 16px; overflow: hidden; border: 1px solid var(--line); }
        .map-wrap iframe { width: 100%; height: 100%; border: 0; display: block; }
        @media (max-width: 720px) { .map-wrap { height: 220px; } }
        .btn {
            display: inline-flex; align-items: center; min-height: 44px;
            font-size: 15px; font-weight: 700;
            border-radius: 999px; padding: 0 24px; transition: opacity .15s;
        }
        .btn:hover { opacity: .85; }
        .btn-primary { background: var(--text); color: var(--bg); }
        .btn-secondary { border: 1px solid var(--line); color: var(--text); }

        /* 구분선 대신 배경색 교차로 섹션을 나눈다 (애플 스타일 흰색-연회색 교차) */
        section { padding: 44px 0; }
        main > section:nth-of-type(even) { background: var(--surface); }
        h2 { font-size: 20px; margin-bottom: 18px; letter-spacing: -0.01em; }

        .stat-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; }
        @media (max-width: 720px) { .stat-grid { grid-template-columns: repeat(2, 1fr); } }
        .stat-card {
            background: var(--card-bg); border: 1px solid var(--line);
            border-radius: 14px; padding: 16px;
        }
        .stat-label { font-size: 12px; color: var(--mute); margin-bottom: 6px; }
        .stat-value { font-size: 17px; font-weight: 700; line-height: 1.3; }
        .stat-sub { font-size: 12px; color: var(--body-text); margin-top: 4px; }
        .stat-card .krw { white-space: nowrap; }
        .fx-date { font-size: 12px; color: var(--mute); margin-top: 10px; text-align: right; }

        .pathway-card {
            background: var(--card-bg); border: 1px solid var(--line);
            border-radius: 14px; padding: 18px; margin-bottom: 12px;
        }
        .pw-head { display: flex; align-items: baseline; gap: 10px; margin-bottom: 10px; flex-wrap: wrap; }
        .pw-type { font-size: 16px; font-weight: 700; }
        .pw-provider { font-size: 13px; color: var(--mute); }
        .pw-facts { display: flex; flex-wrap: wrap; gap: 8px 20px; font-size: 14px; color: var(--body-text); margin-bottom: 12px; }
        .pw-facts b { color: var(--text); }
        .pw-note { font-size: 13px; color: var(--mute); margin-bottom: 12px; }
        .pw-link { font-size: 14px; font-weight: 700; }
        .pw-group { font-size: 15px; color: var(--mute); margin: 22px 0 10px; }
        .pw-group:first-child { margin-top: 0; }

        .video-wrap { aspect-ratio: 16 / 9; border-radius: 14px; overflow: hidden; background: var(--surface); }
        .video-wrap iframe { width: 100%; height: 100%; border: 0; display: block; }

        .major-tags { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 16px; }
        .major-tag {
            font-size: 13px; font-weight: 600; color: var(--body-text);
            background: var(--card-bg); border: 1px solid var(--line); border-radius: 999px; padding: 6px 14px;
        }
        .subject-ranks li { list-style: none; font-size: 14px; color: var(--body-text); margin-bottom: 6px; }
        .subject-ranks .rank-chip {
            display: inline-block; background: var(--accent); color: var(--accent-text);
            font-size: 12px; font-weight: 700; border-radius: 6px; padding: 2px 8px; margin-left: 8px;
        }

        .fact-table { width: 100%; border-collapse: collapse; font-size: 14px; }
        .fact-table th, .fact-table td { text-align: left; padding: 12px 10px; border-bottom: 1px solid var(--line); }
        .fact-table th { color: var(--mute); font-weight: 600; width: 38%; }
        .fact-table td { color: var(--text); font-weight: 600; }
        .fact-table .krw { display: block; font-size: 12px; color: var(--mute); font-weight: 500; margin-top: 2px; }
        .disclaimer { font-size: 12px; color: var(--mute); margin-top: 12px; line-height: 1.8; }

        .editor-note {
            background: var(--card-bg); border: 1px solid var(--line); border-radius: 14px; padding: 18px;
            font-size: 14px; color: var(--body-text);
        }
        .related-links { display: flex; flex-wrap: wrap; gap: 10px; }
        .related-links a {
            border: 1px solid var(--line); border-radius: 999px;
            padding: 8px 16px; font-size: 14px; font-weight: 600; color: var(--text);
        }

        .cta-section { text-align: center; border-bottom: none; padding: 48px 0; }
        .cta-section h2 { margin-bottom: 8px; }
        .cta-lead { font-size: 14px; color: var(--body-text); margin-bottom: 20px; }
        .cta-buttons { display: flex; justify-content: center; gap: 10px; flex-wrap: wrap; }

        .site-footer { background: var(--surface); padding: 28px 0 40px; }
        .site-footer p { font-size: 12px; color: var(--mute); margin-bottom: 6px; }
    </style>
</head>
<body>

    <header class="site-header">
        <div class="container">
            <a href="../index.html" class="brand">Study Guide Hub</a>
            <div class="header-actions">
                <button type="button" class="theme-btn" aria-label="화면 모드 전환" title="밝게 / 어둡게" onclick="var r=document.documentElement,t=r.getAttribute('data-theme')==='dark'?'light':'dark';r.setAttribute('data-theme',t);try{localStorage.setItem('sgh-theme',t)}catch(e){}"></button>
                <a href="../index.html#contact" class="header-cta">상담 문의</a>
            </div>
        </div>
    </header>

    <main>
        <!-- ① 헤더 -->
        <section class="uni-hero">
            <div class="container">
                <p class="crumb"><a href="../index.html">홈</a> › {{COUNTRY}} › {{NAME_KO}}</p>
                {{HERO_BANNER}}
                <div class="hero-top">
                    <div>
                        <div class="meta-badges">
                            <span class="meta-badge">{{CITY}}</span>
                            <span class="meta-badge">{{TYPE_LABEL}}</span>
                            <span class="meta-badge">{{COUNTRY}}</span>
                        </div>
                        <h1>{{NAME_KO}}</h1>
                        <p class="en-name">{{NAME_EN}}</p>
                    </div>
                    {{UNI_LOGO}}
                </div>
                <div class="rank-badges">{{RANK_BADGES}}</div>
                <div class="hero-actions">
                    <a class="btn btn-primary" href="{{DIAG_URL}}">3분 진단 시작</a>
                    <a class="btn btn-secondary" href="{{OFFICIAL_URL}}" target="_blank" rel="noopener">공식 홈페이지</a>
                </div>
                <div class="map-wrap">
                    <iframe src="https://www.google.com/maps?q={{MAP_QUERY}}&amp;output=embed&amp;hl=ko" title="{{NAME_KO}} 위치 지도" loading="lazy" referrerpolicy="no-referrer-when-downgrade" allowfullscreen></iframe>
                </div>
            </div>
        </section>

        <!-- ② 핵심 수치 -->
        <section>
            <div class="container">
                <div class="stat-grid">
                    <div class="stat-card">
                        <p class="stat-label">연간 학비 (학부)</p>
                        <p class="stat-value">{{TUITION_UG}}</p>
                        <p class="stat-sub krw" data-min="{{UG_MIN}}" data-max="{{UG_MAX}}"></p>
                    </div>
                    <div class="stat-card">
                        <p class="stat-label">IELTS 기준</p>
                        <p class="stat-value">{{IELTS_MIN}}</p>
                        <p class="stat-sub">{{ACCEPTED_SUB}}</p>
                    </div>
                    <div class="stat-card">
                        <p class="stat-label">입학 시기</p>
                        <p class="stat-value">{{INTAKES}}</p>
                    </div>
                    <div class="stat-card">
                        <p class="stat-label">진학 경로</p>
                        <p class="stat-value">{{PATHWAY_COUNT}}개</p>
                    </div>
                </div>
                <p class="fx-date"></p>
            </div>
        </section>

        <!-- ③ 진학 경로 -->
        <section>
            <div class="container">
                <h2>진학 경로</h2>
                {{PATHWAY_CARDS}}
            </div>
        </section>

        <!-- ④ 전공 -->
        <section>
            <div class="container">
                <h2>인기 전공</h2>
                <div class="major-tags">{{MAJOR_TAGS}}</div>
                {{SUBJECT_RANK_LIST}}
            </div>
        </section>

        <!-- ⑤ 학비·요건 표 -->
        <section>
            <div class="container">
                <h2>학비·요건 한눈에</h2>
                <table class="fact-table">
                    {{FACT_ROWS}}
                </table>
                <p class="disclaimer">공식 요강 기준이며 전공·연도에 따라 달라질 수 있습니다.<br>원화 금액은 조회 시점의 환율로 자동 계산된 참고 값입니다.<br>최신 정보는 공식 홈페이지에서 확인하세요. (정보 확인: {{LAST_VERIFIED}})</p>
            </div>
        </section>
{{VIDEO_SECTION}}{{EDITOR_NOTE_SECTION}}{{RELATED_SECTION}}
        <!-- ⑥ 하단 CTA -->
        <section class="cta-section">
            <div class="container">
                <h2>내 조건이면 어떤 경로가 맞을까?</h2>
                <p class="cta-lead">3분 진단으로 {{NAME_KO}} 진학 가능성을 바로 확인해 보세요.</p>
                <div class="cta-buttons">
                    <a class="btn btn-primary" href="{{DIAG_URL}}">3분 진단 시작</a>
                    <a class="btn btn-secondary" href="../index.html#contact">상담 문의</a>
                </div>
            </div>
        </section>
    </main>

    <footer class="site-footer">
        <div class="container">
            <p>출처: QS World University Rankings · 각 대학 공식 공시 자료</p>
            <p>본 페이지는 특정 유학원·기관과 무관한 무료 정보 페이지입니다.</p>
            <p>© 2026 Study Guide Hub</p>
        </div>
    </footer>

    <!-- 원화 환산 — 조회 시점의 환율을 받아 학비 옆에 표시. 실패하면 조용히 생략 -->
    <script>
    (function () {
        var els = document.querySelectorAll('.krw');
        if (!els.length) return;
        fetch('https://open.er-api.com/v6/latest/{{CURRENCY}}')
            .then(function (r) { return r.json(); })
            .then(function (d) {
                var rate = d && d.rates && d.rates.KRW;
                if (!rate) return;
                function fmt(v) {
                    var man = Math.round(v * rate / 10000);
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
                    el.textContent = '약 ' + (min === max ? fmt(min) : fmt(min).replace(' 원', '') + '~' + fmt(max));
                });
                var today = new Date();
                var dateNote = today.getFullYear() + '. ' + (today.getMonth() + 1) + '. ' + today.getDate() + '. 환율 기준';
                document.querySelectorAll('.fx-date').forEach(function (el) {
                    el.textContent = dateNote;
                });
            })
            .catch(function () {});
    })();
    </script>
</body>
</html>
'@

# ---------- 목록 페이지 템플릿 ----------
$LIST_TEMPLATE = @'
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>영국 대학교 안내 | Study Guide Hub</title>
    <meta name="description" content="영국 대학교 {{COUNT}}곳의 학비·IELTS 기준·진학 경로를 한눈에 비교하세요. 공식 요강 기준 무료 정보 가이드.">
    <link rel="canonical" href="{{SITE}}uni/">
    <meta property="og:type" content="website">
    <meta property="og:site_name" content="Study Guide Hub">
    <meta property="og:title" content="영국 대학교 {{COUNT}}곳 안내 | Study Guide Hub">
    <meta property="og:description" content="영국 대학교 {{COUNT}}곳의 학비·IELTS 기준·진학 경로를 한눈에 비교하세요. 공식 요강 기준 무료 정보 가이드.">
    <meta property="og:url" content="{{SITE}}uni/">
    <meta property="og:image" content="{{SITE}}images/og-image.jpg?v=20260727">
    <meta property="og:image:width" content="1200">
    <meta property="og:image:height" content="630">
    <meta property="og:locale" content="ko_KR">
    <meta name="twitter:card" content="summary_large_image">

    <script>
        (function () {
            var t = 'light';
            try {
                var saved = localStorage.getItem('sgh-theme');
                if (saved === 'light' || saved === 'dark') t = saved;
                else localStorage.setItem('sgh-theme', t);
            } catch (e) {}
            document.documentElement.setAttribute('data-theme', t);
        })();
    </script>

    <link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css">
    <style>
        :root {
            --bg: #0b0b0f; --surface: #1d1d1f; --text: #f5f5f7; --body-text: #c7c7cc;
            --mute: #86868b; --line: rgba(255,255,255,0.14); --card-bg: rgba(255,255,255,0.05);
            --accent: #FFDE59; --accent-text: #1d1d1f; --link: #2997ff;
            --header-bg: rgba(0,0,0,0.8);
        }
        :root[data-theme="light"] {
            --bg: #ffffff; --surface: #f5f5f7; --text: #1d1d1f; --body-text: #4a4a4f;
            --mute: #6e6e73; --line: rgba(0,0,0,0.12); --card-bg: #ffffff;
            --accent: #A87E00; --accent-text: #ffffff; --link: #0066cc;
            --header-bg: rgba(255,255,255,0.82);
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Pretendard Variable', Pretendard, -apple-system, BlinkMacSystemFont, system-ui, sans-serif;
            background: var(--bg); color: var(--text); line-height: 1.6;
            -webkit-font-smoothing: antialiased;
        }
        .container { max-width: 1024px; margin: 0 auto; padding: 0 20px; }
        a { color: var(--link); text-decoration: none; }

        .site-header {
            position: sticky; top: 0; z-index: 10; backdrop-filter: blur(14px);
            background: var(--header-bg); border-bottom: 1px solid var(--line);
        }
        .site-header .container { display: flex; align-items: center; justify-content: space-between; height: 52px; }
        .brand { font-weight: 700; color: var(--text); font-size: 15px; }
        .header-actions { display: flex; align-items: center; gap: 14px; }
        .header-cta { font-size: 13px; font-weight: 600; }
        .theme-btn {
            width: 34px; height: 34px; border-radius: 50%; cursor: pointer;
            border: 1px solid var(--line); background: none; font-size: 15px; line-height: 1;
        }
        .theme-btn::before { content: '\1F319'; }
        :root[data-theme="dark"] .theme-btn::before { content: '\2600\FE0F'; }

        .list-hero { padding: 44px 0 28px; }
        .crumb { font-size: 13px; color: var(--mute); margin-bottom: 16px; }
        .list-hero h1 { font-size: clamp(26px, 4.5vw, 36px); letter-spacing: -0.02em; margin-bottom: 8px; }
        .list-hero p { font-size: 15px; color: var(--body-text); }

        .toolbar { display: flex; flex-wrap: wrap; gap: 10px; align-items: center; margin: 22px 0 6px; }
        .search-box {
            flex: 1 1 240px; min-height: 44px; padding: 0 16px; font-size: 15px;
            font-family: inherit; color: var(--text);
            background: var(--card-bg); border: 1px solid var(--line); border-radius: 12px;
        }
        .search-box::placeholder { color: var(--mute); }
        .sort-group { display: flex; gap: 6px; }
        .sort-btn {
            min-height: 44px; padding: 0 16px; font-size: 14px; font-weight: 600; cursor: pointer;
            font-family: inherit; color: var(--body-text);
            background: var(--card-bg); border: 1px solid var(--line); border-radius: 999px;
        }
        .sort-btn[aria-pressed="true"] { background: var(--text); color: var(--bg); border-color: var(--text); }
        .result-count { font-size: 13px; color: var(--mute); margin-bottom: 18px; }

        .uni-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; padding-bottom: 60px; }
        @media (max-width: 860px) { .uni-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 560px) { .uni-grid { grid-template-columns: 1fr; } }
        .uni-card {
            display: flex; flex-direction: column; gap: 10px;
            background: var(--card-bg); border: 1px solid var(--line);
            border-radius: 16px; padding: 18px; color: var(--text);
            transition: border-color .15s, transform .15s;
        }
        .uni-card:hover { border-color: var(--accent); transform: translateY(-2px); }
        .uni-card.is-hidden { display: none; }
        .card-top { display: flex; justify-content: space-between; align-items: flex-start; gap: 10px; min-height: 46px; }
        .card-logo { width: 74px; height: 44px; object-fit: contain; flex-shrink: 0; }
        :root[data-theme="dark"] .card-logo { filter: brightness(0) invert(1); opacity: .9; }
        .qs-badge {
            font-size: 12px; font-weight: 700; white-space: nowrap;
            background: var(--accent); color: var(--accent-text);
            border-radius: 8px; padding: 3px 9px;
        }
        .qs-badge.is-unranked { background: none; color: var(--mute); border: 1px solid var(--line); font-weight: 600; }
        .uni-card h2 { font-size: 17px; letter-spacing: -0.01em; }
        .card-en { font-size: 12px; color: var(--mute); margin-top: -6px; }
        .card-meta { font-size: 13px; color: var(--body-text); display: flex; flex-wrap: wrap; gap: 4px 12px; }
        .card-meta b { color: var(--text); }
        .card-go { font-size: 14px; font-weight: 700; color: var(--link); margin-top: auto; }
        .empty { padding: 40px 0 80px; color: var(--mute); font-size: 15px; }

        .site-footer { background: var(--surface); padding: 28px 0 40px; }
        .site-footer p { font-size: 12px; color: var(--mute); margin-bottom: 6px; }
    </style>
</head>
<body>

    <header class="site-header">
        <div class="container">
            <a href="../index.html" class="brand">Study Guide Hub</a>
            <div class="header-actions">
                <button type="button" class="theme-btn" aria-label="화면 모드 전환" title="밝게 / 어둡게" onclick="var r=document.documentElement,t=r.getAttribute('data-theme')==='dark'?'light':'dark';r.setAttribute('data-theme',t);try{localStorage.setItem('sgh-theme',t)}catch(e){}"></button>
                <a href="../index.html#contact" class="header-cta">상담 문의</a>
            </div>
        </div>
    </header>

    <main>
        <section class="list-hero">
            <div class="container">
                <p class="crumb"><a href="../index.html">홈</a> › 영국 대학교</p>
                <h1>영국 대학교 {{COUNT}}곳</h1>
                <p>학비·IELTS 기준·진학 경로를 학교별로 정리했습니다. 학교를 눌러 상세 정보를 확인하세요.</p>

                <div class="toolbar">
                    <input type="search" class="search-box" id="q" placeholder="학교명 또는 도시 검색 (예: 맨체스터, London)" aria-label="학교 검색">
                    <div class="sort-group" role="group" aria-label="정렬 기준">
                        <button type="button" class="sort-btn" data-sort="qs" aria-pressed="true">QS 순위</button>
                        <button type="button" class="sort-btn" data-sort="fee" aria-pressed="false">학비 낮은 순</button>
                        <button type="button" class="sort-btn" data-sort="name" aria-pressed="false">가나다순</button>
                    </div>
                </div>
                <p class="result-count" id="count"></p>
            </div>
        </section>

        <div class="container">
            <div class="uni-grid" id="grid">
{{CARDS}}
            </div>
            <p class="empty is-hidden" id="empty" hidden>검색 결과가 없습니다. 다른 이름으로 찾아보세요.</p>
        </div>
    </main>

    <footer class="site-footer">
        <div class="container">
            <p>출처: QS World University Rankings · 각 대학 공식 공시 자료 (정보 확인: {{LAST_VERIFIED}})</p>
            <p>학비는 공식 요강 기준이며 전공·연도에 따라 달라질 수 있습니다.</p>
            <p>© 2026 Study Guide Hub</p>
        </div>
    </footer>

    <script>
    (function () {
        var grid = document.getElementById('grid');
        var cards = [].slice.call(grid.children);
        var q = document.getElementById('q');
        var count = document.getElementById('count');
        var empty = document.getElementById('empty');
        var sortKey = 'qs';

        function num(el, attr) {
            var v = parseFloat(el.getAttribute(attr));
            return isNaN(v) ? Infinity : v;   // 값 없는 학교는 항상 뒤로
        }
        function render() {
            var term = q.value.trim().toLowerCase();
            cards.sort(function (a, b) {
                if (sortKey === 'name') return a.getAttribute('data-name').localeCompare(b.getAttribute('data-name'), 'ko');
                return num(a, 'data-' + sortKey) - num(b, 'data-' + sortKey);
            });
            var shown = 0;
            cards.forEach(function (c) {
                var hit = !term || c.getAttribute('data-search').indexOf(term) > -1;
                c.classList.toggle('is-hidden', !hit);
                if (hit) shown++;
                grid.appendChild(c);
            });
            count.textContent = shown + '개 학교';
            empty.hidden = shown > 0;
        }
        q.addEventListener('input', render);
        document.querySelectorAll('.sort-btn').forEach(function (btn) {
            btn.addEventListener('click', function () {
                sortKey = btn.getAttribute('data-sort');
                document.querySelectorAll('.sort-btn').forEach(function (b) {
                    b.setAttribute('aria-pressed', String(b === btn));
                });
                render();
            });
        });
        render();
    })();
    </script>
</body>
</html>
'@

# ---------- 생성 ----------
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$built = 0
$listCards = ''
$listCount = 0
$latestVerified = ''
$allIds = @()

$dataFiles = Get-ChildItem -Path (Join-Path $repoRoot 'data') -Filter 'universities-*.json' -File
foreach ($file in $dataFiles) {
    $unis = Get-Content -Path $file.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($unis -isnot [System.Array]) { $unis = @($unis) }

    foreach ($u in $unis) {
        $symbol   = if ($CURRENCY_SYMBOL.ContainsKey($u.currency)) { $CURRENCY_SYMBOL[$u.currency] } else { $u.currency + ' ' }
        $diagUrl  = if ($DIAG_URL.ContainsKey($u.country)) { $DIAG_URL[$u.country] } else { '../index.html' }
        $typeText = if ($TYPE_LABEL.ContainsKey($u.type)) { $TYPE_LABEL[$u.type] } else { $u.type }

        # 랭킹 뱃지 — 전공 순위를 종합 순위보다 강조
        $rankBadges = ''
        foreach ($sr in @($u.qs_subject_ranks)) {
            if ($null -ne $sr) {
                $rankBadges += ('<span class="rank-badge--subject">{0} QS 세계 {1}위</span>' -f (Esc $sr.subject), $sr.rank)
            }
        }
        if ($null -ne $u.qs_rank) {
            $rankBadges += ('<span class="rank-badge--overall">QS 종합 {0}위</span>' -f $u.qs_rank)
        }

        # 핵심 수치
        $tuitionUg = Fmt-Tuition $u.tuition_ug_min $u.tuition_ug_max $symbol
        if ($null -eq $tuitionUg) { $tuitionUg = Fmt-Tuition $u.tuition_pg_min $u.tuition_pg_max $symbol }
        if ($null -eq $tuitionUg) { $tuitionUg = '문의' }
        $acceptedOther = @($u.english.accepted | Where-Object { $_ -ne 'ielts' } | ForEach-Object { $ENGLISH_LABEL[$_] })
        $acceptedSub = if ($acceptedOther.Count -gt 0) { ($acceptedOther -join [char]0x00B7) + ' 인정' } else { 'IELTS 기준' }

        # 진학 경로 카드 — level(ug/pg)이 섞여 있으면 학사/석사 그룹으로 나눔
        $ugPaths = @($u.pathways | Where-Object { $null -ne $_ -and $_.level -ne 'pg' })
        $pgPaths = @($u.pathways | Where-Object { $null -ne $_ -and $_.level -eq 'pg' })
        $pathwayCards = ''
        if ($ugPaths.Count -gt 0 -and $pgPaths.Count -gt 0) {
            $pathwayCards += '<h3 class="pw-group">학사 과정</h3>'
            foreach ($pw in $ugPaths) { $pathwayCards += New-PathwayCard $pw $diagUrl }
            $pathwayCards += '<h3 class="pw-group">석사 과정</h3>'
            foreach ($pw in $pgPaths) { $pathwayCards += New-PathwayCard $pw $diagUrl }
        } else {
            foreach ($pw in @($u.pathways)) { if ($null -ne $pw) { $pathwayCards += New-PathwayCard $pw $diagUrl } }
        }

        # 학교 로고 — images/uni/{id}-logo.(png|svg) 파일이 있으면 학교명 우측에 표시
        $uniLogo = ''
        foreach ($ext in @('png', 'svg')) {
            $logoRel = 'images/uni/' + $u.id + '-logo.' + $ext
            if (Test-Path (Join-Path $repoRoot $logoRel)) {
                $uniLogo = '<img class="uni-logo" src="../' + $logoRel + '" alt="' + (Esc $u.name_ko) + ' 로고">'
                break
            }
        }

        # 배너 이미지 — images/uni/{id}.jpg 파일이 있으면 자동 표시
        $heroBanner = ''
        $bannerRel = 'images/uni/' + $u.id + '.jpg'
        if (Test-Path (Join-Path $repoRoot $bannerRel)) {
            $heroBanner = '<div class="hero-banner"><img src="../' + $bannerRel + '" alt="' + (Esc $u.name_ko) + ' 캠퍼스"></div>'
        }

        # 공식 유튜브 임베드 — youtube_id 없으면 섹션 자체를 생략
        $videoSection = ''
        if ($u.youtube_id) {
            $videoSection = @"

        <section>
            <div class="container">
                <h2>캠퍼스 둘러보기</h2>
                <div class="video-wrap"><iframe src="https://www.youtube-nocookie.com/embed/$($u.youtube_id)" title="$(Esc $u.name_ko) 공식 캠퍼스 영상" loading="lazy" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></div>
                <p class="disclaimer">출처: 대학 공식 유튜브 채널</p>
            </div>
        </section>
"@
        }

        # 전공 태그 + 전공별 QS 순위
        $majorTags = (@($u.popular_majors) | ForEach-Object { '<span class="major-tag">' + (Esc $_) + '</span>' }) -join ''
        $subjectRankList = ''
        $srItems = ''
        foreach ($sr in @($u.qs_subject_ranks)) {
            if ($null -ne $sr) {
                $srItems += ('<li>{0}<span class="rank-chip">QS 전공 {1}위</span></li>' -f (Esc $sr.subject), $sr.rank)
            }
        }
        if ($srItems) { $subjectRankList = '<ul class="subject-ranks">' + $srItems + '</ul>' }

        # 학비·요건 표
        $rows = ''
        $ugText = Fmt-Tuition $u.tuition_ug_min $u.tuition_ug_max $symbol
        $pgText = Fmt-Tuition $u.tuition_pg_min $u.tuition_pg_max $symbol
        if ($ugText) { $rows += '<tr><th>학부 연간 학비</th><td>' + $ugText + ' <small class="krw" data-min="' + $u.tuition_ug_min + '" data-max="' + $u.tuition_ug_max + '"></small></td></tr>' }
        if ($pgText) { $rows += '<tr><th>석사 연간 학비</th><td>' + $pgText + ' <small class="krw" data-min="' + $u.tuition_pg_min + '" data-max="' + $u.tuition_pg_max + '"></small></td></tr>' }
        $ieltsText = 'IELTS ' + $u.english.ielts_min
        if ($u.english.note) { $ieltsText += ' (' + (Esc $u.english.note) + ')' }
        $rows += '<tr><th>영어 최소 기준</th><td>' + $ieltsText + '</td></tr>'
        $acceptedAll = (@($u.english.accepted | ForEach-Object { $ENGLISH_LABEL[$_] })) -join ([string][char]0x00B7)
        $rows += '<tr><th>인정 영어 시험</th><td>' + $acceptedAll + '</td></tr>'
        $rows += '<tr><th>입학 시기</th><td>' + ((@($u.intakes)) -join ' &middot; ') + '</td></tr>'

        # 비어 있으면 렌더링하지 않는 섹션
        $editorSection = ''
        if ($u.editor_note) {
            $editorSection = @"

        <section>
            <div class="container">
                <h2>에디터 노트</h2>
                <div class="editor-note">$(Esc $u.editor_note)</div>
            </div>
        </section>
"@
        }
        $relatedSection = ''
        if (@($u.related_ids).Count -gt 0 -and $null -ne $u.related_ids) {
            $links = (@($u.related_ids) | ForEach-Object { '<a href="./' + (Esc $_) + '.html">' + (Esc $_) + '</a>' }) -join ''
            $relatedSection = @"

        <section>
            <div class="container">
                <h2>함께 보면 좋은 대학</h2>
                <div class="related-links">$links</div>
            </div>
        </section>
"@
        }

        # OG 이미지 — 학교 배너가 있으면 그걸, 없으면 허브 공용 이미지
        $ogImage = if ($heroBanner) { $SITE + $bannerRel } else { $SITE + 'images/og-image.jpg?v=20260727' }

        $html = $TEMPLATE
        $tokens = @{
            '{{ID}}'                  = $u.id
            '{{SITE}}'                = $SITE
            '{{OG_IMAGE}}'            = $ogImage
            '{{NAME_KO}}'             = Esc $u.name_ko
            '{{NAME_EN}}'             = Esc $u.name_en
            '{{COUNTRY}}'             = Esc $u.country
            '{{CITY}}'                = Esc $u.city
            '{{TYPE_LABEL}}'          = Esc $typeText
            '{{RANK_BADGES}}'         = $rankBadges
            '{{DIAG_URL}}'            = $diagUrl
            '{{OFFICIAL_URL}}'        = Esc $u.official_url
            '{{TUITION_UG}}'          = $tuitionUg
            '{{IELTS_MIN}}'           = [string]$u.english.ielts_min
            '{{ACCEPTED_SUB}}'        = $acceptedSub
            '{{INTAKES}}'             = (@($u.intakes)) -join ' &middot; '
            '{{PATHWAY_COUNT}}'       = [string](@($u.pathways).Count)
            '{{PATHWAY_CARDS}}'       = $pathwayCards
            '{{MAJOR_TAGS}}'          = $majorTags
            '{{SUBJECT_RANK_LIST}}'   = $subjectRankList
            '{{FACT_ROWS}}'           = $rows
            '{{LAST_VERIFIED}}'       = Esc $u.last_verified
            '{{MAP_QUERY}}'           = [uri]::EscapeDataString($u.name_en + ', ' + $u.city)
            '{{CURRENCY}}'            = Esc $u.currency
            '{{UG_MIN}}'              = [string]$u.tuition_ug_min
            '{{UG_MAX}}'              = [string]$u.tuition_ug_max
            '{{UNI_LOGO}}'            = $uniLogo
            '{{HERO_BANNER}}'         = $heroBanner
            '{{VIDEO_SECTION}}'       = $videoSection
            '{{EDITOR_NOTE_SECTION}}' = $editorSection
            '{{RELATED_SECTION}}'     = $relatedSection
        }
        foreach ($key in $tokens.Keys) { $html = $html.Replace($key, [string]$tokens[$key]) }

        $outPath = Join-Path $outDir ($u.id + '.html')
        [IO.File]::WriteAllText($outPath, $html, $utf8NoBom)
        Write-Host ("생성: uni\{0}.html" -f $u.id) -ForegroundColor Green
        $built++

        # ---- 목록 페이지용 카드 ----
        $cardLogo = if ($uniLogo) { $uniLogo.Replace('class="uni-logo"', 'class="card-logo"').Replace('src="../', 'src="../') } else { '<span></span>' }
        $qsBadge = if ($null -ne $u.qs_rank) {
            '<span class="qs-badge">QS ' + $u.qs_rank + '위</span>'
        } else {
            '<span class="qs-badge is-unranked">QS 200위권 밖</span>'
        }
        $sortFee = if ($null -ne $u.tuition_ug_min) { $u.tuition_ug_min } elseif ($null -ne $u.tuition_pg_min) { $u.tuition_pg_min } else { '' }
        $searchKey = ($u.name_ko + ' ' + $u.name_en + ' ' + $u.city).ToLower()
        $listCards += @"
                <a class="uni-card" href="./$($u.id).html" data-qs="$($u.qs_rank)" data-fee="$sortFee" data-name="$(Esc $u.name_ko)" data-search="$(Esc $searchKey)">
                    <div class="card-top">$cardLogo$qsBadge</div>
                    <h2>$(Esc $u.name_ko)</h2>
                    <p class="card-en">$(Esc $u.name_en)</p>
                    <div class="card-meta">
                        <span>$(Esc $u.city)</span>
                        <span>학비 <b>$tuitionUg</b></span>
                        <span>IELTS <b>$($u.english.ielts_min)</b></span>
                    </div>
                    <span class="card-go">자세히 보기 &rarr;</span>
                </a>

"@
        $listCount++
        $allIds += $u.id
        if ($u.last_verified -gt $latestVerified) { $latestVerified = $u.last_verified }
    }
}

# ---------- 목록 페이지 ----------
$listHtml = $LIST_TEMPLATE.Replace('{{CARDS}}', $listCards).Replace('{{COUNT}}', [string]$listCount).Replace('{{LAST_VERIFIED}}', $latestVerified).Replace('{{SITE}}', $SITE)
[IO.File]::WriteAllText((Join-Path $outDir 'index.html'), $listHtml, $utf8NoBom)
Write-Host '생성: uni\index.html (목록)' -ForegroundColor Green

# ---------- sitemap.xml / robots.txt ----------
$locs = @('', 'privacy.html', 'uni/') + ($allIds | ForEach-Object { 'uni/' + $_ + '.html' })
$sitemap = '<?xml version="1.0" encoding="UTF-8"?>' + "`n" +
           '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' + "`n" +
           (($locs | ForEach-Object { '  <url><loc>' + $SITE + $_ + '</loc></url>' }) -join "`n") + "`n" +
           '</urlset>' + "`n"
[IO.File]::WriteAllText((Join-Path $repoRoot 'sitemap.xml'), $sitemap, $utf8NoBom)
[IO.File]::WriteAllText((Join-Path $repoRoot 'robots.txt'), "User-agent: *`nAllow: /`nSitemap: ${SITE}sitemap.xml`n", $utf8NoBom)
Write-Host ("생성: sitemap.xml ({0}개 URL) + robots.txt" -f $locs.Count) -ForegroundColor Green

Write-Host ''
Write-Host "완료 — 상세 페이지 ${built}개 + 목록 페이지 1개 생성" -ForegroundColor Cyan
