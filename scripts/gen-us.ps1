# data\us-source.tsv + data\us-urls.tsv -> data\universities-us.json
# 사용법:  powershell -ExecutionPolicy Bypass -File scripts\gen-us.ps1
# 순위·IELTS·도시는 topuniversities.com 각 학교 프로필(QS 2027)에서 수집한 값이다.
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot

$PROVIDER = @{
    'shorelight' = 'Shorelight'
    'into'       = 'INTO'
    'kaplan'     = 'Kaplan International Pathways'
}
$PW_NOTE = @{
    'shorelight' = '조건부 입학 후 2학년 진학 · 세부 요건은 상담으로 확인'
    'into'       = '조건부 입학 후 2학년 진학 · 세부 요건은 상담으로 확인'
    'kaplan'     = '학위 준비 과정 경유 · 세부 요건은 상담으로 확인'
}

# 공식 입학처 페이지로 직접 확인한 학교만 상세 값을 덮어쓴다 (나머지는 QS 프로필 값)
$OVERRIDE = @{
    'us-stony-brook' = @{
        accepted = @('ielts','toefl','pte','duolingo')
        engNote  = 'IELTS 6.5 · TOEFL 80 · 듀오링고 105 · PTE 53 · 수능 영어 1등급도 요건 충족으로 인정'
        # humanizer 적용 샘플(2026-08): 직접 상담하듯 말하는 톤. 나머지 노트도 이 톤으로 맞출 것
        note     = '조건부입학으로 갈 수 있는 학교 중에서는 순위가 가장 높습니다. US News 전국 59위. 그리고 수능 영어 1등급을 공인 성적 대신 받아주는 몇 안 되는 미국 대학이라, 아직 토플 점수가 없는 학생이 시간을 버는 카드로 자주 씁니다.'
        direct   = '미국 고교 3년 이상 재학자는 영어 성적 면제 · 수능 영어 1등급 인정'
    }
    'us-utah' = @{
        accepted = @('ielts','toefl','duolingo')
        engNote  = 'IELTS 6.5 · TOEFL 80 · 듀오링고 110 · 성적은 지원 시점 기준 2년 이내여야 합니다'
        note     = 'US News 전국 151위(Shorelight 공시). 게임 개발 전공이 미국 최상위권으로 꼽히고, 솔트레이크시티 IT 클러스터와 가까워 인턴 기회가 많습니다.'
    }
    'us-ucf' = @{
        accepted = @('ielts','toefl','duolingo')
        engNote  = 'IELTS 6.5 · TOEFL 80(2026년 1월 이전 척도) 또는 4(신척도) · 듀오링고 120'
        note     = 'US News 전국 117위(Shorelight 공시). 재학생 7만 명대로 미국에서 가장 큰 대학 중 하나이고, 로젠 호스피탈리티 스쿨과 광공학(CREOL)이 강합니다.'
        direct   = '지원 마감 가을 3월 1일 · 봄 9월 1일 · 여름 1월 1일'
        intakes  = @('8월','1월','5월')
    }
    'us-asu' = @{
        accepted = @('ielts','toefl','pte','duolingo','cambridge')
        engNote  = '일반 전공 IELTS 6.0 · TOEFL 61 · 듀오링고 95 · PTE 53 · 케임브리지 170 / 간호·공학 6.5, 저널리즘 7.0'
        note     = "US News '가장 혁신적인 대학' 1위를 여러 해 지켜온 학교입니다. 이 목록에서 QS 순위가 가장 높으면서 영어 요건은 IELTS 6.0으로 낮은 편이라 패스웨이 경로로 많이 갑니다."
        direct   = '전공별 요건 상이 · 간호·공학 IELTS 6.5, 크롱카이트 저널리즘 7.0'
    }
    'us-uic'     = @{ note = 'US News 전국 84위(Shorelight 공시). 시카고 유일의 공립 연구중심대학이고 간호·보건 계열이 강합니다.' }
    'us-american'= @{ note = 'US News 전국 88위(Shorelight 공시). 워싱턴 D.C.에 있어 국제관계·정치 전공의 인턴 연계가 강점입니다.' }
    'us-auburn'  = @{ note = 'US News 전국 102위(Shorelight 공시). 공학·건축이 강한 남부의 대형 주립대입니다.' }
}

function UrlMap {
    $m = @{}
    foreach ($line in Get-Content (Join-Path $repoRoot 'data\us-urls.tsv') -Encoding UTF8) {
        if (-not $line.Trim()) { continue }
        $p = $line -split "`t"
        $m[$p[0].Trim()] = $p[1].Trim()
    }
    return $m
}

$urls = UrlMap

# 학비 — 미국 교육부 College Scorecard(2026-06판) 공시. 사립은 주내=주외, 주립은 주외 요율을 쓴다.
# 열: id, out_of_state, in_state, control(1=공립 2=사립 3=사립영리), 학교명, 도시
$TUITION = @{}
$tuPath = Join-Path $repoRoot 'data\us-tuition.tsv'
if (Test-Path $tuPath) {
    foreach ($line in Get-Content $tuPath -Encoding UTF8) {
        if (-not $line.Trim()) { continue }
        $p = $line -split "`t"
        if ($p[1] -match '^\d+$') { $TUITION[$p[0].Trim()] = [int]$p[1] }
    }
}
Write-Host ("학비 데이터: {0}곳" -f $TUITION.Count)
$rows = Get-Content (Join-Path $repoRoot 'data\us-source.tsv') -Encoding UTF8 | Where-Object { $_.Trim() }
$header = $rows[0] -split "`t"
$list = New-Object System.Collections.Generic.List[object]
$missingUrl = @()

foreach ($line in $rows[1..($rows.Count-1)]) {
    $c = $line -split "`t"
    $id = $c[0].Trim()
    $ov = $OVERRIDE[$id]

    $url = $urls[$id]
    if (-not $url) { $missingUrl += $id; continue }

    $qs = $null
    if ($c[4] -and $c[4].Trim()) { $qs = [int]$c[4].Trim() }

    $accepted = if ($ov -and $ov.accepted) { $ov.accepted } else { @('ielts','toefl') }
    $engNote  = if ($ov -and $ov.engNote)  { $ov.engNote }  else { $null }
    $intakes  = if ($ov -and $ov.intakes)  { $ov.intakes }  else { @('8월','1월') }
    $ielts    = [double]$c[5].Trim()

    $pathways = New-Object System.Collections.Generic.List[object]
    $pathways.Add([ordered]@{
        type = 'direct'; level = 'ug'; provider = $null; ielts_min = $ielts
        duration = '4년'; cost_note = $null
        note = if ($ov -and $ov.direct) { $ov.direct } else { $null }
    })
    $prov = if ($c.Count -gt 7) { $c[7].Trim() } else { '' }
    if ($prov) {
        $pathways.Add([ordered]@{
            type = 'pathway'; level = 'ug'; provider = $PROVIDER[$prov]; ielts_min = $null
            duration = '1년'; cost_note = $null; note = $PW_NOTE[$prov]
        })
    }

    $list.Add([ordered]@{
        id               = $id
        type             = 'university'
        name_ko          = $c[2].Trim()
        name_en          = $c[1].Trim()
        country          = 'US'
        city             = $c[3].Trim()
        qs_rank          = $qs
        qs_subject_ranks = @()
        tuition_ug_min   = $(if ($TUITION.ContainsKey($id)) { $TUITION[$id] } else { $null })
        tuition_ug_max   = $(if ($TUITION.ContainsKey($id)) { $TUITION[$id] } else { $null })
        tuition_pg_min   = $null
        tuition_pg_max   = $null
        currency         = 'USD'
        english          = [ordered]@{ ielts_min = $ielts; accepted = $accepted; note = $engNote }
        popular_majors   = @($c[6].Trim() -split '\|')
        pathways         = $pathways.ToArray()
        intakes          = $intakes
        official_url     = $url
        youtube_id       = $null
        editor_note      = if ($ov -and $ov.note) { $ov.note } else { $null }
        related_ids      = @()
        last_verified    = '2026-07'
    })
}

if ($missingUrl.Count -gt 0) {
    Write-Host ("URL 누락 {0}건: {1}" -f $missingUrl.Count, ($missingUrl -join ', ')) -ForegroundColor Red
    exit 1
}

$json = $list | ConvertTo-Json -Depth 6
$utf8NoBom = New-Object Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $repoRoot 'data\universities-us.json'), $json, $utf8NoBom)
Write-Host ("생성: data\universities-us.json ({0}곳)" -f $list.Count) -ForegroundColor Green
