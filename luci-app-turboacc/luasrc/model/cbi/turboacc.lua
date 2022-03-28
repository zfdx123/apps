local kernel_version = luci.sys.exec("echo -n $(uname -r)")

m = Map("turboacc")
m.title	= translate("Turbo ACC 网络加速设置")
m.description = translate("流量分载驱动 硬件 NAT")

m:append(Template("turboacc/turboacc_status"))

s = m:section(TypedSection, "turboacc", "")
s.addremove = false
s.anonymous = true

if nixio.fs.access("/lib/modules/" .. kernel_version .. "/xt_FLOWOFFLOAD.ko") then
sw_flow = s:option(Flag, "sw_flow", translate("软件流量分载"))
sw_flow.default = 0
sw_flow.description = translate("基于软件的 Routing/NAT 分载")
sw_flow:depends("sfe_flow", 0)
end

if luci.sys.call("cat /proc/cpuinfo | grep -q MT76") == 0 then
hw_flow = s:option(Flag, "hw_flow", translate("硬件流量分载"))
hw_flow.default = 0
hw_flow.description = translate("需要硬件 NAT 支持。目前 mt76xx 已实现")
hw_flow:depends("sw_flow", 1)
end

if nixio.fs.access("/lib/modules/" .. kernel_version .. "/tcp_bbr.ko") then
bbr_cca = s:option(Flag, "bbr_cca", translate("BBR 拥塞控制算法"))
bbr_cca.default = 0
bbr_cca.description = translate("使用 BBR 拥塞控制算法可以有效提升 TCP 网络性能")
end 

if nixio.fs.access("/lib/modules/" .. kernel_version .. "/xt_FULLCONENAT.ko") then
fullcone_nat = s:option(Flag, "fullcone_nat", translate("全锥形 NAT"))
fullcone_nat.default = 0
fullcone_nat.description = translate("使用全锥形 NAT 可以有效提升游戏体验")
end 

dns_caching = s:option(Flag, "dns_caching", translate("DNS 缓存"))
dns_caching.default = 0
dns_caching.rmempty = false
dns_caching.description = translate("启用 DNS 多线程查询、缓存，并防止 ISP 的 DNS 广告和域名劫持")

dns_caching_mode = s:option(ListValue, "dns_caching_mode", translate("DNS 解析方式"), translate("DNS 解析程序"))
dns_caching_mode:value("1", translate("使用 PDNSD 解析"))
if nixio.fs.access("/usr/bin/dnsproxy") then
dns_caching_mode:value("2", translate("使用 DNSProxy 解析"))
end
dns_caching_mode.default = 1
dns_caching_mode:depends("dns_caching", 1)

dns_caching_dns = s:option(Value, "dns_caching_dns", translate("上游 DNS 服务器"))
dns_caching_dns.default = "114.114.114.114,114.114.115.115,223.5.5.5,223.6.6.6,180.76.76.76,119.29.29.29,119.28.28.28,1.2.4.8,210.2.4.8"
dns_caching_dns.description = translate("多个上游 DNS 服务器请用 ',' 分隔（注意用英文逗号)")
dns_caching_dns:depends("dns_caching", 1)

return m
