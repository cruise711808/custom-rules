mixed-port: 7890
allow-lan: false
mode: rule
log-level: warning
ipv6: false
unified-delay: true
tcp-concurrent: true
geox-url:
  geoip: https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.dat
  geosite: https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.dat
  mmdb: https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.metadb
  asn: https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/GeoLite2-ASN.mmdb
geo-auto-update: true
geo-update-interval: 24

profile:
  store-rules: true

tun:
  enable: true
  stack: system
  auto-route: true
  auto-detect-interface: true
  dns-hijack:
    - any:53

dns:
  enable: true
  ipv6: false
  enhanced-mode: redir-host
  listen: 127.0.0.1:1053
  default-nameserver:
    - 223.5.5.5
    - 119.29.29.29
  nameserver:
    - 192.168.10.1:1053
    - 223.5.5.5

rules:
  - DOMAIN-SUFFIX,lan,DIRECT
  - IP-CIDR,192.168.0.0/16,DIRECT,no-resolve
  - IP-CIDR,10.0.0.0/8,DIRECT,no-resolve
  - IP-CIDR,172.16.0.0/12,DIRECT,no-resolve
  - IP-CIDR,100.64.0.0/10,DIRECT,no-resolve
  - RULE-SET,direct,DIRECT,no-resolve
  - RULE-SET,download,DL,no-resolve
  - RULE-SET,unlock,Unlock,no-resolve
  - RULE-SET,oversea,Oversea,no-resolve
  - GEOSITE,category-porn,Oversea
  - RULE-SET,proxy,Proxy,no-resolve
  - GEOSITE,category-games@cn,DIRECT
  - GEOSITE,youtube,Proxy
  - GEOSITE,category-ai-chat-!cn,Proxy
  - GEOSITE,github,Proxy
  - GEOSITE,category-games,Proxy
  - GEOIP,CN,DIRECT
  - MATCH,Final

proxies:
  - name: Home-Trojan
    type: trojan
    server: <own-domain>
    port: 8444
    password: REPLACE_ME
    sni: <own-domain>
    udp: true

proxy-groups:
  - name: Proxy
    type: select
    include-all: true
    proxies:
      - Home-Trojan
      - DIRECT
  - name: DL
    type: select
    proxies:
      - DIRECT
      - Proxy
  - name: Final
    type: select
    proxies:
      - Proxy
      - DIRECT
  - name: Unlock
    type: select
    include-all: true
    proxies:
      - Proxy
      - DIRECT
  - name: Oversea
    type: select
    include-all: true
    proxies:
      - Proxy

rule-providers:
  direct:
    type: http
    format: text
    behavior: classical
    url: https://cdn.jsdelivr.net/gh/cruise711808/custom-rules@main/ruleset/clash/direct.list
    path: rulesets/direct.list
    interval: 86400
  download:
    type: http
    format: text
    behavior: classical
    url: https://cdn.jsdelivr.net/gh/cruise711808/custom-rules@main/ruleset/clash/download.list
    path: rulesets/download.list
    interval: 86400
  unlock:
    type: http
    format: text
    behavior: classical
    url: https://cdn.jsdelivr.net/gh/cruise711808/custom-rules@main/ruleset/clash/unlock.list
    path: rulesets/unlock.list
    interval: 86400
  oversea:
    type: http
    format: text
    behavior: classical
    url: https://cdn.jsdelivr.net/gh/cruise711808/custom-rules@main/ruleset/clash/oversea.list
    path: rulesets/oversea.list
    interval: 86400
  proxy:
    type: http
    format: text
    behavior: classical
    url: https://cdn.jsdelivr.net/gh/cruise711808/custom-rules@main/ruleset/clash/proxy.list
    path: rulesets/proxy.list
    interval: 86400
