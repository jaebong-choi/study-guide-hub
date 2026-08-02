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
    'AU' = 'https://jaebong-choi.github.io/au-study-guide/'
    'CA' = 'https://jaebong-choi.github.io/ca-study-guide/'
    'US' = 'https://jaebong-choi.github.io/us-study-guide/'
}
# 국가별 목록 페이지 정보 — UK는 기존 URL(uni/index.html) 유지, 나머지는 uni/{cc}.html
# noun: 캐나다는 컬리지 중심 DB라 명사를 달리 쓴다
$COUNTRY_INFO = @{
    'UK' = @{ ko = '영국';   enAdj = 'UK';         file = 'index.html'; noun = '대학교'; enNoun = 'universities' }
    'AU' = @{ ko = '호주';   enAdj = 'Australian'; file = 'au.html';    noun = '대학교'; enNoun = 'universities' }
    'CA' = @{ ko = '캐나다'; enAdj = 'Canadian';   file = 'ca.html';    noun = '대학·컬리지'; enNoun = 'universities and colleges' }
    'US' = @{ ko = '미국';   enAdj = 'US';         file = 'us.html';    noun = '대학·컬리지'; enNoun = 'universities and colleges' }
}
# 학비 출처 문구 — 국가마다 근거가 달라 푸터에서 따로 밝힌다.
# 미국은 대학별 international 요강이 아니라 교육부 공시(College Scorecard) 값이라 반드시 표기한다.
$FEE_NOTE_DEFAULT = '<p data-en="Fees follow official university publications and vary by course and year.">학비는 공식 요강 기준이며 전공·연도에 따라 달라질 수 있습니다.</p>'
$FEE_NOTE = @{
    'AU' = '<p data-en="Fees are either the range each university publishes in its official fee schedule, or the middle range (25th-75th percentile) of annual tuition for courses registered on the Australian Government&#39;s CRICOS register (checked August 2026). Actual fees vary by course.">학비는 각 대학이 공시한 요금표 범위이거나, 대학이 학비를 과정별로만 공시하는 경우 호주 정부 CRICOS 등록부에 등록된 과정별 학비를 연간으로 환산한 중간 구간(25~75%)입니다(2026년 8월 확인). 실제 학비는 전공에 따라 다릅니다.</p>'
    'CA' = '<p data-en="College tuition is the international rate each college publishes for a two-semester year. Some colleges do not separate tuition from compulsory fees, so their figure is the combined amount, and the cost varies widely by programme.">컬리지 학비는 각 학교가 공시한 국제학생 요율로, 연간(2학기) 수업료 기준입니다. 학교에 따라 수업료와 필수비를 나눠 공시하지 않아 합산 금액인 경우가 있고, 전공에 따라 차이가 큽니다.</p>'
    'US' ='<p data-en="Tuition figures come from the US Department of Education&#39;s College Scorecard (published June 2026). Private universities charge every student the same rate; at public universities this is the out-of-state rate, which is what international students generally pay, though some add an international surcharge.">학비는 미국 교육부 College Scorecard 공시(2026년 6월판) 기준입니다. 사립대는 전 학생이 같은 금액을 내고, 주립대는 주외(out-of-state) 요율로 유학생이 대체로 이 금액을 냅니다. 학교에 따라 유학생 추가 부담금이 붙을 수 있습니다.</p>'
}

# 목록 페이지 진학 경로 필터 — 칩을 누르면 해당 경로가 있는 학교만 남는다.
# 토큰은 pathways[].type 그대로이고, type-college/type-university와 uk 전용 direct-only만 계산값이다.
$LIST_FILTERS = @{
    'UK' = @(
        @('foundation',      '파운데이션 입학',    'Foundation entry'),
        @('iyo',             'IYO 운영',           'International Year One'),
        @('pre-master',      '프리마스터 운영',    "Pre-Master's"),
        @('direct-only',     'Direct만 입학 가능', 'Direct entry only')
    )
    'AU' = @(
        @('foundation',      '파운데이션 운영',    'Foundation'),
        @('transfer',        '디플로마 편입',      'Diploma pathway'),
        @('type-college',    'TAFE·컬리지',        'TAFE & colleges')
    )
    'US' = @(
        @('pathway',         '패스웨이(조건부) 가능', 'Pathway (conditional) entry'),
        @('transfer',        '2+2 편입 연계',      '2+2 transfer route'),
        @('type-college',    '커뮤니티칼리지',     'Community colleges')
    )
    'CA' = @(
        @('type-college',    '컬리지',             'Colleges'),
        @('type-university', '4년제 대학',         'Universities'),
        @('transfer',        '대학 편입 연계',     'University transfer route')
    )
}
function New-FilterChips([string]$cc) {
    if (-not $LIST_FILTERS.ContainsKey($cc)) { return '' }
    $btns = ($LIST_FILTERS[$cc] | ForEach-Object {
        '                        <button type="button" class="sort-btn filter-btn" data-f="' + $_[0] +
        '" aria-pressed="false" data-en="' + (Esc $_[2]) + '">' + (Esc $_[1]) + '</button>'
    }) -join "`n"
    return '<div class="filter-row" role="group" aria-label="진학 경로 필터" data-en-aria="Entry route filter">' + "`n" +
           '                        <span class="filter-cap" data-en="Entry routes">진학 경로</span>' + "`n" +
           $btns + "`n" + '                    </div>'
}

# 미국 커뮤니티칼리지는 Scorecard가 아니라 각 칼리지 international 공시값이라 문구를 따로 쓴다.
$FEE_NOTE_US_CC = '<p data-en="Tuition for community colleges comes from each college&#39;s own international student page (checked August 2026) and covers tuition and mandatory college fees only, without insurance, books or living costs.">커뮤니티칼리지 학비는 각 칼리지 international 공시 페이지 기준입니다(2026년 8월 확인). 수업료와 필수 학교비만 담았고 보험·교재·생활비는 빠져 있습니다.</p>'
# 미국 목록 페이지는 4년제와 컬리지가 섞여 있어 두 출처를 함께 밝힌다.
$FEE_NOTE_US_LIST = $FEE_NOTE_US_CC

function Esc([string]$s) {
    if ($null -eq $s) { return '' }
    return $s.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;')
}

# ---------- 영어 전환 ----------
# 데이터에서 나온 한국어만 data\i18n-uni.json(한국어 원문 → 영어)으로 옮긴다.
# 템플릿의 고정 문구는 마크업에 data-en을 직접 적어 두므로 사전에 넣지 않는다.
$dictPath = Join-Path $repoRoot 'data\i18n-uni.json'
$I18N = @{}
if (Test-Path $dictPath) {
    (Get-Content $dictPath -Raw -Encoding UTF8 | ConvertFrom-Json).PSObject.Properties |
        ForEach-Object { $I18N[$_.Name] = $_.Value }
}
$missing = [ordered]@{}

function En([string]$s) {
    if ([string]::IsNullOrEmpty($s)) { return $s }
    if ($I18N.ContainsKey($s)) { return $I18N[$s] }
    if ($s -match '[가-힣]') { $script:missing[$s] = $true }   # 번역 누락은 빌드 끝에 보고
    return $s
}

# 한국어와 영어가 다를 때만 data-en 속성을 붙인다. 영어 쪽은 HTML 조각도 허용.
function EnAttr([string]$ko, [string]$en) {
    if ($en -eq $ko) { return '' }
    return ' data-en="' + (Esc $en) + '"'
}

# IELTS 밴드는 항상 소수점 한 자리로 적는다(7 -> 7.0).
function Fmt-Ielts($v) {
    if ($null -eq $v) { return '' }
    return ([double]$v).ToString('0.0', [cultureinfo]::InvariantCulture)
}

function New-PathwayCard($pw, [string]$diagUrl, [string]$country) {
    $pwLabel = if ($PATHWAY_LABEL.ContainsKey($pw.type)) { $PATHWAY_LABEL[$pw.type] } else { $pw.type }
    # 호주의 편입은 디플로마 경유라는 것을 라벨에서 드러낸다
    if ($country -eq 'AU' -and $pw.type -eq 'transfer') { $pwLabel = '편입 (호주 디플로마)' }
    # 캐나다의 pathway는 현지 고교 학점(OSSD 등)을 쌓는 경로라 '패스웨이'로 뭉뚱그리지 않는다
    if ($country -eq 'CA' -and $pw.type -eq 'pathway') { $pwLabel = '캐나다 국제 사립학교를 통한 진학' }
    # 경로 안내 모달 — 해당하는 경로는 진단으로 바로 가지 않고 프로그램 설명을 먼저 띄운다
    $guideKey = $null
    if ($country -eq 'AU' -and $pw.type -eq 'foundation') { $guideKey = 'au-foundation' }
    elseif ($country -eq 'AU' -and $pw.type -eq 'transfer') { $guideKey = 'au-diploma' }
    elseif ($country -eq 'UK' -and $pw.type -eq 'foundation') { $guideKey = 'uk-foundation' }
    elseif ($country -eq 'UK' -and $pw.type -eq 'iyo') { $guideKey = 'uk-iyo' }
    elseif ($country -eq 'UK' -and $pw.type -eq 'pre-master') { $guideKey = 'pre-master' }   # 현재 프리마스터는 영국만 존재. 다른 국가에 생기면 가이드 링크도 함께 매핑할 것
    elseif ($country -eq 'CA' -and $pw.type -eq 'pathway') { $guideKey = 'ca-ossd' }
    elseif ($country -eq 'CA' -and $pw.type -eq 'foundation') { $guideKey = 'ca-foundation' }
    elseif ($country -eq 'CA' -and $pw.type -eq 'transfer' -and $pw.provider -match 'Navitas') { $guideKey = 'ca-pathway' }
    elseif ($country -eq 'US' -and $pw.type -eq 'pathway') { $guideKey = 'us-pathway' }
    elseif ($country -eq 'US' -and $pw.type -eq 'transfer') { $guideKey = 'us-transfer' }   # CC 2+2 편입 — 컬리지 페이지와 편입 도착지 대학 양쪽에 붙는다
    $provider = if ($pw.provider) {
        '<span class="pw-provider"' + (EnAttr $pw.provider (En $pw.provider)) + '>' + (Esc $pw.provider) + '</span>'
    } else { '' }
    $facts = ''
    if ($null -ne $pw.ielts_min) { $facts += '<span>IELTS <b>' + (Fmt-Ielts $pw.ielts_min) + '</b></span>' }
    if ($pw.duration) {
        $d = En $pw.duration
        $facts += '<span' + (EnAttr "기간 <b>$($pw.duration)</b>" "Duration <b>$d</b>") + '>기간 <b>' + (Esc $pw.duration) + '</b></span>'
    }
    if ($pw.cost_note) {
        $facts += '<span' + (EnAttr "비용 <b>$($pw.cost_note)</b>" "Cost <b>$(En $pw.cost_note)</b>") + '>비용 <b>' + (Esc $pw.cost_note) + '</b></span>'
    }
    $noteHtml = if ($pw.note) {
        '<p class="pw-note"' + (EnAttr $pw.note (En $pw.note)) + '>' + (Esc $pw.note) + '</p>'
    } else { '' }
    $cta = if ($guideKey) {
        '<button type="button" class="pw-link" onclick="openPwGuide(''' + $guideKey + ''')" data-en="Check this route &rarr;">이 경로로 진단 &rarr;</button>'
    } else {
        '<a class="pw-link" href="' + $diagUrl + '" data-en="Check this route &rarr;">이 경로로 진단 &rarr;</a>'
    }
    return @"
                <div class="pathway-card">
                    <div class="pw-head"><span class="pw-type"$(EnAttr $pwLabel (En $pwLabel))>$(Esc $pwLabel)</span>$provider</div>
                    <div class="pw-facts">$facts</div>
                    $noteHtml
                    $cta
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
        .lang-switch { display: inline-flex; border: 1px solid var(--line); border-radius: 999px; overflow: hidden; flex-shrink: 0; }
        .lang-switch button {
            border: 0; background: transparent; color: var(--mute); cursor: pointer;
            font-family: inherit; font-size: 11.5px; font-weight: 700; letter-spacing: 0.02em; padding: 6px 11px;
        }
        .lang-switch button:hover { color: var(--text); }
        .lang-switch button.on { background: var(--text); color: var(--bg); }

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
        /* 다크 모드: 예전에는 brightness(0) invert(1)로 흰 실루엣을 만들었는데,
         * 문장(crest)형 로고가 디테일 없는 흰 덩어리가 되어 알아볼 수 없었다.
         * 대신 밝은 플레이트를 깔고 원래 로고를 그대로 보여준다. */
        :root[data-theme="dark"] .uni-logo {
            background: #f2f2f4; border-radius: 10px; padding: 8px 12px;
        }
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
        .pw-link {
            font-size: 14px; font-weight: 700; color: var(--link);
            background: none; border: 0; padding: 0; cursor: pointer; font-family: inherit;
        }
        .pw-group { font-size: 15px; color: var(--mute); margin: 22px 0 10px; }
        .pw-group:first-child { margin-top: 0; }

        /* 경로 안내 모달 — 파운데이션·디플로마 등은 진단 전에 프로그램 설명을 먼저 보여준다 */
        .pw-modal-overlay {
            position: fixed; inset: 0; z-index: 100;
            background: rgba(0,0,0,0.55); display: flex; align-items: center; justify-content: center; padding: 20px;
        }
        /* display:flex가 hidden 속성(UA의 display:none)을 이겨버려 빈 모달이 항상 보였다.
         * hidden일 때는 어떤 경우에도 감춘다. */
        .pw-modal-overlay[hidden] { display: none !important; }
        .pw-modal {
            background: var(--bg); color: var(--text);
            border: 1px solid var(--line); border-radius: 20px;
            max-width: 480px; width: 100%; max-height: 85vh; overflow-y: auto;
            padding: 28px 28px 24px; position: relative;
        }
        .pw-modal-close {
            position: absolute; top: 14px; right: 14px; width: 32px; height: 32px;
            border-radius: 50%; border: 1px solid var(--line); background: var(--card-bg);
            color: var(--text); font-size: 15px; line-height: 1; cursor: pointer;
        }
        .pw-modal h3 { font-size: 19px; letter-spacing: -0.01em; margin-bottom: 14px; padding-right: 32px; }
        .pw-modal p { font-size: 14.5px; line-height: 1.7; color: var(--body-text); margin-bottom: 10px; word-break: keep-all; }
        .pw-modal mark {
            background: color-mix(in srgb, var(--accent) 28%, transparent);
            color: var(--text); font-weight: 700; padding: 0 3px; border-radius: 3px;
        }

        /* 경로 흐름도 — 고교부터 학위까지의 단계를 화살표 띠로 보여준다 */
        .flow { display: flex; gap: 3px; list-style: none; margin: 0 0 16px; padding: 0; }
        .flow-step {
            flex: 1 1 0; min-width: 0; padding: 10px 12px 10px 20px;
            background: var(--card-bg); border: 0;
            font-size: 12px; font-weight: 600; color: var(--text); line-height: 1.35;
            clip-path: polygon(0 0, calc(100% - 12px) 0, 100% 50%, calc(100% - 12px) 100%, 0 100%, 12px 50%);
            word-break: keep-all;
        }
        .flow-step span { display: block; font-size: 10.5px; font-weight: 500; color: var(--mute); margin-top: 2px; }
        .flow-step:first-child {
            padding-left: 12px;
            clip-path: polygon(0 0, calc(100% - 12px) 0, 100% 50%, calc(100% - 12px) 100%, 0 100%);
            background: var(--accent); color: var(--accent-text);
        }
        .flow-step:first-child span { color: var(--accent-text); opacity: .78; }
        .flow-step:last-child {
            clip-path: polygon(0 0, 100% 0, 100% 100%, 0 100%, 12px 50%);
            background: var(--text); color: var(--bg);
        }
        .flow-step:last-child span { color: var(--bg); opacity: .72; }
        /* 좁은 화면에서는 화살표 띠 대신 세로 목록으로 (clip-path는 가로 전용) */
        @media (max-width: 560px) {
            .flow { flex-direction: column; gap: 6px; }
            .flow-step, .flow-step:first-child, .flow-step:last-child {
                clip-path: none; border-radius: 10px; padding: 9px 12px; text-align: center;
            }
            .flow-step + .flow-step { position: relative; margin-top: 12px; }
            .flow-step + .flow-step::before {
                content: '\25BC'; position: absolute; top: -14px; left: 50%; transform: translateX(-50%);
                font-size: 9px; color: var(--mute);
            }
        }
        .pw-modal .btn { width: 100%; justify-content: center; margin-top: 14px; }
        .pw-guide-more { display: block; text-align: center; margin-top: 12px; font-size: 13.5px; font-weight: 600; }
        .pw-guide-more[hidden] { display: none; }

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

        /* 핵심 수치 바로 아래에 오는 자리라 본문보다 조금 크게 잡고,
           왼쪽 악센트 선으로 위쪽 데이터 카드와 성격을 구분한다. */
        .editor-note {
            background: var(--surface); border: 1px solid var(--line);
            border-left: 3px solid var(--accent); border-radius: 14px; padding: 20px 22px;
            font-size: 15.5px; line-height: 1.75; color: var(--text);
        }
        @media (max-width: 720px) { .editor-note { font-size: 15px; padding: 17px 18px; } }
        .related-links { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 12px; }
        .related-card {
            display: flex; align-items: center; gap: 14px;
            background: var(--card-bg); border: 1px solid var(--line);
            border-radius: 14px; padding: 14px 16px;
            transition: border-color .15s, transform .15s;
        }
        .related-card:hover { border-color: var(--accent); transform: translateY(-2px); }
        .related-card img { width: 64px; height: 40px; object-fit: contain; flex-shrink: 0; }
        :root[data-theme="dark"] .related-card img { background: #f2f2f4; border-radius: 8px; padding: 4px 6px; }
        .related-names { display: flex; flex-direction: column; min-width: 0; }
        .related-ko { font-size: 15px; font-weight: 700; color: var(--text); word-break: keep-all; }
        .related-en { font-size: 12px; color: var(--mute); }

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
                <div class="lang-switch" role="group" aria-label="언어 선택" data-en-aria="Language">
                    <button type="button" data-lang="ko" class="on" onclick="setLang('ko')">KO</button>
                    <button type="button" data-lang="en" onclick="setLang('en')">EN</button>
                </div>
                <button type="button" class="theme-btn" aria-label="화면 모드 전환" data-en-aria="Switch appearance" title="밝게 / 어둡게" data-en-title="Light / dark" onclick="var r=document.documentElement,t=r.getAttribute('data-theme')==='dark'?'light':'dark';r.setAttribute('data-theme',t);try{localStorage.setItem('sgh-theme',t)}catch(e){}"></button>
                <a href="../index.html#contact" class="header-cta" data-en="Contact">상담 문의</a>
            </div>
        </div>
    </header>

    <main>
        <!-- ① 헤더 -->
        <section class="uni-hero">
            <div class="container">
                <p class="crumb" data-en="&lt;a href=&quot;../index.html&quot;&gt;Home&lt;/a&gt; › {{COUNTRY}} › {{NAME_EN}}"><a href="../index.html">홈</a> › {{COUNTRY}} › {{NAME_KO}}</p>
                {{HERO_BANNER}}
                <div class="hero-top">
                    <div>
                        <div class="meta-badges">
                            {{CITY_BADGE}}
                            {{TYPE_BADGE}}
                            <span class="meta-badge">{{COUNTRY}}</span>
                        </div>
                        <h1 data-en="{{NAME_EN}}">{{NAME_KO}}</h1>
                        <p class="en-name" data-en="{{NAME_KO}}">{{NAME_EN}}</p>
                    </div>
                    {{UNI_LOGO}}
                </div>
                <div class="rank-badges">{{RANK_BADGES}}</div>
                <div class="hero-actions">
                    <a class="btn btn-primary" href="{{DIAG_URL}}" data-en="Start the 3-minute quiz">3분 진단 시작</a>
                    <a class="btn btn-secondary" href="{{OFFICIAL_URL}}" target="_blank" rel="noopener" data-en="Official website">공식 홈페이지</a>
                </div>
            </div>
        </section>

        <!-- ② 핵심 수치 -->
        <section>
            <div class="container">
                <div class="stat-grid">
                    <div class="stat-card">
                        {{TUITION_LABEL}}
                        <p class="stat-value"{{TUITION_UG_EN}}>{{TUITION_UG}}</p>
                        <p class="stat-sub krw" data-min="{{UG_MIN}}" data-max="{{UG_MAX}}"></p>
                    </div>
                    <div class="stat-card">
                        <p class="stat-label" data-en="IELTS requirement">IELTS 기준</p>
                        <p class="stat-value">{{IELTS_MIN}}</p>
                        <p class="stat-sub"{{ACCEPTED_SUB_EN}}>{{ACCEPTED_SUB}}</p>
                    </div>
                    <div class="stat-card">
                        <p class="stat-label" data-en="Intakes">입학 시기</p>
                        <p class="stat-value"{{INTAKES_EN}}>{{INTAKES}}</p>
                    </div>
                    <div class="stat-card">
                        <p class="stat-label" data-en="Entry routes">진학 경로</p>
                        <p class="stat-value" data-en="{{PATHWAY_COUNT}}">{{PATHWAY_COUNT}}개</p>
                    </div>
                </div>
                <p class="fx-date"></p>
            </div>
        </section>
{{EDITOR_NOTE_SECTION}}
        <!-- ③ 진학 경로 -->
        <section>
            <div class="container">
                <h2 data-en="Entry routes">진학 경로</h2>
                {{PATHWAY_CARDS}}
            </div>
        </section>

        <!-- ④ 전공 -->
        <section>
            <div class="container">
                <h2 data-en="Popular subjects">인기 전공</h2>
                <div class="major-tags">{{MAJOR_TAGS}}</div>
                {{SUBJECT_RANK_LIST}}
            </div>
        </section>

        <!-- ⑤ 학비·요건 표 -->
        <section>
            <div class="container">
                <h2 data-en="Tuition and requirements">학비·요건 한눈에</h2>
                <table class="fact-table">
                    {{FACT_ROWS}}
                </table>
                <p class="disclaimer" data-en="Figures follow official university publications and vary by course and year.&lt;br&gt;KRW amounts are indicative, converted at the exchange rate at the time of viewing.&lt;br&gt;Check the official website for the latest information. (Verified: {{LAST_VERIFIED}})">공식 요강 기준이며 전공·연도에 따라 달라질 수 있습니다.<br>원화 금액은 조회 시점의 환율로 자동 계산된 참고 값입니다.<br>최신 정보는 공식 홈페이지에서 확인하세요. (정보 확인: {{LAST_VERIFIED}})</p>
            </div>
        </section>

        <!-- ⑥ 위치 — 히어로에 있던 지도를 여기로 내렸다.
             임베드가 세로로 커서 히어로에 두면 에디터 노트와 핵심 수치가 첫 화면 밖으로 밀린다. -->
        <section>
            <div class="container">
                <h2 data-en="Location">위치</h2>
                <div class="map-wrap">
                    <iframe src="https://www.google.com/maps?q={{MAP_QUERY}}&amp;output=embed&amp;hl=ko" title="{{NAME_KO}} 위치 지도" data-en-title="{{NAME_EN}} location map" loading="lazy" referrerpolicy="no-referrer-when-downgrade" allowfullscreen></iframe>
                </div>
            </div>
        </section>
{{VIDEO_SECTION}}{{RELATED_SECTION}}
        <!-- ⑦ 하단 CTA -->
        <section class="cta-section">
            <div class="container">
                <h2 data-en="Which route fits your profile?">내 조건이면 어떤 경로가 맞을까?</h2>
                <p class="cta-lead" data-en="Take the 3-minute quiz to see how you match {{NAME_EN}}.">3분 진단으로 {{NAME_KO}} 진학 가능성을 바로 확인해 보세요.</p>
                <div class="cta-buttons">
                    <a class="btn btn-primary" href="{{DIAG_URL}}" data-en="Start the 3-minute quiz">3분 진단 시작</a>
                    <a class="btn btn-secondary" href="../index.html#contact" data-en="Contact">상담 문의</a>
                </div>
            </div>
        </section>
    </main>

    <footer class="site-footer">
        <div class="container">
            <p data-en="Sources: QS World University Rankings and official university publications">출처: QS World University Rankings · 각 대학 공식 공시 자료</p>
            {{FEE_NOTE}}
            <p data-en="A free information page, independent of any agency or institution.">본 페이지는 특정 유학원·기관과 무관한 무료 정보 페이지입니다.</p>
            <p>© 2026 Study Guide Hub</p>
        </div>
    </footer>

    <!-- 경로 안내 모달 -->
    <div class="pw-modal-overlay" id="pw-guide" hidden>
        <div class="pw-modal" role="dialog" aria-modal="true" aria-labelledby="pw-guide-title">
            <button type="button" class="pw-modal-close" onclick="closePwGuide()" aria-label="닫기">&#10005;</button>
            <h3 id="pw-guide-title"></h3>
            <ol class="flow" id="pw-guide-flow"></ol>
            <div id="pw-guide-body"></div>
            <a class="btn btn-primary" id="pw-guide-cta" href="{{DIAG_URL}}"></a>
            <a class="pw-guide-more" id="pw-guide-more" href="#"></a>
        </div>
    </div>
    <script>
    // 경로별 안내문 (ko/en) — 진단으로 넘어가기 전에 프로그램 개념을 설명한다
    var PW_GUIDES = {
        'au-foundation': {
            ko: {
                t: '파운데이션(대학예비과정)이란?',
                f: [['고교 2학년~졸업', '또는 동등 학력'], ['아카데믹 영어', '필요한 경우'], ['파운데이션', '8~12개월'], ['학사 1학년', '본교 진학']],
                b: ['고교 성적이나 영어가 직접 입학 기준에 조금 못 미쳐도, 대학 부설 기관에서 <mark>8개월~1년</mark> 영어와 전공 기초를 이수한 뒤 수료 성적으로 <mark>본교 1학년</mark>에 진학하는 경로입니다.',
                    '내신 부담이 컸던 학생이 상위권 대학으로 재도전하는 대표 루트이며, 수료 기준을 충족하면 <mark>진학이 보장</mark>되는 과정도 많습니다. 보통 <mark>IELTS 5.5</mark> 수준부터 시작할 수 있습니다.']
            },
            en: {
                t: 'What is a foundation year?',
                f: [['High school', 'Year 2 to graduate'], ['Academic English', 'if required'], ['Foundation', '8-12 months'], ['Bachelor Year 1', 'at the university']],
                b: ['A university-run preparatory course of <mark>8 months to a year</mark> combining English with academic subjects, leading into <mark>Year 1</mark> on completion grades even if your school grades or English fall short of direct entry.',
                    'Many programs <mark>guarantee progression</mark> once you meet the completion criteria. Entry typically starts from around <mark>IELTS 5.5</mark>.']
            }
        },
        'au-diploma': {
            ko: {
                t: '디플로마 편입이란?',
                f: [['고교 졸업', '또는 동등 학력'], ['아카데믹 영어', '필요한 경우'], ['디플로마', '8~16개월'], ['학사 2학년', '편입']],
                b: ['학부 1학년 과목을 대학 부설 컬리지에서 소규모 수업으로 이수한 뒤, 기준 성적(보통 <mark>60~70%</mark>)을 충족하면 <mark>본교 2학년으로 편입</mark>하는 경로입니다.',
                    '파운데이션보다 <mark>1년 빠르게</mark> 학위를 마칠 수 있고 1학년 학비도 절감됩니다. 보통 <mark>IELTS 5.5~6.0</mark>부터 지원할 수 있으며, 학교·전공별 학점 인정 범위가 다릅니다.']
            },
            en: {
                t: 'What is a diploma transfer?',
                f: [['High school', 'graduate'], ['Academic English', 'if required'], ['Diploma', '8-16 months'], ['Bachelor Year 2', 'transfer in']],
                b: ['You complete first-year subjects at the university college in smaller classes, then <mark>transfer into Year 2</mark> once you clear the grade threshold, usually <mark>60 to 70 per cent</mark>.',
                    'It finishes <mark>a year sooner</mark> than a foundation route and saves first-year fees. Entry typically starts around <mark>IELTS 5.5-6.0</mark>; credit recognition varies by school and course.']
            }
        },
        'uk-foundation': {
            ko: {
                t: '파운데이션(Foundation)이란?',
                f: [['고교 졸업', '한국 12년제'], ['아카데믹 영어', '필요한 경우'], ['파운데이션', '1년'], ['학사 1학년', '본교 진학']],
                b: ['영국 학부는 <mark>13년제 교육(A-level)</mark>을 전제로 하기 때문에, 한국 고교 졸업생은 보통 <mark>파운데이션 1년</mark>을 거쳐 학부 1학년으로 진학합니다.',
                    '대학 부설 또는 제휴 기관에서 영어와 전공 기초를 이수하며, 수료 성적을 충족하면 <mark>진학이 보장</mark>되는 과정이 많습니다. 보통 <mark>IELTS 5.0~5.5</mark>부터 시작할 수 있습니다.']
            },
            en: {
                t: 'What is a foundation year?',
                f: [['High school', '12 years in Korea'], ['Academic English', 'if required'], ['Foundation', '1 year'], ['Bachelor Year 1', 'at the university']],
                b: ['UK degrees assume <mark>13 years of schooling (A-levels)</mark>, so Korean high-school graduates usually take a <mark>one-year foundation</mark> before entering Year 1.',
                    'Run by the university or a partner provider, it combines English with academic subjects, and many programs <mark>guarantee progression</mark> on completion grades. Entry typically starts from around <mark>IELTS 5.0-5.5</mark>.']
            }
        },
        'uk-iyo': {
            ko: {
                t: 'IY1(International Year One)이란?',
                f: [['한국 고교 졸업', '12년제'], ['아카데믹 영어', '필요한 경우'], ['IY1', '1년'], ['학사 2학년', '남은 2년']],
                b: ['파운데이션이 학부 <mark>1학년 진입</mark>을 준비하는 과정이라면, IY1은 <mark>학부 1학년 과목 자체</mark>를 소규모 수업으로 이수하고 곧바로 <mark>2학년으로 올라가는</mark> 경로입니다.',
                    '직접 지원한 학생과 <mark>졸업 시점이 같아져</mark> 파운데이션보다 1년을 아낍니다. 대신 요구 성적과 영어가 조금 높고(보통 <mark>IELTS 5.5~6.0</mark>), 모든 대학·전공에 개설되지는 않아 <mark>경영·공학 계열</mark>에 집중돼 있습니다.']
            },
            en: {
                t: 'What is International Year One?',
                f: [['High school', '12 years in Korea'], ['Academic English', 'if required'], ['IYO', '1 year'], ['Bachelor Year 2', '2 years left']],
                b: ['Where a foundation year prepares you <mark>for Year 1</mark>, International Year One teaches <mark>the Year 1 subjects themselves</mark> in smaller classes and takes you straight <mark>into Year 2</mark>.',
                    'You <mark>graduate at the same time</mark> as direct-entry students, saving a year against the foundation route. Entry sits a little higher (around <mark>IELTS 5.5-6.0</mark>), and it is not offered everywhere, concentrating in <mark>business and engineering</mark>.']
            }
        },
        'pre-master': {
            ko: {
                t: '프리마스터(석사 준비 과정)란?',
                f: [['학사 학위', '한국 4년제'], ['프리마스터', '1~2학기'], ['석사 본과정', '1년제']],
                b: ['학점이나 전공 배경, 영어가 석사 직접 지원 기준에 <mark>조금 못 미칠 때</mark> 거치는 과정입니다. 전공 기초와 학술 영어, 논문 작성법을 이수한 뒤 <mark>석사 본과정으로 진입</mark>합니다.',
                    '수료 기준을 충족하면 <mark>진학이 보장</mark>되는 과정이 많고, <mark>전공을 바꿀 때</mark>의 전환 경로로도 쓰입니다. 학점이 4.5 만점에 <mark>3.0 미만</mark>이거나 비전공자라면 우선 검토할 만합니다.']
            },
            en: {
                t: "What is a pre-master's course?",
                f: [['Bachelor degree', 'from Korea'], ["Pre-master's", '1-2 terms'], ["Master's", '1 year']],
                b: ["A bridge for applicants whose GPA, subject background or English sits <mark>just below</mark> direct master's entry. You cover subject fundamentals, academic English and dissertation skills, then <mark>move into the master's</mark>.",
                    'Many programs <mark>guarantee progression</mark> on completion, and it doubles as a <mark>conversion route</mark> when you change field. Worth considering first if your GPA is <mark>below 3.0 out of 4.5</mark> or your degree is in another subject.']
            }
        },
        'ca-foundation': {
            ko: {
                t: '대학 자체 파운데이션(IFP)이란?',
                f: [['고교 졸업', '또는 동등 학력'], ['IFP', '8개월~1년'], ['학사 1학년', '본교 진학']],
                b: ['캐나다는 영국·호주 같은 <mark>전국 단위 파운데이션 제도가 없어</mark>, 대학이 자체적으로 운영하는 소수의 과정만 있습니다. 토론토대의 International Foundation Program이 대표적입니다.',
                    '<mark>영어와 학점 과목을 병행</mark>해 이수하고, 수료 기준을 충족하면 <mark>본교 1학년</mark>으로 진학합니다. 자리가 제한적이라 경쟁이 있고, 학비도 학부 수준에 가깝습니다.']
            },
            en: {
                t: 'What is a university foundation (IFP)?',
                f: [['High school', 'graduate'], ['IFP', '8-12 months'], ['Bachelor Year 1', 'at the university']],
                b: ['Canada has <mark>no nationwide foundation system</mark> like the UK or Australia, so only a handful of universities run their own. The University of Toronto International Foundation Program is the best known.',
                    'You take <mark>English alongside credit courses</mark> and move into <mark>Year 1</mark> on meeting the completion grades. Places are limited and competitive, and fees sit close to undergraduate level.']
            }
        },
        'ca-ossd': {
            ko: {
                t: '캐나다 국제 사립학교를 통한 진학이란?',
                f: [['한국 고교', '2학년~졸업'], ['국제 사립학교', 'OSSD 학점 1~2년'], ['학사 1학년', 'UofT · UBC 등']],
                b: ['토론토 등지의 인가 사립학교에서 <mark>온타리오 고교 졸업장(OSSD)</mark> 학점을 이수하고, <mark>캐나다 내신</mark>으로 대학에 지원하는 경로입니다. 대학이 캐나다 성적표를 그대로 읽기 때문에 한국 학생이 <mark>UofT·UBC</mark>에 닿는 대표 루트입니다.',
                    'OSSD는 단일 시험이 아니라 <mark>학점 누적</mark> 방식이라 꾸준한 과제·출석이 성적을 만듭니다. <mark>12학년 학점</mark> 비중이 커서 <mark>11학년</mark>에 진입하면 여유가 생기고, 입학 시 IELTS 없이 ESL을 병행할 수 있습니다.']
            },
            en: {
                t: 'Studying at a Canadian international private school',
                f: [['Korean high school', 'Year 2 to graduate'], ['Private school', 'OSSD credits, 1-2 years'], ['Bachelor Year 1', 'UofT, UBC and more']],
                b: ['You earn <mark>Ontario Secondary School Diploma (OSSD)</mark> credits at a licensed private school in Toronto and apply with <mark>Canadian grades</mark>. Universities read a Canadian transcript directly, which is why this is the usual route into <mark>UofT and UBC</mark>.',
                    'OSSD is <mark>credit-based</mark> rather than exam-based, so steady coursework and attendance build the grade. <mark>Grade 12 credits</mark> carry the most weight, so entering by <mark>grade 11</mark> gives you room, and ESL runs alongside without an IELTS score at entry.']
            }
        },
        'ca-pathway': {
            ko: {
                t: '패스웨이 컬리지 편입이란?',
                f: [['고교 졸업', '또는 동등 학력'], ['아카데믹 영어', '필요한 경우'], ['UTP 1학년', '8~12개월'], ['학사 2학년', '본교 편입']],
                b: ['FIC(SFU)·ICM(매니토바)처럼 <mark>대학 캠퍼스 안</mark>에 있는 패스웨이 컬리지에서 학부 1학년 과정(UTP)을 소규모 수업으로 이수하고, 기준 성적을 충족하면 <mark>본교 2학년으로 편입</mark>합니다.',
                    '직접 입학보다 낮은 성적과 영어(보통 <mark>IELTS 5.5</mark>)로 시작할 수 있고, 수업은 본교와 같은 캠퍼스에서 진행됩니다.']
            },
            en: {
                t: 'What is a pathway-college transfer?',
                f: [['High school', 'graduate'], ['Academic English', 'if required'], ['UTP Year 1', '8-12 months'], ['Bachelor Year 2', 'transfer in']],
                b: ['Pathway colleges such as FIC (SFU) and ICM (Manitoba) sit <mark>on the university campus</mark> and teach first-year courses (UTP) in smaller classes; meet the grade threshold and you <mark>transfer into Year 2</mark>.',
                    'Entry starts with lower grades and English (around <mark>IELTS 5.5</mark>) than direct admission, and classes run on the same campus as the university.']
            }
        },
        'us-pathway': {
            ko: {
                t: '미국 패스웨이(조건부입학)란?',
                f: [['고교 졸업', '또는 동등 학력'], ['패스웨이 1년', '영어+전공기초 20~24학점'], ['학사 2학년', '본교 진학'], ['학사 학위', '총 4년']],
                b: ['대학 캠퍼스 안에서 영어와 <mark>학점이 인정되는 1학년 과목</mark>을 함께 듣고, 조건을 충족하면 <mark>그 대학 2학년</mark>으로 올라갑니다. 1학년을 대체하는 방식이라 <mark>학위 기간은 4년 그대로</mark>입니다.',
                    '<mark>SAT 없이</mark> 지원할 수 있고 영어도 <mark>IELTS 5.5</mark> 내외부터 시작합니다. Shorelight·INTO·Kaplan이 운영하며, 어학만 듣는 <mark>조건부 입학과는 다릅니다</mark>(그쪽은 학점이 없어 기간이 늘어납니다).']
            },
            en: {
                t: 'What is a US pathway?',
                f: [['High school', 'graduate'], ['Pathway year', 'English + 20-24 credits'], ['Bachelor Year 2', 'same university'], ['Bachelor degree', 'four years total']],
                b: ['You study on the university campus, taking English alongside <mark>credit-bearing first-year courses</mark>, and move into <mark>Year 2 of that university</mark> once you meet the condition. It replaces first year, so the degree still takes <mark>four years in total</mark>.',
                    'You can apply <mark>without an SAT</mark> and start from around <mark>IELTS 5.5</mark>. Shorelight, INTO and Kaplan run these. It is <mark>not the same as conditional admission</mark>, where the English course carries no credit and adds time to the degree.']
            }
        },
        'us-transfer': {
            ko: {
                t: '커뮤니티칼리지 2+2 편입이란?',
                f: [['고교 졸업', '또는 동등 학력'], ['커뮤니티칼리지', '2년 · 60학점'], ['4년제 3학년', '편입'], ['학사 학위', '총 4년']],
                b: ['2년제 <mark>커뮤니티칼리지</mark>에서 교양과 전공기초 60학점을 채우고 <mark>4년제 3학년으로 편입</mark>합니다. 학위는 편입한 4년제 이름으로 나오고 <mark>총 기간도 4년 그대로</mark>입니다.',
                    '네 경로 중 <mark>입학 문턱이 가장 낮습니다</mark>. SAT가 필요 없고 영어는 <mark>IELTS 4.5~6.0</mark> 선이며, 점수가 없으면 부설 어학과정부터 시작할 수 있습니다. 학비도 4년제의 절반 이하라 <mark>첫 2년 비용이 크게 줄고</mark>, 캘리포니아에서는 <mark>UC TAG</mark>로 데이비스·어바인 등 6개 캠퍼스 편입 보장을 신청할 수 있습니다.']
            },
            en: {
                t: 'What is a community college transfer?',
                f: [['High school', 'graduate'], ['Community college', '2 years, 60 credits'], ['Bachelor Year 3', 'transfer in'], ['Bachelor degree', 'four years total']],
                b: ['You take 60 credits of general education and prerequisites at a two-year <mark>community college</mark>, then <mark>transfer into Year 3</mark> of a four-year university. The degree carries the four-year university name and still takes <mark>four years in total</mark>.',
                    'This is the <mark>lowest entry bar</mark> of the four routes. No SAT is needed, English sits around <mark>IELTS 4.5-6.0</mark>, and with no score at all you can start in the college intensive English program. Tuition is under half a four-year university, so the <mark>first two years cost far less</mark>. In California, <mark>UC TAG</mark> guarantees transfer to six campuses including Davis and Irvine.']
            }
        }
    };
    // 경로 키 → 국가별 전체 가이드 페이지
    var PW_GUIDE_PAGE = { 'au-foundation': '../guide/au.html', 'au-diploma': '../guide/au.html', 'uk-foundation': '../guide/uk.html', 'uk-iyo': '../guide/uk.html', 'pre-master': '../guide/uk.html', 'ca-ossd': '../guide/ca.html', 'ca-foundation': '../guide/ca.html', 'ca-pathway': '../guide/ca.html', 'us-pathway': '../guide/us.html', 'us-transfer': '../guide/us.html#cc' };
    function openPwGuide(key) {
        var g = PW_GUIDES[key]; if (!g) return;
        var c = g[LANG] || g.ko;
        document.getElementById('pw-guide-title').textContent = c.t;
        document.getElementById('pw-guide-flow').innerHTML = (c.f || []).map(function (s) {
            return '<li class="flow-step">' + s[0] + '<span>' + s[1] + '</span></li>';
        }).join('');
        document.getElementById('pw-guide-body').innerHTML = c.b.map(function (p) { return '<p>' + p + '</p>'; }).join('');
        document.getElementById('pw-guide-cta').textContent = LANG === 'en' ? 'Take the 3-minute quiz →' : '3분 진단 하러 가기 →';
        var more = document.getElementById('pw-guide-more');
        if (PW_GUIDE_PAGE[key]) {
            more.href = PW_GUIDE_PAGE[key];
            more.textContent = LANG === 'en' ? 'Read the full guide' : '전체 가이드 보기';
            more.hidden = false;
        } else {
            more.hidden = true;
        }
        document.getElementById('pw-guide').hidden = false;
        document.body.style.overflow = 'hidden';
    }
    function closePwGuide() {
        document.getElementById('pw-guide').hidden = true;
        document.body.style.overflow = '';
    }
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape') closePwGuide(); });
    document.getElementById('pw-guide').addEventListener('click', function (e) { if (e.target === this) closePwGuide(); });
    </script>

    <!-- 언어 전환 — data-en 속성에 영어 문구를 심어 두고 통째로 스왑한다 (허브와 같은 키 sgh-lang 공유) -->
    <script>
    var LANG = 'ko';
    try { if (localStorage.getItem('sgh-lang') === 'en') LANG = 'en'; } catch (e) {}
    function applyLang() {
        document.documentElement.lang = LANG;
        document.title = LANG === 'en' ? '{{NAME_EN}} | Study Guide Hub' : '{{NAME_KO}} ({{NAME_EN}}) | Study Guide Hub';
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
        renderKrw();
    }
    function setLang(l) {
        LANG = l;
        try { localStorage.setItem('sgh-lang', l); } catch (e) {}
        applyLang();
    }
    </script>

    <!-- 원화 환산 — 조회 시점의 환율을 받아 학비 옆에 표시. 실패하면 조용히 생략 -->
    <script>
    var FX_RATE = null;
    function renderKrw() {
        if (!FX_RATE) return;
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
        document.querySelectorAll('.krw').forEach(function (el) {
            var min = parseFloat(el.getAttribute('data-min'));
            var max = parseFloat(el.getAttribute('data-max'));
            if (isNaN(min) && isNaN(max)) return;
            if (isNaN(min)) min = max;
            if (isNaN(max)) max = min;
            var range = min === max ? fmt(min) : (en ? fmt(min) + ' ~ ' + fmt(max) : fmt(min).replace(' 원', '') + '~' + fmt(max));
            el.textContent = (en ? 'approx. ' : '약 ') + range;
        });
        var today = new Date();
        var dateNote = en
            ? 'Rate as of ' + today.toLocaleDateString('en-GB', { year: 'numeric', month: 'short', day: 'numeric' })
            : today.getFullYear() + '. ' + (today.getMonth() + 1) + '. ' + today.getDate() + '. 환율 기준';
        document.querySelectorAll('.fx-date').forEach(function (el) { el.textContent = dateNote; });
    }
    fetch('https://open.er-api.com/v6/latest/{{CURRENCY}}')
        .then(function (r) { return r.json(); })
        .then(function (d) {
            FX_RATE = d && d.rates && d.rates.KRW;
            renderKrw();
        })
        .catch(function () {});
    applyLang();
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
    <title>{{CN_KO}} {{CN_NOUN}} 안내 | Study Guide Hub</title>
    <meta name="description" content="{{CN_KO}} {{CN_NOUN}} {{COUNT}}곳의 학비·IELTS 기준·진학 경로를 한눈에 비교하세요. 공식 요강 기준 무료 정보 가이드.">
    <link rel="canonical" href="{{SITE}}uni/{{LIST_PATH}}">
    <meta property="og:type" content="website">
    <meta property="og:site_name" content="Study Guide Hub">
    <meta property="og:title" content="{{CN_KO}} {{CN_NOUN}} {{COUNT}}곳 안내 | Study Guide Hub">
    <meta property="og:description" content="{{CN_KO}} {{CN_NOUN}} {{COUNT}}곳의 학비·IELTS 기준·진학 경로를 한눈에 비교하세요. 공식 요강 기준 무료 정보 가이드.">
    <meta property="og:url" content="{{SITE}}uni/{{LIST_PATH}}">
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
        .lang-switch { display: inline-flex; border: 1px solid var(--line); border-radius: 999px; overflow: hidden; flex-shrink: 0; }
        .lang-switch button {
            border: 0; background: transparent; color: var(--mute); cursor: pointer;
            font-family: inherit; font-size: 11.5px; font-weight: 700; letter-spacing: 0.02em; padding: 6px 11px;
        }
        .lang-switch button:hover { color: var(--text); }
        .lang-switch button.on { background: var(--text); color: var(--bg); }

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
        .filter-row { display: flex; flex-wrap: wrap; align-items: center; gap: 8px; margin-top: 12px; }
        .filter-cap { font-size: 13px; font-weight: 600; color: var(--mute); margin-right: 2px; }
        .filter-btn { min-height: 38px; padding: 0 14px; font-size: 13px; }
        .filter-btn[aria-pressed="true"] { background: var(--accent); color: var(--accent-text); border-color: var(--accent); }
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
        /* 다크 모드는 흰 실루엣 반전 대신 밝은 플레이트 (상세 페이지와 동일 규칙) */
        :root[data-theme="dark"] .card-logo {
            background: #f2f2f4; border-radius: 8px; padding: 5px 7px; width: 84px; height: 46px;
        }
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
                <div class="lang-switch" role="group" aria-label="언어 선택" data-en-aria="Language">
                    <button type="button" data-lang="ko" class="on" onclick="setLang('ko')">KO</button>
                    <button type="button" data-lang="en" onclick="setLang('en')">EN</button>
                </div>
                <button type="button" class="theme-btn" aria-label="화면 모드 전환" data-en-aria="Switch appearance" title="밝게 / 어둡게" data-en-title="Light / dark" onclick="var r=document.documentElement,t=r.getAttribute('data-theme')==='dark'?'light':'dark';r.setAttribute('data-theme',t);try{localStorage.setItem('sgh-theme',t)}catch(e){}"></button>
                <a href="../index.html#contact" class="header-cta" data-en="Contact">상담 문의</a>
            </div>
        </div>
    </header>

    <main>
        <section class="list-hero">
            <div class="container">
                <p class="crumb" data-en="&lt;a href=&quot;../index.html&quot;&gt;Home&lt;/a&gt; › {{CN_EN}} {{CN_ENNOUN}}"><a href="../index.html">홈</a> › {{CN_KO}} {{CN_NOUN}}</p>
                <h1 data-en="{{COUNT}} {{CN_EN}} {{CN_ENNOUN}}">{{CN_KO}} {{CN_NOUN}} {{COUNT}}곳</h1>
                <p data-en="Tuition, IELTS requirements and entry routes, school by school. Select a university for details.">학비·IELTS 기준·진학 경로를 학교별로 정리했습니다. 학교를 눌러 상세 정보를 확인하세요.</p>

                <div class="toolbar">
                    <input type="search" class="search-box" id="q" placeholder="학교명 또는 도시 검색 (예: 맨체스터, London)" data-en-ph="Search by name or city (e.g. Manchester)" aria-label="학교 검색" data-en-aria="Search universities">
                    <div class="sort-group" role="group" aria-label="정렬 기준" data-en-aria="Sort by">
                        <button type="button" class="sort-btn" data-sort="qs" aria-pressed="true" data-en="QS rank">QS 순위</button>
                        <button type="button" class="sort-btn" data-sort="fee" aria-pressed="false" data-en="Lowest fees">학비 낮은 순</button>
                        <button type="button" class="sort-btn" data-sort="name" aria-pressed="false" data-en="Name">가나다순</button>
                    </div>
                </div>
                {{FILTERS}}
                <p class="result-count" id="count"></p>
            </div>
        </section>

        <div class="container">
            <div class="uni-grid" id="grid">
{{CARDS}}
            </div>
            <p class="empty is-hidden" id="empty" hidden data-en="No results. Try a different name.">검색 결과가 없습니다. 다른 이름으로 찾아보세요.</p>
        </div>
    </main>

    <footer class="site-footer">
        <div class="container">
            <p data-en="Sources: QS World University Rankings and official university publications (Verified: {{LAST_VERIFIED}})">출처: QS World University Rankings · 각 대학 공식 공시 자료 (정보 확인: {{LAST_VERIFIED}})</p>
            {{FEE_NOTE}}
            <p>© 2026 Study Guide Hub</p>
        </div>
    </footer>

    <script>
    var LANG = 'ko';
    try { if (localStorage.getItem('sgh-lang') === 'en') LANG = 'en'; } catch (e) {}
    var render;   // applyLang에서 재호출할 수 있게 밖으로 꺼내 둔다
    function applyLang() {
        document.documentElement.lang = LANG;
        document.title = LANG === 'en' ? '{{CN_EN}} {{CN_ENNOUN}} | Study Guide Hub' : '{{CN_KO}} {{CN_NOUN}} 안내 | Study Guide Hub';
        document.querySelectorAll('[data-en]').forEach(function (el) {
            if (!el.dataset.ko) el.dataset.ko = el.innerHTML;
            el.innerHTML = LANG === 'en' ? el.dataset.en : el.dataset.ko;
        });
        [['data-en-title', 'title'], ['data-en-aria', 'aria-label'], ['data-en-ph', 'placeholder'], ['data-en-alt', 'alt']].forEach(function (pair) {
            document.querySelectorAll('[' + pair[0] + ']').forEach(function (el) {
                var koAttr = pair[0] + '-ko';
                if (!el.hasAttribute(koAttr)) el.setAttribute(koAttr, el.getAttribute(pair[1]) || '');
                el.setAttribute(pair[1], el.getAttribute(LANG === 'en' ? pair[0] : koAttr));
            });
        });
        document.querySelectorAll('.lang-switch button').forEach(function (b) {
            b.classList.toggle('on', b.getAttribute('data-lang') === LANG);
        });
        if (render) render();
    }
    function setLang(l) {
        LANG = l;
        try { localStorage.setItem('sgh-lang', l); } catch (e) {}
        applyLang();
    }
    (function () {
        var grid = document.getElementById('grid');
        var cards = [].slice.call(grid.children);
        var q = document.getElementById('q');
        var count = document.getElementById('count');
        var empty = document.getElementById('empty');
        var sortKey = 'qs';
        var pwFilter = '';

        function num(el, attr) {
            var v = parseFloat(el.getAttribute(attr));
            return isNaN(v) ? Infinity : v;   // 값 없는 학교는 항상 뒤로
        }
        render = function () {
            var term = q.value.trim().toLowerCase();
            cards.sort(function (a, b) {
                if (sortKey === 'name') {
                    var attr = LANG === 'en' ? 'data-name-en' : 'data-name';
                    return a.getAttribute(attr).localeCompare(b.getAttribute(attr), LANG);
                }
                return num(a, 'data-' + sortKey) - num(b, 'data-' + sortKey);
            });
            var shown = 0;
            cards.forEach(function (c) {
                var hit = (!term || c.getAttribute('data-search').indexOf(term) > -1) &&
                    (!pwFilter || (' ' + (c.getAttribute('data-pw') || '') + ' ').indexOf(' ' + pwFilter + ' ') > -1);
                c.classList.toggle('is-hidden', !hit);
                if (hit) shown++;
                grid.appendChild(c);
            });
            count.textContent = LANG === 'en' ? shown + (shown === 1 ? ' school' : ' schools') : shown + '개 학교';
            empty.hidden = shown > 0;
        };
        q.addEventListener('input', render);
        document.querySelectorAll('.sort-btn:not(.filter-btn)').forEach(function (btn) {
            btn.addEventListener('click', function () {
                sortKey = btn.getAttribute('data-sort');
                document.querySelectorAll('.sort-btn:not(.filter-btn)').forEach(function (b) {
                    b.setAttribute('aria-pressed', String(b === btn));
                });
                render();
            });
        });
        // 경로 필터 — 하나만 선택, 다시 누르면 해제
        document.querySelectorAll('.filter-btn').forEach(function (btn) {
            btn.addEventListener('click', function () {
                var f = btn.getAttribute('data-f');
                pwFilter = (pwFilter === f) ? '' : f;
                document.querySelectorAll('.filter-btn').forEach(function (b) {
                    b.setAttribute('aria-pressed', String(b.getAttribute('data-f') === pwFilter));
                });
                render();
            });
        });
        applyLang();
    })();
    </script>
</body>
</html>
'@

# ---------- 생성 ----------
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$built = 0
$lists = @{}   # country → @{cards; count; latest}
$allIds = @()

$dataFiles = Get-ChildItem -Path (Join-Path $repoRoot 'data') -Filter 'universities-*.json' -File

# 1차 로딩 — related_ids가 다른 학교의 이름·로고를 참조할 수 있게 전체를 먼저 읽는다
$allUnis = @()
$UNI_INDEX = @{}
foreach ($file in $dataFiles) {
    $unis = Get-Content -Path $file.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($unis -isnot [System.Array]) { $unis = @($unis) }
    foreach ($u in $unis) { $allUnis += $u; $UNI_INDEX[$u.id] = $u }
}

# 로고 파일 경로 찾기 (없으면 null)
function Get-LogoRel([string]$id) {
    foreach ($ext in @('png', 'svg')) {
        $rel = 'images/uni/' + $id + '-logo.' + $ext
        if (Test-Path (Join-Path $repoRoot $rel)) { return $rel }
    }
    return $null
}

foreach ($nothing in @(1)) {
    foreach ($u in $allUnis) {
        $symbol   = if ($CURRENCY_SYMBOL.ContainsKey($u.currency)) { $CURRENCY_SYMBOL[$u.currency] } else { $u.currency + ' ' }
        $diagUrl  = if ($DIAG_URL.ContainsKey($u.country)) { $DIAG_URL[$u.country] } else { '../index.html' }
        $typeText = if ($TYPE_LABEL.ContainsKey($u.type)) { $TYPE_LABEL[$u.type] } else { $u.type }

        # 랭킹 뱃지 — 전공 순위를 종합 순위보다 강조
        $rankBadges = ''
        foreach ($sr in @($u.qs_subject_ranks)) {
            if ($null -ne $sr) {
                $srEn = 'QS #{0} worldwide in {1}' -f $sr.rank, (En $sr.subject)
                $rankBadges += ('<span class="rank-badge--subject" data-en="{2}">{0} QS 세계 {1}위</span>' -f (Esc $sr.subject), $sr.rank, (Esc $srEn))
            }
        }
        if ($null -ne $u.qs_rank) {
            $rankBadges += ('<span class="rank-badge--overall" data-en="QS World #{0}">QS 종합 {0}위</span>' -f $u.qs_rank)
        }

        # 핵심 수치 — 학부 학비가 없는 대학원 전용 학교는 석사 학비로 라벨을 바꿔 표시
        $tuitionUg = Fmt-Tuition $u.tuition_ug_min $u.tuition_ug_max $symbol
        $tuitionLabel = '<p class="stat-label" data-en="Annual tuition (UG)">연간 학비 (학부)</p>'
        $statMin = $u.tuition_ug_min; $statMax = $u.tuition_ug_max
        if ($null -eq $tuitionUg) {
            $tuitionUg = Fmt-Tuition $u.tuition_pg_min $u.tuition_pg_max $symbol
            $tuitionLabel = '<p class="stat-label" data-en="Annual tuition (PG)">연간 학비 (석사)</p>'
            $statMin = $u.tuition_pg_min; $statMax = $u.tuition_pg_max
        }
        $tuitionUgEn = ''
        if ($null -eq $tuitionUg) { $tuitionUg = '문의'; $tuitionUgEn = ' data-en="Enquire"' }
        $acceptedOther = @($u.english.accepted | Where-Object { $_ -ne 'ielts' } | ForEach-Object { $ENGLISH_LABEL[$_] })
        if ($acceptedOther.Count -gt 0) {
            $joined = $acceptedOther -join [char]0x00B7
            $acceptedSub = $joined + ' 인정'
            $acceptedSubEn = ' data-en="' + (Esc ('Also accepts ' + ((@($u.english.accepted | Where-Object { $_ -ne 'ielts' } | ForEach-Object { En $ENGLISH_LABEL[$_] })) -join [char]0x00B7))) + '"'
        } else {
            $acceptedSub = 'IELTS 기준'
            $acceptedSubEn = ' data-en="IELTS only"'
        }
        # 입학 시기 — "9월" 같은 한국어 월 표기를 영어 약칭으로
        $MONTH_EN = @{ '1월'='Jan';'2월'='Feb';'3월'='Mar';'4월'='Apr';'5월'='May';'6월'='Jun';'7월'='Jul';'8월'='Aug';'9월'='Sep';'10월'='Oct';'11월'='Nov';'12월'='Dec' }
        $intakesKo = (@($u.intakes)) -join ' &middot; '
        $intakesEn = (@($u.intakes) | ForEach-Object { if ($MONTH_EN.ContainsKey($_)) { $MONTH_EN[$_] } else { En $_ } }) -join ' &middot; '

        # 진학 경로 카드 — level(ug/pg)이 섞여 있으면 학사/석사 그룹으로 나눔
        $ugPaths = @($u.pathways | Where-Object { $null -ne $_ -and $_.level -ne 'pg' })
        $pgPaths = @($u.pathways | Where-Object { $null -ne $_ -and $_.level -eq 'pg' })
        $pathwayCards = ''
        if ($ugPaths.Count -gt 0 -and $pgPaths.Count -gt 0) {
            $pathwayCards += '<h3 class="pw-group" data-en="Undergraduate">학사 과정</h3>'
            foreach ($pw in $ugPaths) { $pathwayCards += New-PathwayCard $pw $diagUrl $u.country }
            $pathwayCards += '<h3 class="pw-group" data-en="Postgraduate">석사 과정</h3>'
            foreach ($pw in $pgPaths) { $pathwayCards += New-PathwayCard $pw $diagUrl $u.country }
        } else {
            foreach ($pw in @($u.pathways)) { if ($null -ne $pw) { $pathwayCards += New-PathwayCard $pw $diagUrl $u.country } }
        }

        # 학교 로고 — images/uni/{id}-logo.(png|svg) 파일이 있으면 학교명 우측에 표시
        $uniLogo = ''
        foreach ($ext in @('png', 'svg')) {
            $logoRel = 'images/uni/' + $u.id + '-logo.' + $ext
            if (Test-Path (Join-Path $repoRoot $logoRel)) {
                $uniLogo = '<img class="uni-logo" src="../' + $logoRel + '" alt="' + (Esc $u.name_ko) + ' 로고" data-en-alt="' + (Esc $u.name_en) + ' logo">'
                break
            }
        }

        # 배너 이미지 — images/uni/{id}.jpg가 있으면 학교 전용, 없으면 국가 공용 {국가코드}-banner.jpg
        $heroBanner = ''
        $bannerRel = 'images/uni/' + $u.id + '.jpg'
        if (-not (Test-Path (Join-Path $repoRoot $bannerRel))) {
            $bannerRel = 'images/uni/' + $u.country.ToLower() + '-banner.jpg'
        }
        if (Test-Path (Join-Path $repoRoot $bannerRel)) {
            $heroBanner = '<div class="hero-banner"><img src="../' + $bannerRel + '" alt="' + (Esc $u.name_ko) + ' 캠퍼스" data-en-alt="' + (Esc $u.name_en) + ' campus"></div>'
        }

        # 공식 유튜브 임베드 — youtube_id 없으면 섹션 자체를 생략
        $videoSection = ''
        if ($u.youtube_id) {
            $videoSection = @"

        <section>
            <div class="container">
                <h2 data-en="Campus tour">캠퍼스 둘러보기</h2>
                <div class="video-wrap"><iframe src="https://www.youtube-nocookie.com/embed/$($u.youtube_id)" title="$(Esc $u.name_ko) 공식 캠퍼스 영상" data-en-title="$(Esc $u.name_en) official campus video" loading="lazy" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></div>
                <p class="disclaimer" data-en="Source: the university's official YouTube channel">출처: 대학 공식 유튜브 채널</p>
            </div>
        </section>
"@
        }

        # 전공 태그 + 전공별 QS 순위
        $majorTags = (@($u.popular_majors) | ForEach-Object { '<span class="major-tag"' + (EnAttr $_ (En $_)) + '>' + (Esc $_) + '</span>' }) -join ''
        $subjectRankList = ''
        $srItems = ''
        foreach ($sr in @($u.qs_subject_ranks)) {
            if ($null -ne $sr) {
                $srKo = '{0}<span class="rank-chip">QS 전공 {1}위</span>' -f (Esc $sr.subject), $sr.rank
                $srEn = '{0}<span class="rank-chip">QS subject #{1}</span>' -f (Esc (En $sr.subject)), $sr.rank
                $srItems += '<li' + (EnAttr $srKo $srEn) + '>' + $srKo + '</li>'
            }
        }
        if ($srItems) { $subjectRankList = '<ul class="subject-ranks">' + $srItems + '</ul>' }

        # 학비·요건 표
        $rows = ''
        $ugText = Fmt-Tuition $u.tuition_ug_min $u.tuition_ug_max $symbol
        $pgText = Fmt-Tuition $u.tuition_pg_min $u.tuition_pg_max $symbol
        if ($ugText) { $rows += '<tr><th data-en="UG annual tuition">학부 연간 학비</th><td>' + $ugText + ' <small class="krw" data-min="' + $u.tuition_ug_min + '" data-max="' + $u.tuition_ug_max + '"></small></td></tr>' }
        if ($pgText) { $rows += '<tr><th data-en="PG annual tuition">석사 연간 학비</th><td>' + $pgText + ' <small class="krw" data-min="' + $u.tuition_pg_min + '" data-max="' + $u.tuition_pg_max + '"></small></td></tr>' }
        $ieltsKo = 'IELTS ' + (Fmt-Ielts $u.english.ielts_min)
        $ieltsEn = $ieltsKo
        if ($u.english.note) {
            $ieltsEn = $ieltsKo + ' (' + (Esc (En $u.english.note)) + ')'
            $ieltsKo += ' (' + (Esc $u.english.note) + ')'
        }
        $rows += '<tr><th data-en="Minimum English">영어 최소 기준</th><td' + (EnAttr $ieltsKo $ieltsEn) + '>' + $ieltsKo + '</td></tr>'
        $acceptedAllKo = (@($u.english.accepted | ForEach-Object { $ENGLISH_LABEL[$_] })) -join ([string][char]0x00B7)
        $acceptedAllEn = (@($u.english.accepted | ForEach-Object { En $ENGLISH_LABEL[$_] })) -join ([string][char]0x00B7)
        $rows += '<tr><th data-en="Accepted English tests">인정 영어 시험</th><td' + (EnAttr $acceptedAllKo $acceptedAllEn) + '>' + $acceptedAllKo + '</td></tr>'
        $rows += '<tr><th data-en="Intakes">입학 시기</th><td' + (EnAttr $intakesKo $intakesEn) + '>' + $intakesKo + '</td></tr>'

        # 비어 있으면 렌더링하지 않는 섹션
        $editorSection = ''
        if ($u.editor_note) {
            $editorSection = @"

        <section>
            <div class="container">
                <h2 data-en="Editor's note">에디터 노트</h2>
                <div class="editor-note"$(EnAttr $u.editor_note (En $u.editor_note))>$(Esc $u.editor_note)</div>
            </div>
        </section>
"@
        }
        $relatedSection = ''
        if (@($u.related_ids).Count -gt 0 -and $null -ne $u.related_ids) {
            # id 나열 대신 로고 + 한국어명 + 영문명 카드로 표시
            $links = (@($u.related_ids) | ForEach-Object {
                $r = $UNI_INDEX[$_]
                if ($null -eq $r) { return }
                $logoRel = Get-LogoRel $r.id
                $logoHtml = if ($logoRel) { '<img src="../' + $logoRel + '" alt="' + (Esc $r.name_ko) + ' 로고" data-en-alt="' + (Esc $r.name_en) + ' logo" loading="lazy">' } else { '' }
                '<a class="related-card" href="./' + $r.id + '.html">' + $logoHtml +
                '<span class="related-names"><span class="related-ko"' + (EnAttr $r.name_ko (Esc $r.name_en)) + '>' + (Esc $r.name_ko) + '</span>' +
                '<span class="related-en"' + (EnAttr $r.name_en (Esc $r.name_ko)) + '>' + (Esc $r.name_en) + '</span></span></a>'
            }) -join ''
            if ($links) {
                $relatedSection = @"

        <section>
            <div class="container">
                <h2 data-en="Related universities">함께 보면 좋은 대학</h2>
                <div class="related-links">$links</div>
            </div>
        </section>
"@
            }
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
            '{{CITY_BADGE}}'          = '<span class="meta-badge"' + (EnAttr $u.city (En $u.city)) + '>' + (Esc $u.city) + '</span>'
            '{{TYPE_BADGE}}'          = '<span class="meta-badge"' + (EnAttr $typeText (En $typeText)) + '>' + (Esc $typeText) + '</span>'
            '{{RANK_BADGES}}'         = $rankBadges
            '{{DIAG_URL}}'            = $diagUrl
            '{{OFFICIAL_URL}}'        = Esc $u.official_url
            '{{TUITION_LABEL}}'       = $tuitionLabel
            '{{TUITION_UG}}'          = $tuitionUg
            '{{TUITION_UG_EN}}'       = $tuitionUgEn
            '{{IELTS_MIN}}'           = Fmt-Ielts $u.english.ielts_min
            '{{ACCEPTED_SUB}}'        = $acceptedSub
            '{{ACCEPTED_SUB_EN}}'     = $acceptedSubEn
            '{{INTAKES}}'             = $intakesKo
            '{{INTAKES_EN}}'          = (EnAttr $intakesKo $intakesEn)
            '{{PATHWAY_COUNT}}'       = [string](@($u.pathways).Count)
            '{{PATHWAY_CARDS}}'       = $pathwayCards
            '{{MAJOR_TAGS}}'          = $majorTags
            '{{SUBJECT_RANK_LIST}}'   = $subjectRankList
            '{{FACT_ROWS}}'           = $rows
            '{{LAST_VERIFIED}}'       = Esc $u.last_verified
            '{{MAP_QUERY}}'           = [uri]::EscapeDataString($u.name_en + ', ' + $u.city)
            '{{CURRENCY}}'            = Esc $u.currency
            '{{UG_MIN}}'              = [string]$statMin
            '{{UG_MAX}}'              = [string]$statMax
            '{{UNI_LOGO}}'            = $uniLogo
            '{{HERO_BANNER}}'         = $heroBanner
            '{{VIDEO_SECTION}}'       = $videoSection
            '{{EDITOR_NOTE_SECTION}}' = $editorSection
            '{{RELATED_SECTION}}'     = $relatedSection
            '{{FEE_NOTE}}'            = if ($u.country -eq 'US' -and $u.type -eq 'college') { $FEE_NOTE_US_CC }
                                        elseif ($FEE_NOTE.ContainsKey($u.country)) { $FEE_NOTE[$u.country] }
                                        else { $FEE_NOTE_DEFAULT }
        }
        foreach ($key in $tokens.Keys) { $html = $html.Replace($key, [string]$tokens[$key]) }

        $outPath = Join-Path $outDir ($u.id + '.html')
        [IO.File]::WriteAllText($outPath, $html, $utf8NoBom)
        Write-Host ("생성: uni\{0}.html" -f $u.id) -ForegroundColor Green
        $built++

        # ---- 목록 페이지용 카드 ----
        $cardLogo = if ($uniLogo) { $uniLogo.Replace('class="uni-logo"', 'class="card-logo"').Replace('src="../', 'src="../') } else { '<span></span>' }
        $qsBadge = if ($null -ne $u.qs_rank) {
            '<span class="qs-badge" data-en="QS #' + $u.qs_rank + '">QS ' + $u.qs_rank + '위</span>'
        } else {
            '<span class="qs-badge is-unranked" data-en="Outside QS top 200">QS 200위권 밖</span>'
        }
        $sortFee = if ($null -ne $u.tuition_ug_min) { $u.tuition_ug_min } elseif ($null -ne $u.tuition_pg_min) { $u.tuition_pg_min } else { '' }
        # 경로 필터 토큰 — pathways[].type + 학교 type. 영국은 파운데이션·IYO 둘 다 없으면 Direct 전용.
        $pwTok = @($u.pathways | ForEach-Object { $_.type }) + @('type-' + $u.type)
        if ($u.country -eq 'UK' -and $pwTok -notcontains 'foundation' -and $pwTok -notcontains 'iyo') { $pwTok += 'direct-only' }
        $pwAttr = (@($pwTok) | Sort-Object -Unique) -join ' '
        $searchKey = ($u.name_ko + ' ' + $u.name_en + ' ' + $u.city).ToLower()
        $feeEnVal = if ($tuitionUgEn) { 'Enquire' } else { $tuitionUg }
        if (-not $lists.ContainsKey($u.country)) { $lists[$u.country] = @{ cards = ''; count = 0; latest = '' } }
        $lists[$u.country].cards += @"
                <a class="uni-card" href="./$($u.id).html" data-qs="$($u.qs_rank)" data-fee="$sortFee" data-name="$(Esc $u.name_ko)" data-name-en="$(Esc $u.name_en)" data-search="$(Esc $searchKey)" data-pw="$pwAttr">
                    <div class="card-top">$cardLogo$($qsBadge)</div>
                    <h2 data-en="$(Esc $u.name_en)">$(Esc $u.name_ko)</h2>
                    <p class="card-en" data-en="$(Esc $u.name_ko)">$(Esc $u.name_en)</p>
                    <div class="card-meta">
                        <span$(EnAttr $u.city (En $u.city))>$(Esc $u.city)</span>
                        <span data-en="Fees <b>$feeEnVal</b>">학비 <b>$tuitionUg</b></span>
                        <span>IELTS <b>$(Fmt-Ielts $u.english.ielts_min)</b></span>
                    </div>
                    <span class="card-go" data-en="View details &rarr;">자세히 보기 &rarr;</span>
                </a>

"@
        $lists[$u.country].count++
        $allIds += $u.id
        if ($u.last_verified -gt $lists[$u.country].latest) { $lists[$u.country].latest = $u.last_verified }
    }
}

# ---------- 국가별 목록 페이지 ----------
$listLocs = @()
foreach ($cc in $lists.Keys) {
    $info = $COUNTRY_INFO[$cc]
    if (-not $info) { $info = @{ ko = $cc; enAdj = $cc; file = ($cc.ToLower() + '.html') } }
    $listPath = if ($info.file -eq 'index.html') { '' } else { $info.file }   # canonical: index.html은 uni/
    $l = $lists[$cc]
    $listHtml = $LIST_TEMPLATE.Replace('{{FILTERS}}', (New-FilterChips $cc)).
        Replace('{{CARDS}}', $l.cards).Replace('{{COUNT}}', [string]$l.count).Replace('{{CN_NOUN}}', $info.noun).Replace('{{CN_ENNOUN}}', $info.enNoun).
        Replace('{{LAST_VERIFIED}}', $l.latest).Replace('{{SITE}}', $SITE).
        Replace('{{CN_KO}}', $info.ko).Replace('{{CN_EN}}', $info.enAdj).Replace('{{LIST_PATH}}', $listPath).
        Replace('{{FEE_NOTE}}', $(if ($cc -eq 'US') { $FEE_NOTE['US'] + $FEE_NOTE_US_LIST }
                                  elseif ($FEE_NOTE.ContainsKey($cc)) { $FEE_NOTE[$cc] }
                                  else { $FEE_NOTE_DEFAULT }))
    [IO.File]::WriteAllText((Join-Path $outDir $info.file), $listHtml, $utf8NoBom)
    $listLocs += ('uni/' + $listPath)
    Write-Host ("생성: uni\{0} ({1} 목록 {2}곳)" -f $info.file, $cc, $l.count) -ForegroundColor Green
}

# ---------- sitemap.xml / robots.txt ----------
$locs = @('', 'privacy.html', 'guide/uk.html', 'guide/au.html', 'guide/ca.html', 'guide/us.html') + $listLocs + ($allIds | ForEach-Object { 'uni/' + $_ + '.html' })
$sitemap = '<?xml version="1.0" encoding="UTF-8"?>' + "`n" +
           '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' + "`n" +
           (($locs | ForEach-Object { '  <url><loc>' + $SITE + $_ + '</loc></url>' }) -join "`n") + "`n" +
           '</urlset>' + "`n"
[IO.File]::WriteAllText((Join-Path $repoRoot 'sitemap.xml'), $sitemap, $utf8NoBom)
[IO.File]::WriteAllText((Join-Path $repoRoot 'robots.txt'), "User-agent: *`nAllow: /`nSitemap: ${SITE}sitemap.xml`n", $utf8NoBom)
Write-Host ("생성: sitemap.xml ({0}개 URL) + robots.txt" -f $locs.Count) -ForegroundColor Green

Write-Host ''
Write-Host "완료 — 상세 페이지 ${built}개 + 목록 페이지 1개 생성" -ForegroundColor Cyan

# ---------- 번역 누락 보고 ----------
if ($missing.Count -gt 0) {
    $missPath = Join-Path $repoRoot 'data\i18n-uni-missing.txt'
    [IO.File]::WriteAllLines($missPath, [string[]]$missing.Keys, $utf8NoBom)
    Write-Host ("번역 누락 {0}건 → data\i18n-uni-missing.txt (i18n-uni.json에 추가할 것)" -f $missing.Count) -ForegroundColor Yellow
} elseif (Test-Path (Join-Path $repoRoot 'data\i18n-uni-missing.txt')) {
    Remove-Item (Join-Path $repoRoot 'data\i18n-uni-missing.txt')
    Write-Host '번역 누락 0건' -ForegroundColor Green
}
