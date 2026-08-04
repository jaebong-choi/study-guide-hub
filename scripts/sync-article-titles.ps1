# Sync article titles/descriptions from hub articles-au.json into a study-guide INFO block.
# ASCII-only source; every Korean string is read from the files, never written here.
param(
    [Parameter(Mandatory=$true)][string]$HubJson,
    [Parameter(Mandatory=$true)][string]$DiagHtml,
    [switch]$Apply
)
$ErrorActionPreference = 'Stop'

$hub = [IO.File]::ReadAllText($HubJson) | ConvertFrom-Json
$map = @{}
foreach ($a in $hub) { $map[$a.slug] = $a }

$diag = [IO.File]::ReadAllText($DiagHtml)

function Esc([string]$s) { return $s.Replace('\', '\\').Replace('"', '\"') }

# Rebuild one "field: value" line, preserving the leading prefix (indent, and a
# possible opening brace when the first field shares the line) and trailing comma.
function NewLine([string]$orig, [string]$prefix, [string]$field, [string]$value) {
    $tail = ''
    if ($orig.TrimEnd().EndsWith(',')) { $tail = ',' }
    return $prefix + $field + ': "' + (Esc $value) + '"' + $tail
}

$objRx = [regex]'\{[^{}]*url:\s*HUB_ARTICLE\s*\+\s*"([^"]+)\.html"[^{}]*\}'
$objs = $objRx.Matches($diag)
Write-Host ("objects found: " + $objs.Count)

$report = New-Object System.Collections.ArrayList
$edits  = New-Object System.Collections.ArrayList

foreach ($m in $objs) {
    $slug = $m.Groups[1].Value
    if (-not $map.ContainsKey($slug)) {
        [void]$report.Add("SKIP  $slug  (not in hub)")
        continue
    }
    $a = $map[$slug]
    $lines = $m.Value -split "`r?`n"
    $changed = New-Object System.Collections.ArrayList
    $seen = @{}

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]

        # The line carrying url: HUB_ARTICLE also carries cat / min / ver.
        if ($line -match 'url:\s*HUB_ARTICLE') {
            $seen['cat'] = $true
            $cm = [regex]::Match($line, 'cat:\s*"([^"]*)"')
            if (-not $cm.Success) { continue }
            $oldCat = $cm.Groups[1].Value
            if ($oldCat -ne $a.category) { [void]$changed.Add("cat($oldCat>" + $a.category + ")") }
            $line = [regex]::Replace($line, 'cat:\s*"[^"]*"', 'cat: "' + $a.category + '"')
            $mm = [regex]::Match($line, 'min:\s*(\d+)')
            if ($mm.Success) {
                if ([int]$mm.Groups[1].Value -ne [int]$a.read_min) { [void]$changed.Add("min(" + $mm.Groups[1].Value + '>' + $a.read_min + ")") }
                $line = [regex]::Replace($line, 'min:\s*\d+', 'min: ' + $a.read_min)
            }
            $mv = [regex]::Match($line, 'ver:\s*"([^"]*)"')
            if ($mv.Success) {
                if ($mv.Groups[1].Value -ne $a.verified) { [void]$changed.Add("ver(" + $mv.Groups[1].Value + '>' + $a.verified + ")") }
                $line = [regex]::Replace($line, 'ver:\s*"[^"]*"', 'ver: "' + $a.verified + '"')
            }
            $lines[$i] = $line
            continue
        }

        # A text field line. The first one may share the line with the opening brace.
        $fm = [regex]::Match($line, '^(\s*\{?\s*)(ko|en|dko|den):\s*"')
        if (-not $fm.Success) { continue }
        $prefix = $fm.Groups[1].Value
        $field  = $fm.Groups[2].Value
        $seen[$field] = $true
        switch ($field) {
            'ko'  { $val = $a.title_ko; $tag = 'title_ko' }
            'en'  { $val = $a.title_en; $tag = 'title_en' }
            'dko' { $val = $a.desc_ko;  $tag = 'desc_ko'  }
            'den' { $val = $a.desc_en;  $tag = 'desc_en'  }
        }
        if ($line.TrimEnd().TrimEnd(',') -ne ($prefix + $field + ': "' + (Esc $val) + '"')) {
            [void]$changed.Add($tag)
        }
        $lines[$i] = NewLine $line $prefix $field $val
    }

    $missing = @('ko','en','dko','den','cat') | Where-Object { -not $seen.ContainsKey($_) }
    if ($missing.Count -gt 0) {
        [void]$report.Add("WARN  $slug  missing: $($missing -join ',')")
        continue
    }

    if ($changed.Count -gt 0) {
        [void]$report.Add(("EDIT  {0,-20} {1}" -f $slug, ($changed -join ' ')))
        [void]$edits.Add([pscustomobject]@{ Index = $m.Index; Length = $m.Length; Text = ($lines -join "`n") })
    } else {
        [void]$report.Add("OK    $slug")
    }
}

$report | ForEach-Object { Write-Host $_ }
Write-Host ("objects needing edit: " + $edits.Count)

if ($Apply -and $edits.Count -gt 0) {
    $sb = New-Object System.Text.StringBuilder($diag)
    foreach ($e in ($edits | Sort-Object Index -Descending)) {
        [void]$sb.Remove($e.Index, $e.Length)
        [void]$sb.Insert($e.Index, $e.Text)
    }
    [IO.File]::WriteAllText($DiagHtml, $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))
    Write-Host ("WROTE " + $DiagHtml)
}
