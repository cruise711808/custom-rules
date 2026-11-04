# refresh_client.ps1 - generate the Android phone config (Surfboard) from the latest converted yaml
# usage: powershell -ExecutionPolicy Bypass -File scripts\refresh_client.ps1
# notes: subconverter -g reads exactly one generate.ini and (in v0.9.0) only honours url= of the
#        FIRST profile section -> this script swaps in config\generate_client.ini before running.
#        [Proxy] nodes and [Proxy Group] members come fully from the subscription + ini groups;
#        the tpl only carries [General] and [Rule] (generator rewrites the other sections).
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot          # repo root (parent of scripts)
$dir  = 'D:\Program\subconverter'                 # subconverter program dir (outside repo)
$exe  = Join-Path $dir 'subconverter.exe'
$pub  = Join-Path $dir 'output'
$out  = Join-Path $pub 'surfboard_mobile.conf'

if (-not (Test-Path (Join-Path $root 'config\generate_client.ini'))) {
    Copy-Item (Join-Path $root 'config\generate_client.ini.example') (Join-Path $root 'config\generate_client.ini')
    Write-Warning 'first run: copied generate_client.ini.example (check url= source)'
}
Copy-Item (Join-Path $root 'config\generate_client.ini') (Join-Path $dir 'generate.ini') -Force
Copy-Item (Join-Path $root 'template\Client_Surfboard_Android.tpl') (Join-Path $dir 'base\Client_Surfboard_Android.tpl') -Force

if (Test-Path $out) { Remove-Item $out -Force }
& $exe -g -l (Join-Path $pub 'refresh_client.log') | Out-Null
if (-not (Test-Path $out)) { throw 'surfboard_mobile.conf not generated - check output\refresh_client.log' }

# inject Home-Trojan (回家节点): generator rewrites [Proxy]/[Proxy Group], so the static
# trojan -> home listener must be re-added after generation. 真值全线唯一维护点: config\local.ini.
$local = Join-Path $root 'config\local.ini'
if (Test-Path $local) {
    $cfg = @{}
    foreach ($l in [IO.File]::ReadAllLines($local)) {
        if ($l -match '^\s*(\w+)\s*=\s*(.+?)\s*$') { $cfg[$matches[1]] = $matches[2] }
    }
    $dom = $cfg['own_domain']; $tpw = $cfg['home_trojan_password']
    if (-not $dom -or -not $tpw) { throw 'local.ini: own_domain / home_trojan_password missing' }
    $hst = $cfg['home_trojan_host'];  if (-not $hst)  { $hst = "proxy.$dom" }
    $prt = $cfg['home_trojan_port'];  if (-not $prt)  { $prt = '8443' }
    $cidr = $cfg['home_lan_cidr'];    if (-not $cidr) { $cidr = '192.168.10.0/24' }
    $rip = $cfg['home_router_ip'];    if (-not $rip)  { $rip = '192.168.10.1' }
} else {
    Write-Warning 'config\local.ini missing - Home-Trojan node skipped'
    $dom = $null
}

# ---- DNS split: [Host] RULE-SET:/DOMAIN-SET: entries (Surfboard >= mobile-2.33.0, changelog
# "[Host] Rule Sets") - a WHOLE LIST gets a DNS server, no per-domain enumeration.
# Manual syntax ref (github getsurfboard/manual docs/ai-profile-guide/reference.md):
#   key form `DOMAIN-SET:<url>` / `RULE-SET:<url>`, value = same server: forms as normal host keys.
# Router policy mapping: '+.lan'/'+.<dom>'/bootstrap names -> static; own five lists -> RULE-SET:;
# ruleprovider:ls-private/apple/icloud/google -> DOMAIN-SET: pointing at the ORIGINAL Loyalsoldier
# URLs (zero derived copies in the repo; NOTE their .txt are YAML payload format
# ("- '+.x'"), so if the phone log shows a set failing to parse, this is the suspect);
# ruleprovider:ls-direct -> NOT shipped (110k domains; phone default dns-server layer is already
# all-domestic = same answer).
$dnsCn  = 'server:223.5.5.5'
$dnsOvs = 'server:https://cloudflare-dns.com/dns-query'
$base   = 'https://cdn.jsdelivr.net/gh/cruise711808/custom-rules@main'
$lsBase = 'https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release'
$bootNames = 'cloudflare-dns.com', 'dns.google', 'doh.opendns.com', 'cdn.jsdelivr.net'  # jsdelivr matters: every RULE-SET/DOMAIN-SET is fetched from it
# [Host] set lines (five egress lists)
$hostSets = @()
foreach ($l in @( @('direct', $dnsCn), @('proxy', $dnsOvs), @('unlock', $dnsOvs), @('oversea', $dnsOvs), @('download', $dnsOvs) )) {
    $hostSets += "RULE-SET:$base/ruleset/clash/$($l[0]).list = $($l[1])"
}
foreach ($n in 'private', 'apple', 'icloud', 'google') {
    $hostSets += "DOMAIN-SET:$lsBase/$n.txt = $dnsCn"
}

$lines = [IO.File]::ReadAllLines($out, [Text.Encoding]::UTF8)
$result = New-Object System.Collections.Generic.List[string]
$injProxy = $false; $injRule = $false
foreach ($line in $lines) {
    if ($dom -and -not $injProxy -and $line.Trim() -eq '[Proxy]') {
        # [Host] = phone DNS split, mirroring the router dns layers ONE BY ONE:
        #   L1 hosts '+.v.lan'     -> *.v.lan static (zero query)
        #   L2 policy '+.lan'      -> *.lan = server:<router>  (client front door :53 pipeline)
        #   L3 policy '+.<dom>'    -> own domain -> oversea DoH (public true answer)
        #   L4 bootstrap pin       -> DoH server name pinned to domestic resolver
        #   + LIST PINS: six egress lists expanded to per-domain server: pins above (国内->223.5.5.5,
        #     国外->Cloudflare DoH) - THIS is the phone-side 国内/国外 DNS split
        #   L5 nameserver domestic -> [General] dns-server default  L6 国外 -> node-side (fake-ip)
        $result.Add('[Host]')
        $result.Add('*.v.lan = ' + $rip)
        $result.Add('*.lan = server:' + $rip)
        $result.Add('*.' + $dom + ' = ' + $dnsOvs)
        foreach ($b in $bootNames) { $result.Add("$b = " + $dnsCn) }
        $result.Add('# list DNS split via [Host] rule sets (Surfboard >= mobile-2.33.0); ls-direct skipped: default layer already domestic')
        foreach ($s in $hostSets) { $result.Add($s) }
        $result.Add('')
        $result.Add($line)
        # Surfboard trojan syntax REQUIRES named password= (positional bare password -> decode failed/NPE)
        $result.Add("Home-Trojan = trojan, $hst, $prt, password=$tpw, sni=$hst, udp-relay=true")
        $injProxy = $true; continue
    }
    if ($dom -and -not $injRule -and $line.Trim() -eq '[Rule]') {
        $result.Add($line)
        # home split by domain/IP (mirrors the user's Verge main(config) script) - rules target
        # the node DIRECTLY (no select group): own public domain DIRECT (anti loop),
        # v.lan (resolved by [Host] above) + home LAN CIDR -> home node.
        $result.Add("DOMAIN-SUFFIX,$dom,DIRECT")
        $result.Add('DOMAIN-SUFFIX,v.lan,Home-Trojan')
        $result.Add("IP-CIDR,$cidr,Home-Trojan,no-resolve")
        $injRule = $true; continue
    }
    $result.Add($line)
}
# ini 混入: <own-domain> tokens left by the tpl (e.g. [General] always-real-ip) get real values
if ($dom) { for ($i = 0; $i -lt $result.Count; $i++) { $result[$i] = $result[$i].Replace('<own-domain>', $dom) } }
# reorder [Proxy Group] for the app UI: Proxy first, DL/Final next, region node groups last
$gi = $result.IndexOf('[Proxy Group]')
if ($gi -ge 0) {
    $ge = $gi + 1
    while ($ge -lt $result.Count -and $result[$ge] -notmatch '^\s*\[') { $ge++ }
    $block = @($result[($gi + 1)..($ge - 1)] | Where-Object { $_.Trim() -ne '' })
    # explicit priority pick (PS 5.1 Sort-Object has no -Stable; Where-Object preserves order)
    # app display order: Proxy -> Final -> service groups -> (region node groups + DL last,
    # DL is a node picker like TW so it belongs down there with them)
    $prio = 'Proxy', 'Final', 'Unlock', 'Oversea', 'YouTube', 'Bahamut', 'Bilibili', 'Spotify', 'Steam',
            'Telegram', 'Google', 'Microsoft', 'PayPal', 'Apple', 'OpenAI'
    $sorted = @()
    foreach ($gname in $prio) {
        $sorted += @($block | Where-Object { ($_ -split '=')[0].Trim() -eq $gname })
    }
    $sorted += @($block | Where-Object { $n = ($_ -split '=')[0].Trim(); $prio -notcontains $n })
    $new = New-Object System.Collections.Generic.List[string]
    $new.AddRange([string[]]@($result[0..$gi]))
    $new.AddRange([string[]]$sorted)
    if ($ge -lt $result.Count) { $new.AddRange([string[]]@($result[$ge..($result.Count - 1)])) }
    $result = $new
}
[IO.File]::WriteAllLines($out, $result, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("OK: {0} ({1} lines, Host+proxy injected: {2}, home rules: {3})" -f $out, $result.Count, $injProxy, $injRule)
