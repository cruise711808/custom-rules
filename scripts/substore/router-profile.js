/*
 * router-profile.js — Sub-Store 处理脚本（Response Transformer）：flower 订阅 → momo/sing-box 1.14 完整 profile
 * 挂载方式：Sub-Store 文件 router-singbox.json 的 process: [{ type:"Response Transformer", args:{mode:"link",content:"/api/file/router-profile.js"} }]
 * 输入: $response.body = flower 订阅导出（base64 trojan URI 列表或明文 URI 列表）
 * 输出: $response.body = sing-box 1.14 JSON profile
 * 真值混入点：CONF 常量区（本文件入 repo = 唯一真源；推送 Sub-Store 时用 local.ini 替换占位）
 */
var CONF = {
  ownDomain: '<own-domain>',            // local.ini: own_domain
  routerIP: '192.168.10.1',             // local.ini: home_router_ip
  homeLanCidr: '192.168.10.0/24',       // local.ini: home_lan_cidr
  homeTrojanHost: 'proxy.<own-domain>', // local.ini: home_trojan_host
  homeTrojanPort: 8443,                 // local.ini: home_trojan_port（lucky 前置）
  homeTrojanPass: '<trojan-password>',  // local.ini: home_trojan_password
  certDir: '/etc/ssl/lucky',
  apiSecret: '215530',
  ruleset: 'https://cdn.jsdelivr.net/gh/cruise711808/custom-rules@main/ruleset/singbox',
  includeRemark: '专线'
};

/* 分组定版表：顺序=面板顺序 Proxy > Final > Unlock > Oversea > 服务组 > 区域组 > DL
 * 维护规则: 三端(路由器/手机/Win)同步改动 */
var REGION = [
  { tag: 'HK', re: '香港' },
  { tag: 'TW', re: '台湾' },
  { tag: 'JP', re: '日本' },
  { tag: 'SG', re: '新加坡' },
  { tag: 'US', re: '美国' }
];

function b64MaybeDecode(txt) {
  var t = String(txt).trim();
  if (t.indexOf('://') >= 0) return t;
  try {
    if (typeof b64d === 'function') return b64d(t);
    if (typeof Buffer !== 'undefined') return Buffer.from(t, 'base64').toString('utf8');
  } catch (e) { /* fallthrough */ }
  return t;
}

function transformFunction($response, $context) {
  /* ---------- 解析节点 ---------- */
  var raw = b64MaybeDecode($response && $response.body != null ? $response.body : $response);
  var lines = raw.split('\n');
  var nodes = [];
  var i, ln, hi, hashIdx, name, head, qs, qIdx, q, ci, host, port, pass, sni, qi, kv, qa;
  for (i = 0; i < lines.length; i++) {
    ln = lines[i].trim();
    if (!ln || ln.indexOf('trojan://') !== 0) continue;
    hi = ln.indexOf('@');
    hashIdx = ln.indexOf('#');
    if (hi < 0 || hashIdx < 0) continue;
    name = decodeURIComponent(ln.slice(hashIdx + 1).trim());
    if (name.indexOf(CONF.includeRemark) < 0) continue; // Traffic/Expire/杂项在此过滤
    head = ln.slice(9, hi);                 // pass@host:port
    qs = ln.slice(hi + 1, hashIdx);
    qIdx = qs.indexOf('?');
    q = qIdx >= 0 ? qs.slice(qIdx + 1) : '';
    qs = qIdx >= 0 ? qs.slice(0, qIdx) : qs;
    ci = qs.lastIndexOf(':');
    host = qs.slice(0, ci);
    port = parseInt(qs.slice(ci + 1), 10);
    pass = decodeURIComponent(head.slice(0, head.lastIndexOf('@') + 1).slice(0, -1));
    sni = '';
    qa = q ? q.split('&') : [];
    for (qi = 0; qi < qa.length; qi++) {
      kv = qa[qi].split('=');
      if (kv[0] === 'sni') sni = decodeURIComponent(kv[1] || '');
    }
    var ob = { type: "trojan", tag: name, server: host, server_port: port, password: pass };
    if (sni) ob.tls = { enabled: true, server_name: sni };
    nodes.push(ob);
  }

  /* ---------- 组构建 ---------- */
  var regionNames = { HK: [], TW: [], JP: [], SG: [], US: [] };
  var spNames = [];
  var allNames = [];
  for (i = 0; i < nodes.length; i++) {
    var n = nodes[i].tag;
    allNames.push(n);
    var placed = false;
    for (var r = 0; r < REGION.length; r++) {
      if (n.indexOf(REGION[r].re) >= 0) { regionNames[REGION[r].tag].push(n); placed = true; break; }
    }
    if (!placed) spNames.push(n);
  }

  var groupDefs = [
    { tag: 'Proxy',     mem: ['HK', 'TW', 'JP', 'SG', 'US', 'SP', 'DIRECT'], spec: 'HK' },
    { tag: 'Final',     mem: ['Proxy', 'DIRECT'], spec: 'Proxy' },
    { tag: 'Unlock',    mem: ['Proxy', 'HK', 'TW', 'JP', 'SG', 'US', 'DIRECT'], spec: 'Proxy' },
    { tag: 'Oversea',   mem: ['Proxy', 'US', 'HK', 'TW', 'JP', 'SG'], spec: 'Proxy' },
    { tag: 'YouTube',   mem: ['Proxy', 'HK', 'JP', 'SG', 'TW', 'US'], spec: 'Proxy' },
    { tag: 'Bahamut',   mem: ['Proxy', 'HK', 'TW'], spec: 'Proxy' },
    { tag: 'Bilibili',  mem: ['DIRECT', 'HK', 'TW'], spec: 'DIRECT' },
    { tag: 'Spotify',   mem: ['Proxy', 'DIRECT', 'HK', 'JP', 'SG', 'TW', 'US'], spec: 'Proxy' },
    { tag: 'Steam',     mem: ['Proxy', 'DIRECT', 'HK', 'JP', 'SG', 'TW', 'US'], spec: 'Proxy' },
    { tag: 'Telegram',  mem: ['Proxy', 'HK', 'JP', 'SG', 'TW', 'US'], spec: 'Proxy' },
    { tag: 'Google',    mem: ['Proxy', 'HK', 'JP', 'SG', 'TW', 'US'], spec: 'Proxy' },
    { tag: 'Microsoft', mem: ['Proxy', 'DIRECT', 'HK', 'JP', 'SG', 'TW', 'US'], spec: 'Proxy' },
    { tag: 'PayPal',    mem: ['Proxy', 'DIRECT', 'HK', 'JP', 'SG', 'TW', 'US'], spec: 'Proxy' },
    { tag: 'Apple',     mem: ['Proxy', 'DIRECT', 'HK', 'JP', 'SG', 'TW', 'US'], spec: 'Proxy' },
    { tag: 'OpenAI',    mem: ['Proxy', 'HK', 'JP', 'SG', 'TW', 'US'], spec: 'Proxy' }
  ];
  var outbounds = [{ type: 'direct', tag: 'direct' }, {
    type: 'trojan', tag: 'Home-Trojan', server: CONF.homeTrojanHost, server_port: CONF.homeTrojanPort,
    password: CONF.homeTrojanPass, tls: { enabled: true, server_name: CONF.homeTrojanHost }
  }];
  for (i = 0; i < nodes.length; i++) outbounds.push(nodes[i]);
  for (i = 0; i < groupDefs.length; i++) {
    var g = groupDefs[i], mem = [], j;
    for (j = 0; j < g.mem.length; j++) {
      mem.push(g.mem[j] === 'DIRECT' ? 'direct' : g.mem[j]);
    }
    outbounds.push({ type: 'selector', tag: g.tag, outbounds: mem, 'default': g.spec === 'DIRECT' ? 'direct' : g.spec });
  }
  /* 区域组与 SP 放服务组之后，保持定版顺序: 区域组 > DL */
  for (i = 0; i < REGION.length; i++) {
    outbounds.push({
      type: 'selector', tag: REGION[i].tag,
      outbounds: regionNames[REGION[i].tag].slice(),
      'default': regionNames[REGION[i].tag][0]
    });
  }
  outbounds.push({ type: 'selector', tag: 'SP', outbounds: spNames.slice(), 'default': spNames[0] });
  outbounds.push({ type: 'selector', tag: 'DL', outbounds: ['direct'].concat(allNames), 'default': 'direct' });

  /* ---------- 静态内联规则（迁自 Server_Clash_Linux.tpl，PROCESS-* 因 redirect/tproxy 无进程信息而去除；1.14 规则集引用用 tag:id 查询语法） ---------- */
  function R(o) { return o; }
  var rules = [
    /* 防回环：trojan 入口 + 自身域名 + v.lan + 家网段 */
    R({ inbound: 'trojan-home', action: 'route', outbound: 'direct' }),
    R({ domain_suffix: '.' + CONF.ownDomain, action: 'route', outbound: 'direct' }),
    R({ domain_suffix: '.v.lan', action: 'route', outbound: 'direct' }),
    R({ ip_cidr: CONF.homeLanCidr, action: 'route', outbound: 'direct' }),
    /* 五类分流（自研 rule-set, version 5） */
    R({ rule_set: 'rs-direct', action: 'route', outbound: 'direct' }),
    R({ rule_set: 'rs-download', action: 'route', outbound: 'DL' }),
    R({ rule_set: 'rs-oversea', action: 'route', outbound: 'Oversea' }),
    R({ rule_set: 'rs-unlock', action: 'route', outbound: 'Unlock' }),
    R({ rule_set: 'geosite:category-porn', action: 'route', outbound: 'Oversea' }),
    R({ rule_set: 'rs-proxy', action: 'route', outbound: 'Proxy' }),
    R({ rule_set: 'geosite:category-games@cn', action: 'route', outbound: 'direct' }),
    R({ rule_set: 'geosite:youtube', action: 'route', outbound: 'YouTube' }),
    R({ rule_set: 'geosite:category-ai-chat-!cn', action: 'route', outbound: 'OpenAI' }),
    R({ rule_set: 'geosite:github', action: 'route', outbound: 'Proxy' }),
    R({ rule_set: 'geosite:category-games', action: 'route', outbound: 'Proxy' }),
    /* YouTube IP */
    R({ ip_cidr: ['172.110.32.0/21', '216.73.80.0/20', '2620:120:e000::/40'], action: 'route', outbound: 'YouTube' }),
    /* Bilibili（PROCESS-* 已去除） */
    R({ domain: ['p.bstarstatic.com'], action: 'route', outbound: 'Bilibili' }),
    R({ domain_suffix: ['bilibili.tv', 'corari.com', 'im9.com', 'sharejoytech.com', 'yo9.com'], action: 'route', outbound: 'Bilibili' }),
    R({ ip_cidr: ['106.75.74.76/32', '111.206.25.147/32', '119.3.238.64/32', '120.92.108.182/32', '120.92.113.99/32', '120.92.153.217/32', '134.175.207.130/32', '203.107.1.0/24', '116.211.202.206/32', '116.211.202.216/32'], action: 'route', outbound: 'Bilibili' }),
    /* Spotify */
    R({ domain_suffix: ['spotilocal.com'], action: 'route', outbound: 'Spotify' }),
    R({ domain_keyword: ['-spotify-', 'spotify.com'], action: 'route', outbound: 'Spotify' }),
    R({ ip_cidr: ['104.154.127.126/32', '35.186.224.47/32'], action: 'route', outbound: 'Spotify' }),
    /* Steam */
    R({ domain_suffix: ['f3b7q2p3.ssl.hwcdn.net', 'steamcontent.tnkjmec.com'], action: 'route', outbound: 'Steam' }),
    R({ domain_keyword: ['steambroadcast', 'steamstore', 'steamuserimages'], action: 'route', outbound: 'Steam' }),
    /* Telegram */
    R({ domain_suffix: ['stel.com'], action: 'route', outbound: 'Telegram' }),
    R({ domain_keyword: ['nicegram'], action: 'route', outbound: 'Telegram' }),
    R({ rule_set: 'geoip:telegram', action: 'route', outbound: 'Telegram' }),
    /* Google */
    R({ domain_suffix: ['adsensecustomsearchads.com', 'adsenseformobileapps.com', 'advertiserscommunity.com', 'adwords-community.com', 'adwords.com', 'adwordsexpress.com', 'app-measurement.net', 'chromercise.com', 'digitalattackmap.com', 'doubleclick.com', 'download.qatp1.net', 'googleadapis.com', 'monitoring.qpdp1.net', 'neverware.com', 'oasisfeng.com', 'qagpublic.qatp1.net', 'qgadmin.qcpp1.net', 'qualysapi.qatp1.net', 'qualysguard.qpdp1.net', 'scanservice1.qcpp1.net'], action: 'route', outbound: 'Google' }),
    R({ domain_keyword: ['appspot', 'blogspot', 'recaptcha'], action: 'route', outbound: 'Google' }),
    R({ rule_set: 'geoip:google', action: 'route', outbound: 'Google' }),
    /* Microsoft（PROCESS-* 已去除） */
    R({ domain_suffix: ['acompli.com', 'acompli.net', 'aicscience.com', 'assets-yammer.com', 'azure-apim.net', 'azurerms.com', 'bbing.com', 'bibg.com', 'biing.com', 'binb.com', 'binf.com', 'bing135.com', 'bing4.com', 'bingads.com', 'binginternal.com', 'bingit.net', 'bingiton.com', 'bingj.com', 'bingpix.com', 'bingpk.com', 'bings.com', 'bingtoolbar.com', 'bingtranslator.com', 'biying.com', 'cs11.wpc.v0cdn.net', 'cs9.wac.phicdn.net', 'discoverbing.com', 'dwh5.com', 'e-msedge.net', 'evoke-windowsservices-tas.msedge', 'explorebing.com', 'getmicrosoftkey.com', 'groupme.com', 'helpshift.com', 'here.com', 'here.net', 'hockeyapp.net', 'joinms.com', 'joinmva.com', 'localytics.com', 'lync.com', 'mapblast.com', 'mappoint.com', 'mesh.com', 'microsoft-tst.com', 'microsoft.com.nsatc.net', 'microsoftads.com', 'microsoftemail.com', 'microsoftestore.com.hk', 'microsoftol.com', 'microsoftonline-p.net', 'microsoftusercontent.com', 'msads.net', 'msappproxy.net', 'msauthimages.net', 'msftidentity.com', 'msignitechina.com', 'msn.com.nsatc.net', 'msnmaps.com', 'msvevent.com', 'msxiaobing.com', 'msxiaoice.com', 'myhomemsn.com', 'oaspapps.com', 'officeppe.net', 'onecollector.cloudapp.aria', 'onmicrosoft.com', 'optimizely.com', 'osdinfra.net', 'outlookmobile.com', 'phonefactor.net', 'playfabcn.com', 'renlifang.com', 'sclive.net', 'skypeforbusiness.com', 'sway-extensions.com', 'uservoice.com', 'vip5.afdorigin-prod-am02.afdogw.com', 'windows-ppe.net', 'wlxrs.com', 'working-bing-int.com', 'wunderlist.com', 'yammerusercontent.com'], action: 'route', outbound: 'Microsoft' }),
    R({ domain_keyword: ['onedrive', 'skydrive'], action: 'route', outbound: 'Microsoft' }),
    /* OpenAI IP（geosite ai-chat 在前） */
    R({ ip_cidr: ['160.79.104.0/21', '2607:6BC0::/32', '24.199.123.28/32', '64.23.132.171/32'], action: 'route', outbound: 'OpenAI' }),
    /* PayPal */
    R({ domain_suffix: ['paypal-mktg.com'], action: 'route', outbound: 'PayPal' }),
    R({ domain_keyword: ['paypal'], action: 'route', outbound: 'PayPal' }),
    /* Apple（PROCESS-* 已去除） */
    R({ domain_suffix: ['appstore.com'], action: 'route', outbound: 'Apple' }),
    R({ domain_keyword: ['apple.com.akadns.net', 'apple.com.edgekey.net', 'apple-support.akadns.net', 'icloud.com.akadns.net', 'testflight'], action: 'route', outbound: 'Apple' }),
    R({ ip_cidr: ['139.178.128.0/18', '144.178.0.0/19', '144.178.36.0/22', '144.178.48.0/20', '17.0.0.0/8', '192.35.50.0/24', '198.183.17.0/24', '205.180.175.0/24', '63.92.224.0/19', '65.199.22.0/23'], action: 'route', outbound: 'Apple' }),
    /* Amazon/Line 等 → Proxy（tpl IP-CIDR 兜底段） */
    R({ ip_cidr: ['13.32.0.0/15', '13.35.0.0/17', '18.184.0.0/15', '18.194.0.0/15', '18.208.0.0/13', '18.232.0.0/14', '52.200.0.0/13', '52.58.0.0/15', '52.74.0.0/16', '52.77.0.0/16', '52.84.0.0/15', '54.156.0.0/14', '54.226.0.0/15', '54.230.156.0/22', '54.93.0.0/16', '103.2.30.0/23', '125.209.208.0/20', '147.92.128.0/17', '203.104.144.0/21', '109.239.140.0/24', '5.28.195.163/32', '5.28.195.205/32', '5.28.195.37/32', '91.108.0.0/16'], action: 'route', outbound: 'Proxy' }),
    R({ ip_cidr: ['182.254.116.0/24', '203.205.238.0/23', '203.205.254.0/23'], action: 'route', outbound: 'direct' }),
    /* Loyalsoldier → sing-geosite.db id 等价（1.14 tag:id 查询）；tld-not-cn 自托管 source json */
    R({ rule_set: 'geosite:private', action: 'route', outbound: 'direct' }),
    R({ rule_set: 'geosite:apple', action: 'route', outbound: 'direct' }),
    R({ rule_set: 'geosite:icloud', action: 'route', outbound: 'direct' }),
    R({ rule_set: 'geosite:google', action: 'route', outbound: 'direct' }),
    R({ rule_set: 'geosite:direct', action: 'route', outbound: 'direct' }),
    R({ rule_set: 'geosite:proxy', action: 'route', outbound: 'Proxy' }),
    R({ rule_set: 'geosite:gfw', action: 'route', outbound: 'Proxy' }),
    R({ rule_set: 'ls-tld-not-cn', action: 'route', outbound: 'Proxy' }),
    R({ rule_set: 'geoip:cn', action: 'route', outbound: 'direct' }),
    R({ ip_cidr: ['192.168.0.0/16', '10.0.0.0/8', '172.16.0.0/12', '127.0.0.0/8', '100.64.0.0/10', '::1/128', 'fc00::/7', 'fe80::/10', 'fd00::/8'], action: 'route', outbound: 'direct' })
  ];

  /* ---------- rule-set（1.14: remote 不再写 path，update_interval 自动更新） ---------- */
  function remote(tag, format, url) {
    return { type: 'remote', tag: tag, format: format, url: url, update_interval: '7d', download_detour: 'direct' };
  }
  var ruleSets = [
    remote('rs-direct', 'source', CONF.ruleset + '/direct.json'),
    remote('rs-download', 'source', CONF.ruleset + '/download.json'),
    remote('rs-oversea', 'source', CONF.ruleset + '/oversea.json'),
    remote('rs-unlock', 'source', CONF.ruleset + '/unlock.json'),
    remote('rs-proxy', 'source', CONF.ruleset + '/proxy.json'),
    remote('ls-tld-not-cn', 'source', CONF.ruleset + '/tld-not-cn.json'),
    remote('geosite', 'binary', 'https://cdn.jsdelivr.net/gh/SagerNet/sing-geosite@release/geosite.db'),
    remote('geoip', 'binary', 'https://cdn.jsdelivr.net/gh/SagerNet/sing-geoip@release/geoip.db')
  ];

  /* ---------- profile ---------- */
  var profile = {
    log: { level: 'info', timestamp: true },
    dns: {
      servers: [
        /* boot=dnsmasq:54（钉死真上游，不走 AGH:53→7874 回环） */
        { type: 'udp', tag: 'boot', server: '127.0.0.1', server_port: 54 },
        { type: 'udp', tag: 'lan-dns', server: CONF.routerIP, server_port: 54 },
        { type: 'https', tag: 'doh-global', server: 'dns.google', detour: 'Proxy' }
      ],
      rules: [
        { domain: ['dns.google'], action: 'route', server: 'boot' },
        { domain_suffix: ['.' + CONF.ownDomain], action: 'route', server: 'boot' },
        { domain_suffix: ['lan'], action: 'route', server: 'lan-dns' },
        { action: 'evaluate', server: 'boot' },
        { match_response: true, rule_set: ['geoip'], action: 'route', server: 'boot' }
      ],
      final: 'doh-global',
      strategy: 'prefer_ipv4'
    },
    inbounds: [
      /* momo 约定：redirect-in=redirect 型(TCP)、tproxy-in=tproxy 型(UDP)、dns-in=direct 型；1.14 仍兼容 redirect/tproxy 类型（momo check 只认这两个） */
      { type: 'redirect', tag: 'redirect-in', listen: '::', listen_port: 7894 },
      { type: 'tproxy', tag: 'tproxy-in', listen: '::', listen_port: 7894, network: 'udp' },
      { type: 'direct', tag: 'dns-in', listen: '::', listen_port: 7874, network: 'udp' },
      { type: 'trojan', tag: 'trojan-home', listen: '::', listen_port: 8444,
        users: [{ name: 'home', password: CONF.homeTrojanPass }],
        tls: { enabled: true, certificate_path: CONF.certDir + '/' + CONF.ownDomain + '.pem', key_path: CONF.certDir + '/' + CONF.ownDomain + '.key' } }
      /* 防回环由 route.rules 首条 { inbound: 'trojan-home' -> direct } 完成（1.14 入站无默认出口字段） */
    ],
    outbounds: outbounds,
    route: {
      final: 'Proxy',
      default_domain_resolver: { server: 'boot' },
      auto_detect_interface: true,
      rule_set: ruleSets,
      rules: rules
    },
    experimental: {
      cache_file: { enabled: true, store_dns: true },
      clash_api: {
        external_controller: '0.0.0.0:9090',
        secret: CONF.apiSecret,
        external_ui: 'ui',
        external_ui_download_url: 'https://github.com/Zephyruso/zashboard/releases/latest/download/dist-cdn-fonts.zip'
      }
    }
  };

  return {
    status: ($response && $response.status) || 200,
    headers: { 'content-type': 'application/json; charset=utf-8' },
    body: JSON.stringify(profile, null, 2)
  };
}
