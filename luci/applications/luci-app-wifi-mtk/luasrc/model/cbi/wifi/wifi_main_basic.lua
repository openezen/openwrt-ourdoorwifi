--[[
tittle: wifi UI
author: xiaguohua
date: 2014/6/26
]]--
require("luci.tools.webadmin")
require("luci.model.network")
require "luci.sys"

local m = Map("wireless")


s = m:section(NamedSection, "main", "wifi-iface",  translate("2.4G"))
s.addremove = false


mac = s:option(DummyValue, "macaddr", translate("MAC Address"))
mac.cfgvalue = function(self, section)
	local macaddr=luci.util.exec("cat /sys/class/net/ra0/address")
	if macaddr then
		return macaddr
	else
		return "none"
	end
end 


disable = s:option(Flag, "disabled", translate("Disable"))
disable.rmempty = false


ssid = s:option(Value, "ssid", "SSID", translate("The length of WI-Fi SSID should less than 32 characters."))
ssid.rmempty = false
ssid.validate = function(self, value, section)
	if value and #value <= 32 then
		return value
	end
	return nil
end 

encrypt = s:option(ListValue, "encryption", translate("Encrypt Type"))
encrypt:value("none", translate("No Encrypt"))
encrypt:value("wep-shared", translate("WEP"))
encrypt:value("psk", "WPA-PSK")
encrypt:value("psk2", "WPA2-PSK")
encrypt:value("psk+psk2", "WPA-PSK/WPA2-PSK")
encrypt.default = "none"

cipher = s:option(ListValue, "cipher", translate("Cipher"))
cipher:depends({encryption="psk"})
cipher:depends({encryption="psk2"})
cipher:depends({encryption="psk+psk2"})
cipher:value("ccmp", "AES")
cipher:value("tkip", "TKIP")
cipher:value("tkip+ccmp", "TKIP/AES")
cipher.default = "tkip+ccmp"

wepkey = s:option(Value, "key1", translate("Key"), translate("Composed of letters,numbers and most of special letters, the length range is 5 to 13"))
wepkey:depends("encryption", "wep-shared")
wepkey.datatype = "wepkey"
wepkey.validate = function(self, value, section)
	if value and value:match("^[a-zA-Z0-9!@#_%~%$%%%^%&%*%(%%)%-%+%=%.%,%;%:%{%}%[%]%|%>%<%?%'%`]+$") then
		return value
	end
	return nil
end 

--key1type = s:option(Value, "key", translate("Key"))
--key1type.default = "1"
--key1type.hidden = true
--key1type:depends("encryption", "wep-shared")

wpakey = s:option(Value, "key", translate("Key"), translate("Composed of letters,numbers and most of special letters, the length range is 8 to 63"))
wpakey.datatype = "wpakey"
wpakey:depends("encryption", "psk")
wpakey:depends("encryption", "psk2")
wpakey:depends("encryption", "psk+psk2")
wpakey.validate = function(self, value, section)
	if value and value:match("^[a-zA-Z0-9!@#_%~%$%%%^%&%*%(%%)%-%+%=%.%,%;%:%{%}%[%]%|%>%<%?%'%`]+$") then
		return value
	end
	return nil
end 

if luci.verctrl.module_status("ssid_bridge")  then
	if string.match(version, "(%d)\.%d\.%d") == "4" then
		lanintf = s:option(ListValue, "network", translate("Bind Interface"))
		if luci.verctrl.module_status("lan_display")  then
			luci.tools.webadmin.cbi_add_lan_networks(lanintf)
			luci.tools.webadmin.cbi_add_vlan_networks(lanintf)
		end
		luci.tools.webadmin.cbi_add_wan_networks(lanintf)
		lanintf.optional = false
		lanintf.rmempty = false
		if luci.verctrl.module_status("lan_display")  then
			lanintf.default = "lan"
		else
			lanintf.default = "wan"
		end
	end
end

function m.on_parse(map)
	local enc = encrypt:formvalue("main")
	if enc == "wep" then
		wepkey.rmempty = false
	elseif enc == "psk" or enc == "psk2" or enc == "psk+psk2" then
		wpakey.rmempty = false
	else
		wepkey.rmempty = true
		wpakey.rmempty = true
	end
	if have_wifi_5G and have_wifi_5G ~= '0' then
		local enc5g = encrypt:formvalue("main_5g")
		if enc5g == "wep" then
			wepkey5g.rmempty = false
		elseif enc5g == "psk" or enc5g == "psk2" or enc5g == "psk+psk2" then
			wpakey5g.rmempty = false
		else
			wepkey5g.rmempty = true
			wpakey5g.rmempty = true
		end
	end
end

kick = s:option(Value, "kickthres", translate("Kickout Threshold"),translate("Set 0 to disable kickout"))
kick:value("0", translate("Disable Kickout"))
kick:value("-75", translatef("Less than %s dBm", "-75"))
kick:value("-78", translatef("Less than %s dBm", "-78"))
kick:value("-80", translatef("Less than %s dBm", "-80"))
kick:value("-83", translatef("Less than %s dBm", "-83"))
kick:value("-85", translatef("Less than %s dBm", "-85"))
kick:value("-88", translatef("Less than %s dBm", "-88"))
kick:value("-90", translatef("Less than %s dBm", "-90"))
kick:value("-95", translatef("Less than %s dBm", "-95"))
kick.default = "0"
kick.datatype = "range(-100, 0)"

reject = s:option(Value, "assocthres", translate("Weak signal rejection threshold"),translate("Set 0 to disable weak signal rejection"))
reject:value("0", translate("Disable weak signal rejection"))
reject:value("-75", translatef("Less than %s dBm", "-75"))
reject:value("-78", translatef("Less than %s dBm", "-78"))
reject:value("-80", translatef("Less than %s dBm", "-80"))
reject:value("-83", translatef("Less than %s dBm", "-83"))
reject:value("-85", translatef("Less than %s dBm", "-85"))
reject:value("-88", translatef("Less than %s dBm", "-88"))
reject:value("-90", translatef("Less than %s dBm", "-90"))
reject:value("-95", translatef("Less than %s dBm", "-95"))
reject.default = "0"
reject.datatype = "range(-100, 0)"

local ap_mode = luci.sys.sys_is_ap_mode()
if ap_mode ~= 1 then
	qos = s:option(Flag, "qos_enable", translate("Qos Enable"))

	download = s:option(Value, "downlimit", translate("Download limit"), translate("KB/s"))
	download:depends("qos_enable", "1")
	download.default = "3000"
	download.datatype = "uinteger"

	up = s:option(Value, "uplimit", translate("Upload limit"), translate("KB/s"))
	up:depends("qos_enable", "1")
	up.default = "0"
	up.datatype = "uinteger"

end

--5G
if have_wifi_5G and have_wifi_5G ~= '0' then
s2 = m:section(NamedSection, "main_5g", "wifi-iface",  translate("5G"))
s2.addremove = false

mac5g = s2:option(DummyValue, "macaddr", translate("MAC Address"))
mac5g.cfgvalue = function(self, section)
	local macaddr=luci.util.exec("cat /sys/class/net/rai0/address")
	if macaddr then
		return macaddr
	else
		return "none"
	end
end 

disable5g = s2:option(Flag, "disabled", translate("Disable"))
disable5g.rmempty = false

if std_name ~= "S3A" and nixio.fs.access("/usr/bin/iconv") then
	-- if iconv not compiled in or not S3A 
	gbk_enable5g = s2:option(Flag, "gbk_enable", translate("Enable GBK SSID for Windows computer"), translate("If not selected only support iOS and Android devices."))
	gbk_enable5g.rmempty = false
end

ssid5g = s2:option(Value, "ssid", "SSID", translate("The length of WI-Fi SSID should less than 32 characters."))
ssid5g.rmempty = false
ssid5g.validate = function(self, value, section)
	if value and #value <= 32 then
		return value
	end
	return nil
end 

encrypt5g = s2:option(ListValue, "encryption", translate("Encrypt Type"))
encrypt5g:value("none", translate("No Encrypt"))
encrypt5g:value("wep-shared", translate("WEP"))
encrypt5g:value("psk", "WPA-PSK")
encrypt5g:value("psk2", "WPA2-PSK")
encrypt5g:value("psk+psk2", "WPA-PSK/WPA2-PSK")
encrypt5g.default = "none"

cipher5g = s2:option(ListValue, "cipher", translate("Cipher"))
cipher5g:depends({encryption="psk"})
cipher5g:depends({encryption="psk2"})
cipher5g:depends({encryption="psk+psk2"})
cipher5g:value("ccmp", "AES")
cipher5g:value("tkip", "TKIP")
cipher5g:value("tkip+ccmp", "TKIP/AES")
cipher5g.default = "tkip+ccmp"

wepkey5g = s2:option(Value, "key1", translate("Key"), translate("Composed of letters,numbers and most of special letters, the length range is 5 to 13"))
wepkey5g:depends("encryption", "wep-shared")
wepkey5g.datatype = "wepkey"
wepkey5g.validate = function(self, value, section)
	if value and value:match("^[a-zA-Z0-9!@#_%~%$%%%^%&%*%(%%)%-%+%=%.%,%;%:%{%}%[%]%|%>%<%?%'%`]+$") then
		return value
	end
	return nil
end 

wpakey5g = s2:option(Value, "key", translate("Key"), translate("Composed of letters,numbers and most of special letters, the length range is 8 to 63"))
wpakey5g:depends("encryption", "psk")
wpakey5g:depends("encryption", "psk2")
wpakey5g:depends("encryption", "psk+psk2")
wpakey5g.datatype = "wpakey"
wpakey5g.validate = function(self, value, section)
	if value and value:match("^[a-zA-Z0-9!@#_%~%$%%%^%&%*%(%%)%-%+%=%.%,%;%:%{%}%[%]%|%>%<%?%'%`]+$") then
		return value
	end
	return nil
end 

if luci.verctrl.module_status("ssid_bridge")  then
	if string.match(version, "(%d)\.%d\.%d") == "4" then
		lanintf5g = s2:option(ListValue, "network", translate("Bind Interface"))
		if luci.verctrl.module_status("lan_display")  then
			luci.tools.webadmin.cbi_add_lan_networks(lanintf5g)
			luci.tools.webadmin.cbi_add_vlan_networks(lanintf5g)
		end
		luci.tools.webadmin.cbi_add_wan_networks(lanintf5g)
		lanintf5g.optional = false
		lanintf5g.rmempty = false
		if luci.verctrl.module_status("lan_display")  then
			lanintf5g.default = "lan"
		else
			lanintf5g.default = "wan"
		end
	end
end

kick5g = s2:option(Value, "kickthres", translate("Kickout Threshold"),translate("Set 0 to disable kickout"))
kick5g:value("0", translate("Disable Kickout"))
kick5g:value("-75", translatef("Less than %s dBm", "-75"))
kick5g:value("-78", translatef("Less than %s dBm", "-78"))
kick5g:value("-80", translatef("Less than %s dBm", "-80"))
kick5g:value("-83", translatef("Less than %s dBm", "-83"))
kick5g:value("-85", translatef("Less than %s dBm", "-85"))
kick5g:value("-88", translatef("Less than %s dBm", "-88"))
kick5g:value("-90", translatef("Less than %s dBm", "-90"))
kick5g:value("-95", translatef("Less than %s dBm", "-95"))
kick5g.default = "0"
kick5g.datatype = "range(-100, 0)"

reject5g = s2:option(Value, "assocthres", translate("Weak signal rejection threshold"),translate("Set 0 to disable weak signal rejection"))
reject5g:value("0", translate("Disable weak signal rejection"))
reject5g:value("-75", translatef("Less than %s dBm", "-75"))
reject5g:value("-78", translatef("Less than %s dBm", "-78"))
reject5g:value("-80", translatef("Less than %s dBm", "-80"))
reject5g:value("-83", translatef("Less than %s dBm", "-83"))
reject5g:value("-85", translatef("Less than %s dBm", "-85"))
reject5g:value("-88", translatef("Less than %s dBm", "-88"))
reject5g:value("-90", translatef("Less than %s dBm", "-90"))
reject5g:value("-95", translatef("Less than %s dBm", "-95"))
reject5g.default = "0"
reject5g.datatype = "range(-100, 0)"

if ap_mode ~= 1 then
	qos5g = s2:option(Flag, "qos_enable", translate("Qos Enable"))

	download5g = s2:option(Value, "downlimit", translate("Download limit"), translate("KB/s"))
	download5g:depends("qos_enable", "1")
	download5g.default = "3000"
	download5g.datatype = "uinteger"

	up5g = s2:option(Value, "uplimit", translate("Upload limit"), translate("KB/s"))
	up5g:depends("qos_enable", "1")
	up5g.default = "0"
	up5g.datatype = "uinteger"

end

end

return m


