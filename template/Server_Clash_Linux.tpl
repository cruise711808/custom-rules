port: 8080
socks-port: 1080
redir-port: 7891
mixed-port: 7890
allow-lan: true
mode: rule
log-level: warning
external-controller: '[::]:9090'
unified-delay: true
geox-url:
  geoip: https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.dat
  geosite: https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.dat
  mmdb: https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.metadb
  asn: https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/GeoLite2-ASN.mmdb
geo-auto-update: true
geo-update-interval: 24
sniffer:
  sniff:
    TLS:
      ports: [443]
      override-destination: true
    HTTP:
      ports: [443]
      override-destination: true
  enable: true
  parse-pure-ip: false
  force-dns-mapping: true
  override-destination: true
  skip-domain:
    - "+.lan"
ipv6: true
clash-for-android:
  append-system-dns: false
profile:
  tracing: true
  store-selected: true
experimental:
  sniff-tls-sni: true
dns:
  enable: true
  ipv6: true
  listen: '[::]:1053'
  use-hosts: true
  use-system-hosts: false
  enhanced-mode: redir-host
  prefer-h3: true
  cache-algorithm: arc
  respect-rules: false
  fallback:
    - "https://doh.opendns.com/dns-query"
    - "https://cloudflare-dns.com/dns-query"
    - "https://dns.google/dns-query"
  fallback-filter:
    geoip: true
    geoip-code: CN
    ipcidr:
      - "::/128"
      - "::1/128"
      - "2001::/32"
      - "0.0.0.0/8"
      - "10.0.0.0/8"
      - "100.64.0.0/10"
      - "127.0.0.0/8"
      - "169.254.0.0/16"
      - "172.16.0.0/12"
      - "192.0.0.0/24"
      - "192.0.2.0/24"
      - "192.88.99.0/24"
      - "192.168.0.0/16"
      - "198.18.0.0/15"
      - "198.51.100.0/24"
      - "203.0.113.0/24"
      - "224.0.0.0/4"
      - "240.0.0.0/4"
      - "255.255.255.255/32"
    domain:
      - "+.google.com"
      - "+.facebook.com"
      - "+.youtube.com"
      - "+.github.com"
      - "+.githubusercontent.com"
      - "+.googlevideo.com"
      - "+.msftconnecttest.com"
      - "+.msftncsi.com"
  nameserver-policy:
    "+.lan": 192.168.10.1:54
    '+.<own-domain>': [https://doh.opendns.com/dns-query, https://cloudflare-dns.com/dns-query, https://dns.google/dns-query]
    "dns.google": ["https://dns.alidns.com/dns-query", "https://doh.pub/dns-query"]
    "cloudflare-dns.com": ["https://dns.alidns.com/dns-query", "https://doh.pub/dns-query"]
    "doh.opendns.com": ["https://dns.alidns.com/dns-query", "https://doh.pub/dns-query"]
    "cdn.jsdelivr.net": ["https://dns.alidns.com/dns-query", "https://doh.pub/dns-query"]
    "ruleprovider:ls-private": ["https://dns.alidns.com/dns-query", "https://doh.pub/dns-query"]
    "ruleprovider:ls-direct": ["https://dns.alidns.com/dns-query", "https://doh.pub/dns-query"]
    "ruleprovider:ls-apple": ["https://dns.alidns.com/dns-query", "https://doh.pub/dns-query"]
    "ruleprovider:ls-icloud": ["https://dns.alidns.com/dns-query", "https://doh.pub/dns-query"]
    "ruleprovider:ls-google": ["https://dns.alidns.com/dns-query", "https://doh.pub/dns-query"]
    "ruleprovider:ls-gfw": ["https://doh.opendns.com/dns-query", "https://cloudflare-dns.com/dns-query", "https://dns.google/dns-query"]
  default-nameserver:
    - 223.5.5.5
    - 119.29.29.29
  proxy-server-nameserver:
    - https://223.5.5.5/dns-query
    - https://223.6.6.6/dns-query
  direct-nameserver:
    - https://223.5.5.5/dns-query
    - https://doh.pub/dns-query
  nameserver:
    - https://dns.alidns.com/dns-query
    - https://doh.pub/dns-query
  direct-nameserver-follow-policy: false
proxies: ~
proxy-groups: ~
hosts:
  '+.v.lan': 192.168.10.1
  0bc52bj2-10e0.aws-agent.org: bad18bj2-1f25.apt-agent.org
  e3585sh0-3ad5.aws-agent.org: 9a558sh8-8de9.apt-agent.org
  fd025gz8-c617.aws-agent.org: b36d5gz0-2ac1.apt-agent.org
rules:
  - RULE-SET,direct,DIRECT,no-resolve
  - RULE-SET,download,DL,no-resolve
  - RULE-SET,oversea,Oversea,no-resolve
  - RULE-SET,unlock,Unlock,no-resolve
  - GEOSITE,category-porn,Oversea
  - RULE-SET,proxy,Proxy,no-resolve
  - GEOSITE,category-games@cn,DIRECT
  - GEOSITE,youtube,YouTube
  - GEOSITE,category-ai-chat-!cn,OpenAI
  - GEOSITE,github,Proxy
  - GEOSITE,category-games,Proxy
  - IP-CIDR,172.110.32.0/21,YouTube,no-resolve
  - IP-CIDR,216.73.80.0/20,YouTube,no-resolve
  - IP-CIDR6,2620:120:e000::/40,YouTube,no-resolve
  - DOMAIN,p.bstarstatic.com,Bilibili
  - DOMAIN-SUFFIX,bilibili.tv,Bilibili
  - DOMAIN-SUFFIX,corari.com,Bilibili
  - DOMAIN-SUFFIX,im9.com,Bilibili
  - DOMAIN-SUFFIX,sharejoytech.com,Bilibili
  - DOMAIN-SUFFIX,yo9.com,Bilibili
  - PROCESS-NAME,com.bilibili.app.blue,Bilibili
  - PROCESS-NAME,com.bilibili.app.in,Bilibili
  - PROCESS-NAME,com.bilibili.comic,Bilibili
  - PROCESS-NAME,com.bilibili.comic.intl,Bilibili
  - PROCESS-NAME,tv.danmaku.bili,Bilibili
  - PROCESS-NAME,tv.danmaku.bilibilihd,Bilibili
  - IP-CIDR,106.75.74.76/32,Bilibili,no-resolve
  - IP-CIDR,111.206.25.147/32,Bilibili,no-resolve
  - IP-CIDR,119.3.238.64/32,Bilibili,no-resolve
  - IP-CIDR,120.92.108.182/32,Bilibili,no-resolve
  - IP-CIDR,120.92.113.99/32,Bilibili,no-resolve
  - IP-CIDR,120.92.153.217/32,Bilibili,no-resolve
  - IP-CIDR,134.175.207.130/32,Bilibili,no-resolve
  - IP-CIDR,203.107.1.0/24,Bilibili,no-resolve
  - IP-CIDR,116.211.202.206/32,Bilibili,no-resolve
  - IP-CIDR,116.211.202.216/32,Bilibili,no-resolve
  - DOMAIN-SUFFIX,spotilocal.com,Spotify
  - DOMAIN-KEYWORD,-spotify-,Spotify
  - DOMAIN-KEYWORD,spotify.com,Spotify
  - IP-CIDR,104.154.127.126/32,Spotify,no-resolve
  - IP-CIDR,35.186.224.47/32,Spotify,no-resolve
  - PROCESS-NAME,com.spotify.music,Spotify
  - DOMAIN-SUFFIX,f3b7q2p3.ssl.hwcdn.net,Steam
  - DOMAIN-SUFFIX,steamcontent.tnkjmec.com,Steam
  - DOMAIN-KEYWORD,steambroadcast,Steam
  - DOMAIN-KEYWORD,steamstore,Steam
  - DOMAIN-KEYWORD,steamuserimages,Steam
  - DOMAIN-SUFFIX,stel.com,Telegram
  - DOMAIN-KEYWORD,nicegram,Telegram
  - GEOIP,telegram,Telegram,no-resolve
  - PROCESS-NAME,nekox.messenger,Telegram
  - PROCESS-NAME,org.telegram.messenger,Telegram
  - PROCESS-NAME,telegram-desktop,Telegram
  - PROCESS-NAME,tw.nekomimi.nekogram,Telegram
  - PROCESS-NAME,xyz.nextalone.nagram,Telegram
  - DOMAIN-SUFFIX,adsensecustomsearchads.com,Google
  - DOMAIN-SUFFIX,adsenseformobileapps.com,Google
  - DOMAIN-SUFFIX,advertiserscommunity.com,Google
  - DOMAIN-SUFFIX,adwords-community.com,Google
  - DOMAIN-SUFFIX,adwords.com,Google
  - DOMAIN-SUFFIX,adwordsexpress.com,Google
  - DOMAIN-SUFFIX,app-measurement.net,Google
  - DOMAIN-SUFFIX,chromercise.com,Google
  - DOMAIN-SUFFIX,digitalattackmap.com,Google
  - DOMAIN-SUFFIX,doubleclick.com,Google
  - DOMAIN-SUFFIX,download.qatp1.net,Google
  - DOMAIN-SUFFIX,googleadapis.com,Google
  - DOMAIN-SUFFIX,monitoring.qpdp1.net,Google
  - DOMAIN-SUFFIX,neverware.com,Google
  - DOMAIN-SUFFIX,oasisfeng.com,Google
  - DOMAIN-SUFFIX,qagpublic.qatp1.net,Google
  - DOMAIN-SUFFIX,qgadmin.qcpp1.net,Google
  - DOMAIN-SUFFIX,qualysapi.qatp1.net,Google
  - DOMAIN-SUFFIX,qualysguard.qpdp1.net,Google
  - DOMAIN-SUFFIX,scanservice1.qcpp1.net,Google
  - DOMAIN-KEYWORD,appspot,Google
  - DOMAIN-KEYWORD,blogspot,Google
  - DOMAIN-KEYWORD,recaptcha,Google
  - GEOIP,google,Google,no-resolve
  - PROCESS-NAME,com.android.vending,Google
  - PROCESS-NAME,com.google.android.gms,Google
  - PROCESS-NAME,com.google.android.gsf,Google
  - PROCESS-NAME,com.google.android.play.games,Google
  - PROCESS-NAME,BackupandSync,Google
  - DOMAIN-SUFFIX,acompli.com,Microsoft
  - DOMAIN-SUFFIX,acompli.net,Microsoft
  - DOMAIN-SUFFIX,aicscience.com,Microsoft
  - DOMAIN-SUFFIX,assets-yammer.com,Microsoft
  - DOMAIN-SUFFIX,azure-apim.net,Microsoft
  - DOMAIN-SUFFIX,azurerms.com,Microsoft
  - DOMAIN-SUFFIX,bbing.com,Microsoft
  - DOMAIN-SUFFIX,bibg.com,Microsoft
  - DOMAIN-SUFFIX,biing.com,Microsoft
  - DOMAIN-SUFFIX,binb.com,Microsoft
  - DOMAIN-SUFFIX,binf.com,Microsoft
  - DOMAIN-SUFFIX,bing135.com,Microsoft
  - DOMAIN-SUFFIX,bing4.com,Microsoft
  - DOMAIN-SUFFIX,bingads.com,Microsoft
  - DOMAIN-SUFFIX,binginternal.com,Microsoft
  - DOMAIN-SUFFIX,bingit.net,Microsoft
  - DOMAIN-SUFFIX,bingiton.com,Microsoft
  - DOMAIN-SUFFIX,bingj.com,Microsoft
  - DOMAIN-SUFFIX,bingpix.com,Microsoft
  - DOMAIN-SUFFIX,bingpk.com,Microsoft
  - DOMAIN-SUFFIX,bings.com,Microsoft
  - DOMAIN-SUFFIX,bingtoolbar.com,Microsoft
  - DOMAIN-SUFFIX,bingtranslator.com,Microsoft
  - DOMAIN-SUFFIX,biying.com,Microsoft
  - DOMAIN-SUFFIX,cs11.wpc.v0cdn.net,Microsoft
  - DOMAIN-SUFFIX,cs9.wac.phicdn.net,Microsoft
  - DOMAIN-SUFFIX,discoverbing.com,Microsoft
  - DOMAIN-SUFFIX,dwh5.com,Microsoft
  - DOMAIN-SUFFIX,e-msedge.net,Microsoft
  - DOMAIN-SUFFIX,evoke-windowsservices-tas.msedge,Microsoft
  - DOMAIN-SUFFIX,explorebing.com,Microsoft
  - DOMAIN-SUFFIX,getmicrosoftkey.com,Microsoft
  - DOMAIN-SUFFIX,groupme.com,Microsoft
  - DOMAIN-SUFFIX,helpshift.com,Microsoft
  - DOMAIN-SUFFIX,here.com,Microsoft
  - DOMAIN-SUFFIX,here.net,Microsoft
  - DOMAIN-SUFFIX,hockeyapp.net,Microsoft
  - DOMAIN-SUFFIX,joinms.com,Microsoft
  - DOMAIN-SUFFIX,joinmva.com,Microsoft
  - DOMAIN-SUFFIX,localytics.com,Microsoft
  - DOMAIN-SUFFIX,lync.com,Microsoft
  - DOMAIN-SUFFIX,mapblast.com,Microsoft
  - DOMAIN-SUFFIX,mappoint.com,Microsoft
  - DOMAIN-SUFFIX,mesh.com,Microsoft
  - DOMAIN-SUFFIX,microsoft-tst.com,Microsoft
  - DOMAIN-SUFFIX,microsoft.com.nsatc.net,Microsoft
  - DOMAIN-SUFFIX,microsoftads.com,Microsoft
  - DOMAIN-SUFFIX,microsoftemail.com,Microsoft
  - DOMAIN-SUFFIX,microsoftestore.com.hk,Microsoft
  - DOMAIN-SUFFIX,microsoftol.com,Microsoft
  - DOMAIN-SUFFIX,microsoftonline-p.net,Microsoft
  - DOMAIN-SUFFIX,microsoftusercontent.com,Microsoft
  - DOMAIN-SUFFIX,msads.net,Microsoft
  - DOMAIN-SUFFIX,msappproxy.net,Microsoft
  - DOMAIN-SUFFIX,msauthimages.net,Microsoft
  - DOMAIN-SUFFIX,msftidentity.com,Microsoft
  - DOMAIN-SUFFIX,msignitechina.com,Microsoft
  - DOMAIN-SUFFIX,msn.com.nsatc.net,Microsoft
  - DOMAIN-SUFFIX,msnmaps.com,Microsoft
  - DOMAIN-SUFFIX,msvevent.com,Microsoft
  - DOMAIN-SUFFIX,msxiaobing.com,Microsoft
  - DOMAIN-SUFFIX,msxiaoice.com,Microsoft
  - DOMAIN-SUFFIX,myhomemsn.com,Microsoft
  - DOMAIN-SUFFIX,oaspapps.com,Microsoft
  - DOMAIN-SUFFIX,officeppe.net,Microsoft
  - DOMAIN-SUFFIX,onecollector.cloudapp.aria,Microsoft
  - DOMAIN-SUFFIX,onmicrosoft.com,Microsoft
  - DOMAIN-SUFFIX,optimizely.com,Microsoft
  - DOMAIN-SUFFIX,osdinfra.net,Microsoft
  - DOMAIN-SUFFIX,outlookmobile.com,Microsoft
  - DOMAIN-SUFFIX,phonefactor.net,Microsoft
  - DOMAIN-SUFFIX,playfabcn.com,Microsoft
  - DOMAIN-SUFFIX,renlifang.com,Microsoft
  - DOMAIN-SUFFIX,sclive.net,Microsoft
  - DOMAIN-SUFFIX,skypeforbusiness.com,Microsoft
  - DOMAIN-SUFFIX,sway-extensions.com,Microsoft
  - DOMAIN-SUFFIX,uservoice.com,Microsoft
  - DOMAIN-SUFFIX,vip5.afdorigin-prod-am02.afdogw.com,Microsoft
  - DOMAIN-SUFFIX,windows-ppe.net,Microsoft
  - DOMAIN-SUFFIX,wlxrs.com,Microsoft
  - DOMAIN-SUFFIX,working-bing-int.com,Microsoft
  - DOMAIN-SUFFIX,wunderlist.com,Microsoft
  - DOMAIN-SUFFIX,yammerusercontent.com,Microsoft
  - DOMAIN-KEYWORD,onedrive,Microsoft
  - DOMAIN-KEYWORD,skydrive,Microsoft
  - PROCESS-NAME,OneDrive,Microsoft
  - PROCESS-NAME,OneDriveUpdater,Microsoft
  - IP-CIDR,160.79.104.0/21,OpenAI,no-resolve
  - IP-CIDR6,2607:6BC0::/32,OpenAI,no-resolve
  - IP-CIDR,24.199.123.28/32,OpenAI,no-resolve
  - IP-CIDR,64.23.132.171/32,OpenAI,no-resolve
  - DOMAIN-SUFFIX,paypal-mktg.com,PayPal
  - DOMAIN-KEYWORD,paypal,PayPal
  - DOMAIN-SUFFIX,appstore.com,Apple
  - DOMAIN-KEYWORD,apple.com.akadns.net,Apple
  - DOMAIN-KEYWORD,apple.com.edgekey.net,Apple
  - DOMAIN-KEYWORD,apple-support.akadns.net,Apple
  - DOMAIN-KEYWORD,icloud.com.akadns.net,Apple
  - DOMAIN-KEYWORD,testflight,Apple
  - IP-CIDR,139.178.128.0/18,Apple,no-resolve
  - IP-CIDR,144.178.0.0/19,Apple,no-resolve
  - IP-CIDR,144.178.36.0/22,Apple,no-resolve
  - IP-CIDR,144.178.48.0/20,Apple,no-resolve
  - IP-CIDR,17.0.0.0/8,Apple,no-resolve
  - IP-CIDR,192.35.50.0/24,Apple,no-resolve
  - IP-CIDR,198.183.17.0/24,Apple,no-resolve
  - IP-CIDR,205.180.175.0/24,Apple,no-resolve
  - IP-CIDR,63.92.224.0/19,Apple,no-resolve
  - IP-CIDR,65.199.22.0/23,Apple,no-resolve
  - PROCESS-NAME,LookupViewService,Apple
  - PROCESS-NAME,storedownloadd,Apple
  - PROCESS-NAME,Music,Apple
  - PROCESS-NAME,News,Apple
  - PROCESS-NAME,TV,Apple
  - IP-CIDR,13.32.0.0/15,Proxy,no-resolve
  - IP-CIDR,13.35.0.0/17,Proxy,no-resolve
  - IP-CIDR,18.184.0.0/15,Proxy,no-resolve
  - IP-CIDR,18.194.0.0/15,Proxy,no-resolve
  - IP-CIDR,18.208.0.0/13,Proxy,no-resolve
  - IP-CIDR,18.232.0.0/14,Proxy,no-resolve
  - IP-CIDR,52.200.0.0/13,Proxy,no-resolve
  - IP-CIDR,52.58.0.0/15,Proxy,no-resolve
  - IP-CIDR,52.74.0.0/16,Proxy,no-resolve
  - IP-CIDR,52.77.0.0/16,Proxy,no-resolve
  - IP-CIDR,52.84.0.0/15,Proxy,no-resolve
  - IP-CIDR,54.156.0.0/14,Proxy,no-resolve
  - IP-CIDR,54.226.0.0/15,Proxy,no-resolve
  - IP-CIDR,54.230.156.0/22,Proxy,no-resolve
  - IP-CIDR,54.93.0.0/16,Proxy,no-resolve
  - PROCESS-NAME,com.amazon.avod.thirdpartyclient,Proxy
  - IP-CIDR,103.2.30.0/23,Proxy,no-resolve
  - IP-CIDR,125.209.208.0/20,Proxy,no-resolve
  - IP-CIDR,147.92.128.0/17,Proxy,no-resolve
  - IP-CIDR,203.104.144.0/21,Proxy,no-resolve
  - IP-CIDR,109.239.140.0/24,Proxy,no-resolve
  - IP-CIDR,5.28.195.163/32,Proxy,no-resolve
  - IP-CIDR,5.28.195.205/32,Proxy,no-resolve
  - IP-CIDR,5.28.195.37/32,Proxy,no-resolve
  - IP-CIDR,91.108.0.0/16,Proxy,no-resolve
  - IP-CIDR,182.254.116.0/24,DIRECT,no-resolve
  - IP-CIDR,203.205.238.0/23,DIRECT,no-resolve
  - IP-CIDR,203.205.254.0/23,DIRECT,no-resolve
  - RULE-SET,ls-private,DIRECT
  - RULE-SET,ls-apple,DIRECT
  - RULE-SET,ls-icloud,DIRECT
  - RULE-SET,ls-google,DIRECT
  - RULE-SET,ls-direct,DIRECT
  - RULE-SET,ls-proxy,Proxy
  - RULE-SET,ls-gfw,Proxy
  - RULE-SET,ls-tld-not-cn,Proxy
  - RULE-SET,ls-telegramcidr,Proxy,no-resolve
  - RULE-SET,ls-lancidr,DIRECT,no-resolve
  - RULE-SET,ls-cncidr,DIRECT,no-resolve
  - GEOIP,CN,DIRECT,no-resolve
  - IP-CIDR,192.168.0.0/16,DIRECT,no-resolve
  - IP-CIDR,10.0.0.0/8,DIRECT,no-resolve
  - IP-CIDR,172.16.0.0/12,DIRECT,no-resolve
  - IP-CIDR,127.0.0.0/8,DIRECT,no-resolve
  - IP-CIDR,100.64.0.0/10,DIRECT,no-resolve
  - IP-CIDR6,::1/128,DIRECT,no-resolve
  - IP-CIDR6,fc00::/7,DIRECT,no-resolve
  - IP-CIDR6,fe80::/10,DIRECT,no-resolve
  - IP-CIDR6,fd00::/8,DIRECT,no-resolve
  - MATCH,Final
listeners:
  - name: trojan-home
    type: trojan
    listen: "::"
    port: 8444
    users:
      - username: home
        password: "<trojan-password>"
    certificate: "/etc/ssl/lucky/<own-domain>.pem"
    private-key: "/etc/ssl/lucky/<own-domain>.key"
    proxy: DIRECT
rule-providers:
  ls-direct:
    type: http
    format: yaml
    behavior: domain
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/direct.txt"
    path: rules/ls-direct.txt
    interval: 86400
  ls-proxy:
    type: http
    format: yaml
    behavior: domain
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/proxy.txt"
    path: rules/ls-proxy.txt
    interval: 86400
  ls-private:
    type: http
    format: yaml
    behavior: domain
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/private.txt"
    path: rules/ls-private.txt
    interval: 86400
  ls-apple:
    type: http
    format: yaml
    behavior: domain
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/apple.txt"
    path: rules/ls-apple.txt
    interval: 86400
  ls-icloud:
    type: http
    format: yaml
    behavior: domain
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/icloud.txt"
    path: rules/ls-icloud.txt
    interval: 86400
  ls-google:
    type: http
    format: yaml
    behavior: domain
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/google.txt"
    path: rules/ls-google.txt
    interval: 86400
  ls-gfw:
    type: http
    format: yaml
    behavior: domain
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/gfw.txt"
    path: rules/ls-gfw.txt
    interval: 86400
  ls-tld-not-cn:
    type: http
    format: yaml
    behavior: domain
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/tld-not-cn.txt"
    path: rules/ls-tld-not-cn.txt
    interval: 86400
  direct:
    type: http
    url: https://cdn.jsdelivr.net/gh/cruise711808/custom-rules@main/ruleset/clash/direct.list
    size_limit: "0"
    format: text
    behavior: domain
    path: rules/direct.list
    interval: "86400"
  proxy:
    type: http
    url: https://cdn.jsdelivr.net/gh/cruise711808/custom-rules@main/ruleset/clash/proxy.list
    size_limit: "0"
    format: text
    behavior: domain
    path: rules/proxy.list
    interval: "86400"
  unlock:
    type: http
    url: https://cdn.jsdelivr.net/gh/cruise711808/custom-rules@main/ruleset/clash/unlock.list
    size_limit: "0"
    format: text
    behavior: domain
    path: rules/unlock.list
    interval: "86400"
  download:
    type: http
    url: https://cdn.jsdelivr.net/gh/cruise711808/custom-rules@main/ruleset/clash/download.list
    format: text
    behavior: domain
    path: rules/download.list
    interval: "86400"
  oversea:
    type: http
    url: https://cdn.jsdelivr.net/gh/cruise711808/custom-rules@main/ruleset/clash/oversea.list
    format: text
    behavior: domain
    path: rules/oversea.list
    interval: "86400"
  ls-telegramcidr:
    type: http
    format: yaml
    behavior: ipcidr
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/telegramcidr.txt"
    path: rules/ls-telegramcidr.txt
    interval: 86400
  ls-lancidr:
    type: http
    format: yaml
    behavior: ipcidr
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/lancidr.txt"
    path: rules/ls-lancidr.txt
    interval: 86400
  ls-cncidr:
    type: http
    format: yaml
    behavior: ipcidr
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/cncidr.txt"
    path: rules/ls-cncidr.txt
    interval: 86400
find-process-mode: off
external-ui: ui
external-ui-url: https://github.com/Zephyruso/zashboard/releases/latest/download/dist-cdn-fonts.zip
tproxy-port: 7892
tun:
  enable: true
  device: nikki
  stack: mips
  auto-route: false
  auto-redirect: false
  auto-detect-interface: false
  disable-icmp-forwarding: true
