# custom-rules — nikki router 订阅转换管线

> 仓库纪律：**配置里（tpl/ini）不准乱注释，不准记决策内容**——本文件即仓库主文档（README.md 按约定留空）。
> 本文件只写结构、流程、原则：**不准写决策过程、本机路径、实体信息**（真值唯一维护点=`config\local.ini`）。

## 管线

订阅链接 → subconverter 本地转换 → 路由器 profile（mihomo yaml）+ 手机 Surfboard conf → 上传路由器生效。

- 三端模板同套五类分流（direct / download / unlock / oversea / proxy）：路由器 mihomo、Windows mihomo(Verge)、安卓 Surfboard（Surge 格式）。模板命名 `Role_Tool_Platform`。
- 组显示顺序定版：**Proxy > Final > Unlock > Oversea > 其余服务组 > 区域组 > DL**；规则/组/类目任何变更三端一起过。
- DNS 原则=解析即分流：境内本地解析、境外节点侧解析；家名/自身域名/v.lan 静态钉真址。路由器=redir-host，手机 Surfboard=内置 fake-ip（关不掉）。
- Home-Trojan 回家：trojan → lucky :8443（TLS 前置）→ mihomo listener :8444；手机 [Rule] 顶部三条规则直接以节点名出站（自身域名 DIRECT 防回环、v.lan、家网段）。

## 部件

| 位置 | 作用 |
|---|---|
| `template\Server_Clash_Linux.tpl` / `.ini` | 路由器 mihomo 基底模板（dns/listeners/rule-providers/rules）+ 分组定义（regex 建组：区域/SP/Proxy/DL/服务组/Final） |
| `template\Client_Clash_Windows.tpl` | Windows 客户端模板（同款分流，节点直连） |
| `template\Client_Surfboard_Android.tpl` / `.ini` | 手机模板（只留 [General]/[Rule]，节点与组全由生成器注入）+ 手机转换配置 |
| `config\generate.ini` / `generate_client.ini` | 转换任务定义（不入库，样板 `.example`） |
| `config\local.ini` | **全线真值唯一维护点**（不入库，样板 `.example`）：`own_domain` / `home_trojan_host` / `home_trojan_port` / `home_trojan_password` / `home_lan_cidr` / `home_router_ip` |
| `scripts\refresh.ps1` | 路由器一键转换：subconverter 生成 → local.ini 真值混入（缺失即 throw）→ proxy-groups 按定版重排 |
| `scripts\refresh_client.ps1` | 手机一键转换：生成 → 注入 [Host]（DNS 分流）+ Home-Trojan + [Rule] 顶部三条 → 组显示排序 |
| 产物 `mihomo.yaml` / `surfboard_mobile.conf` | 路由器 profile / 手机导入文件（在 subconverter 的 `output\`） |

## 怎么转换

```powershell
powershell -ExecutionPolicy Bypass -File scripts\refresh.ps1          # 路由器 -> output\mihomo.yaml
powershell -ExecutionPolicy Bypass -File scripts\refresh_client.ps1   # 手机   -> output\surfboard_mobile.conf
```

1. 订阅链接 10 分钟有效、一次性：面板生成新链接后换 `generate.ini` 的 `url=`；不等新链接时 `url=` 可指本地订阅文件。
2. 产物经 ssh 管道上传路由器 profile（nobody 可写），`mihomo -t` 校验后重启 nikki；路由器不留备份，回滚=重传产物。
3. 自己列表（ruleset/clash/*.list）改动要 push 到 main，客户端才从 jsdelivr 取得到。

## 真值与占位

- 公开仓库只出现 `<own-domain>` / `<trojan-password>` / `REPLACE_ME`，真值永不进 git；混入发生在生成之后（refresh 脚本替换）。
- 路由器 mixin 不用（uci 关闭）：listener 口令/证书路径与 `+.<own-domain>` DNS pin 都在 tpl，随 profile 落地。

## 坑（改动前必读）

1. `clash_rule_base` 只能写 `base/xxx.tpl` 相对路径（绝对路径会吞掉 rules 之后的段）。
2. tpl 必须 LF 行尾、`proxy-groups: ~` 占位符保留（subconverter 注入点）。
3. 升级 subconverter.exe 后要重打 UA 头补丁（订阅端 WAF 对其默认请求头必 403）。
4. 一个 generate.ini 只认第一个 section 的 `url=`（路由器/手机各自一份，脚本互换）。
5. 模板 `[Proxy]`/`[Proxy Group]` 段会被生成器整段重写（静态节点/组由脚本注入）；Surfboard trojan 行必须命名式 `password=`；`skip-proxy` 优先于 [Rule]，要按规则分流的网段不能进 skip-proxy。
