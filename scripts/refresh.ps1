# refresh.ps1 - subconverter 本地转换一轮（路由器端）-> output\mihomo.yaml
# 用法: powershell -ExecutionPolicy Bypass -File scripts\refresh.ps1
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot          # repo 根目录 (scripts 的上级)
$dir  = 'D:\Program\subconverter'                # subconverter 程序目录（不在 repo 内）
$exe  = Join-Path $dir 'subconverter.exe'
$pub  = Join-Path $dir 'output'                  # 订阅源与产物都在这里
$out  = Join-Path $pub 'mihomo.yaml'
$log  = Join-Path $pub 'refresh.log'

# generate.ini / base 模板以 repo 里的为准（跑前同步到程序目录）
if (-not (Test-Path (Join-Path $root 'config\generate.ini'))) {
    Copy-Item (Join-Path $root 'config\generate.ini.example') (Join-Path $root 'config\generate.ini')
    Write-Warning '首次运行: 已复制 generate.ini.example, 请把 token2 换成面板新链接里的真实 token'
}
Copy-Item (Join-Path $root 'config\generate.ini') (Join-Path $dir 'generate.ini') -Force
Copy-Item (Join-Path $root 'template\Server_Clash_Linux.tpl') (Join-Path $dir 'base\Server_Clash_Linux.tpl') -Force

$before = if (Test-Path $out) { (Get-Item $out).LastWriteTime } else { [datetime]::MinValue }
Remove-Item $log -Force -ErrorAction SilentlyContinue
Push-Location $dir
try {
    $eap = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    & $exe -g -l $log 2>&1 | Out-Null    # -l: 日志写文件（PS 不吃 stderr）
    $ErrorActionPreference = $eap
} finally { Pop-Location }

if (-not ((Test-Path $out) -and (Get-Item $out).LastWriteTime -gt $before -and (Select-String -Path $log -Pattern 'generate SUCCESS' -Quiet))) {
    Write-Warning '生成失败或超时，查看 output\refresh.log'
    Get-Content $log -Tail 5 | Write-Warning
    exit 1
}

# ini 混入: local.ini 真值替换模板占位符（真值唯一维护点，profile 自包含）
$localIni = Join-Path $root 'config\local.ini'
if (-not (Test-Path $localIni)) { throw 'config\local.ini 缺失 - 复制 local.ini.example 并填真值（ini 是唯一真值源）' }
$cfg = @{}
foreach ($l in [IO.File]::ReadAllLines($localIni)) {
    if ($l -match '^\s*(\w+)\s*=\s*(.+?)\s*$') { $cfg[$matches[1]] = $matches[2] }
}
$dom = $cfg['own_domain']; $pw = $cfg['home_trojan_password']
if (-not $dom -or -not $pw) { throw 'local.ini: own_domain / home_trojan_password 缺失' }
$txt = [IO.File]::ReadAllText($out, [Text.Encoding]::UTF8)
$txt = $txt.Replace('<own-domain>', $dom).Replace('<trojan-password>', $pw)
if ($txt -match '<own-domain>|<trojan-password>') { throw '产物中仍有未替换占位符' }
[IO.File]::WriteAllText($out, $txt, (New-Object System.Text.UTF8Encoding($false)))

# 组顺序: proxy-groups 按定版顺序重排（与手机 [Proxy Group] 同一套:
# Proxy > Final > 11 服务组 > HK TW JP SG US SP > DL；面板显示顺序=配置文件顺序）
$y = [IO.File]::ReadAllLines($out, [Text.Encoding]::UTF8)
$g = [array]::IndexOf($y, 'proxy-groups:')
if ($g -lt 0) { throw 'proxy-groups section not found' }
$ge = $g + 1
while ($ge -lt $y.Count -and $y[$ge] -notmatch '^[a-z]') { $ge++ }
$blocks = @(); $cur = $null
foreach ($l in $y[($g + 1)..($ge - 1)]) {
    if ($l -match '^  - name: (.+)$') {
        if ($null -ne $cur) { $blocks += ,@($cur) }
        $cur = [System.Collections.Generic.List[string]]::new(); $cur.Add($l)
    } elseif ($null -ne $cur) { $cur.Add($l) }
}
if ($null -ne $cur) { $blocks += ,@($cur) }
$blockNames = foreach ($b in $blocks) { ($b[0] -replace '^  - name: ', '').Trim() }
$prio = 'Proxy', 'Final', 'Unlock', 'Oversea', 'YouTube', 'Bahamut', 'Bilibili', 'Spotify', 'Steam', 'Telegram',
        'Google', 'Microsoft', 'PayPal', 'Apple', 'OpenAI', 'HK', 'TW', 'JP', 'SG', 'US', 'SP', 'DL'
$miss = @($blockNames | Where-Object { $prio -notcontains $_ })
if ($miss) { Write-Warning ("组不在排序表, 排在末尾: " + ($miss -join ', ')) }
$ordered = @()
foreach ($n in ($prio + $miss)) {
    $ix = [array]::IndexOf($blockNames, $n)
    if ($ix -ge 0) { $ordered += ,$blocks[$ix] }
}
$new = [System.Collections.Generic.List[string]]::new()
$new.AddRange([string[]]$y[0..$g])
foreach ($b in $ordered) { $new.AddRange([string[]]$b) }
if ($ge -lt $y.Count) { $new.AddRange([string[]]$y[$ge..($y.Count - 1)]) }
[IO.File]::WriteAllLines($out, $new, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ('groups ordered: ' + (($prio | Where-Object { $blockNames -contains $_ }) -join ' > '))
Write-Host ('OK ' + (Get-Item $out).LastWriteTime + ' <- mihomo.yaml (真值已从 local.ini 混入)')
