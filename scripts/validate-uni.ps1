# 대학 DB 스키마 v1 검증 스크립트
# 사용법:  powershell -ExecutionPolicy Bypass -File scripts\validate-uni.ps1
# data\universities-*.json 전체를 검사한다. 오류가 하나라도 있으면 exit 1.

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot

$TYPE_ENUM     = @('university', 'college', 'specialty')
$ENGLISH_ENUM  = @('ielts', 'toefl', 'pte', 'duolingo', 'toeic', 'cambridge', 'internal')
$PATHWAY_ENUM  = @('foundation', 'iyo', 'direct', 'pre-master', 'pathway', 'transfer', 'college')
$REQUIRED      = @('id', 'type', 'name_ko', 'name_en', 'country', 'city', 'currency', 'english', 'popular_majors', 'pathways', 'intakes', 'official_url', 'last_verified')

$errors = New-Object System.Collections.Generic.List[string]
$allIds = New-Object System.Collections.Generic.List[string]
$count  = 0

function Test-NullOrNumber($value) {
    if ($null -eq $value) { return $true }
    return ($value -is [int] -or $value -is [long] -or $value -is [double] -or $value -is [decimal])
}

$dataFiles = Get-ChildItem -Path (Join-Path $repoRoot 'data') -Filter 'universities-*.json' -File
if (-not $dataFiles) {
    Write-Host 'data\universities-*.json 파일이 없습니다.' -ForegroundColor Red
    exit 1
}

foreach ($file in $dataFiles) {
    $raw = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    try {
        $unis = $raw | ConvertFrom-Json
    } catch {
        $errors.Add("[$($file.Name)] JSON 파싱 실패: $($_.Exception.Message)")
        continue
    }
    if ($unis -isnot [System.Array]) { $unis = @($unis) }

    for ($i = 0; $i -lt $unis.Count; $i++) {
        $u = $unis[$i]
        $count++
        $label = if ($u.id) { $u.id } else { "$($file.Name)#$i" }

        # 필수 필드
        foreach ($field in $REQUIRED) {
            $prop = $u.PSObject.Properties[$field]
            if ($null -eq $prop -or $null -eq $prop.Value -or ($prop.Value -is [string] -and $prop.Value -eq '')) {
                $errors.Add("[$label] 필수 필드 누락/빈 값: $field")
            }
        }

        # id 형식·중복
        if ($u.id) {
            if ($u.id -cnotmatch '^[a-z]{2}-[a-z0-9-]+$') {
                $errors.Add("[$label] id 형식 오류(국가코드-약칭, 소문자·하이픈): $($u.id)")
            }
            if ($allIds -contains $u.id) { $errors.Add("[$label] id 중복") }
            $allIds.Add($u.id)
        }

        # enum: type
        if ($u.type -and $TYPE_ENUM -cnotcontains $u.type) {
            $errors.Add("[$label] type enum 오타: '$($u.type)' (허용: $($TYPE_ENUM -join ', '))")
        }

        # qs_rank: null 또는 정수
        if (-not (Test-NullOrNumber $u.qs_rank)) {
            $errors.Add("[$label] qs_rank 는 숫자 또는 null 이어야 합니다: '$($u.qs_rank)'")
        }

        # 학비: null 또는 숫자, min <= max
        foreach ($field in @('tuition_ug_min', 'tuition_ug_max', 'tuition_pg_min', 'tuition_pg_max')) {
            $v = $u.PSObject.Properties[$field].Value
            if (-not (Test-NullOrNumber $v)) {
                $errors.Add("[$label] $field 는 통화기호·콤마 없는 숫자 또는 null 이어야 합니다: '$v'")
            }
        }
        foreach ($level in @('ug', 'pg')) {
            $min = $u.PSObject.Properties["tuition_${level}_min"].Value
            $max = $u.PSObject.Properties["tuition_${level}_max"].Value
            if ($null -ne $min -and $null -ne $max -and (Test-NullOrNumber $min) -and (Test-NullOrNumber $max) -and $min -gt $max) {
                $errors.Add("[$label] tuition_${level}_min($min) > tuition_${level}_max($max)")
            }
        }

        # english
        if ($u.english) {
            if (-not (Test-NullOrNumber $u.english.ielts_min) -or $null -eq $u.english.ielts_min) {
                $errors.Add("[$label] english.ielts_min 는 숫자여야 합니다")
            }
            if (-not $u.english.accepted -or $u.english.accepted.Count -eq 0) {
                $errors.Add("[$label] english.accepted 가 비어 있습니다")
            } else {
                foreach ($test in $u.english.accepted) {
                    if ($ENGLISH_ENUM -cnotcontains $test) {
                        $errors.Add("[$label] english.accepted enum 오타: '$test' (허용: $($ENGLISH_ENUM -join ', '))")
                    }
                }
            }
        }

        # pathways
        if ($u.pathways) {
            for ($p = 0; $p -lt $u.pathways.Count; $p++) {
                $pw = $u.pathways[$p]
                if (-not $pw.type) {
                    $errors.Add("[$label] pathways[$p].type 누락")
                } elseif ($PATHWAY_ENUM -cnotcontains $pw.type) {
                    $errors.Add("[$label] pathways[$p].type enum 오타: '$($pw.type)' (허용: $($PATHWAY_ENUM -join ', '))")
                }
            }
        }

        # intakes 비어 있으면 안 됨
        if ($u.intakes -and $u.intakes.Count -eq 0) {
            $errors.Add("[$label] intakes 가 비어 있습니다")
        }

        # official_url
        if ($u.official_url -and $u.official_url -notmatch '^https?://') {
            $errors.Add("[$label] official_url 은 http(s):// 로 시작해야 합니다: '$($u.official_url)'")
        }

        # last_verified: YYYY-MM
        if ($u.last_verified -and $u.last_verified -notmatch '^\d{4}-(0[1-9]|1[0-2])$') {
            $errors.Add("[$label] last_verified 형식 오류(YYYY-MM): '$($u.last_verified)'")
        }
    }
}

Write-Host ''
if ($errors.Count -gt 0) {
    Write-Host "검증 실패 — 오류 $($errors.Count)건 / 대학 ${count}곳" -ForegroundColor Red
    foreach ($e in $errors) { Write-Host "  - $e" -ForegroundColor Red }
    exit 1
} else {
    Write-Host "검증 통과 — 대학 ${count}곳, 오류 없음" -ForegroundColor Green
    exit 0
}
