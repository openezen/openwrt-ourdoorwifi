-- Copyright 2011 Jo-Philipp Wich <jow@openwrt.org>
-- Licensed to the public under the Apache License 2.0.

local map, section, net = ...

local device, apn, service, pincode, username, password, dialnumber
local ipv6, maxwait, defaultroute, metric, peerdns, dns,
      keepalive_failure, keepalive_interval, demand
local simcard

local simnum = luci.sys.get_simcard_num()

device = section:taboption("general", Value, "device", translate("Modem device"))
device.rmempty = false
device.default="/dev/ttyUSB2"

local device_suggestions = nixio.fs.glob("/dev/ttyUSB*")
	or nixio.fs.glob("/dev/tts/*")

if device_suggestions then
	local node
	for node in device_suggestions do
		device:value(node)
	end
end
if simnum >= 2 then
	simcard = section:taboption("general", ListValue, "sim", translate("Active SIM Card"))
	simcard.default="0"
	simcard:value("0", translate("Primary SIM1"))
	simcard:value("1", translate("Secondary SIM2"))

	simauto = section:taboption("general", Flag, "simauto", translate("Auto Switch SIM card"), translate("Become effective when disable mwan3"))
	simauto.default = false

	section:tab("primary",  translate("Primary SIM1"))
	section:tab("secondary",  translate("Secondary SIM2"))

	service1 = section:taboption("primary", Value, "service1", translate("Service Type"))
	service1:value("", translate("-- Please choose --"))
	service1:value("umts", "UMTS/GPRS")
	service1:value("umts_only", translate("UMTS only"))
	service1:value("gprs_only", translate("GPRS only"))
	service1:value("evdo", "CDMA/EV-DO")
	apn1 = section:taboption("primary", Value, "apn1", translate("APN"))
	pincode1 = section:taboption("primary", Value, "pincode1", translate("PIN"))
	username1 = section:taboption("primary", Value, "username1", translate("PAP/CHAP username"))
	password1 = section:taboption("primary", Value, "password1", translate("PAP/CHAP password"))
	password1.password = true
	dialnumber1 = section:taboption("primary", Value, "dialnumber1", translate("Dial number"))
	dialnumber1.placeholder = "*99***1#"

	service2 = section:taboption("secondary", Value, "service2", translate("Service Type"))
	service2:value("", translate("-- Please choose --"))
	service2:value("umts", "UMTS/GPRS")
	service2:value("umts_only", translate("UMTS only"))
	service2:value("gprs_only", translate("GPRS only"))
	service2:value("evdo", "CDMA/EV-DO")
	apn2 = section:taboption("secondary", Value, "apn2", translate("APN"))
	pincode2 = section:taboption("secondary", Value, "pincode2", translate("PIN"))
	username2 = section:taboption("secondary", Value, "username2", translate("PAP/CHAP username"))
	password2 = section:taboption("secondary", Value, "password2", translate("PAP/CHAP password"))
	password2.password = true
	dialnumber2 = section:taboption("secondary", Value, "dialnumber2", translate("Dial number"))
	dialnumber2.placeholder = "*99***1#"
else
	service = section:taboption("general", Value, "service", translate("Service Type"))
	service:value("", translate("-- Please choose --"))
	service:value("umts", "UMTS/GPRS")
	service:value("umts_only", translate("UMTS only"))
	service:value("gprs_only", translate("GPRS only"))
	service:value("evdo", "CDMA/EV-DO")
	apn = section:taboption("general", Value, "apn", translate("APN"))
	pincode = section:taboption("general", Value, "pincode", translate("PIN"))
	username = section:taboption("general", Value, "username", translate("PAP/CHAP username"))
	password = section:taboption("general", Value, "password", translate("PAP/CHAP password"))
	password.password = true
	dialnumber = section:taboption("general", Value, "dialnumber", translate("Dial number"))
	dialnumber.placeholder = "*99***1#"
end

if luci.model.network:has_ipv6() then

	ipv6 = section:taboption("advanced", ListValue, "ipv6")
	ipv6:value("auto", translate("Automatic"))
	ipv6:value("0", translate("Disabled"))
	ipv6:value("1", translate("Manual"))
	ipv6.default = "auto"

end


maxwait = section:taboption("advanced", Value, "maxwait",
	translate("Modem init timeout"),
	translate("Maximum amount of seconds to wait for the modem to become ready"))

maxwait.placeholder = "20"
maxwait.datatype    = "min(1)"


defaultroute = section:taboption("advanced", Flag, "defaultroute",
	translate("Use default gateway"),
	translate("If unchecked, no default route is configured"))

defaultroute.default = defaultroute.enabled


metric = section:taboption("advanced", Value, "metric",
	translate("Use gateway metric"))

metric.placeholder = "0"
metric.datatype    = "uinteger"
metric:depends("defaultroute", defaultroute.enabled)


peerdns = section:taboption("advanced", Flag, "peerdns",
	translate("Use DNS servers advertised by peer"),
	translate("If unchecked, the advertised DNS server addresses are ignored"))

peerdns.default = peerdns.enabled


dns = section:taboption("advanced", DynamicList, "dns",
	translate("Use custom DNS servers"))

dns:depends("peerdns", "")
dns.datatype = "ipaddr"
dns.cast     = "string"


keepalive_failure = section:taboption("advanced", Value, "_keepalive_failure",
	translate("LCP echo failure threshold"),
	translate("Presume peer to be dead after given amount of LCP echo failures, use 0 to ignore failures"))

function keepalive_failure.cfgvalue(self, section)
	local v = m:get(section, "keepalive")
	if v and #v > 0 then
		return tonumber(v:match("^(%d+)[ ,]+%d+") or v)
	end
end

function keepalive_failure.write() end
function keepalive_failure.remove() end

keepalive_failure.placeholder = "0"
keepalive_failure.datatype    = "uinteger"


keepalive_interval = section:taboption("advanced", Value, "_keepalive_interval",
	translate("LCP echo interval"),
	translate("Send LCP echo requests at the given interval in seconds, only effective in conjunction with failure threshold"))

function keepalive_interval.cfgvalue(self, section)
	local v = m:get(section, "keepalive")
	if v and #v > 0 then
		return tonumber(v:match("^%d+[ ,]+(%d+)"))
	end
end

function keepalive_interval.write(self, section, value)
	local f = tonumber(keepalive_failure:formvalue(section)) or 0
	local i = tonumber(value) or 5
	if i < 1 then i = 1 end
	if f > 0 then
		m:set(section, "keepalive", "%d %d" %{ f, i })
	else
		m:del(section, "keepalive")
	end
end

keepalive_interval.remove      = keepalive_interval.write
keepalive_interval.placeholder = "5"
keepalive_interval.datatype    = "min(1)"


demand = section:taboption("advanced", Value, "demand",
	translate("Inactivity timeout"),
	translate("Close inactive connection after the given amount of seconds, use 0 to persist connection"))

demand.placeholder = "0"
demand.datatype    = "uinteger"
