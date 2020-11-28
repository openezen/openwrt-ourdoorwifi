--[[
tittle: wifi UI
author: xiaguohua
date: 2014/6/26
]]--

local m = Map("wireless")
if luci.verctrl.module_status("ourtabmenus") then
	require("luci.tabmenu.wifi.wifi_tabmenu")
	luci.tabmenu.wifi.wifi_tabmenu.wifi_advanced_set_tab_menu_items(m)
end

local board_name = luci.sys.sys_board_name()

if board_name == "wr8305rt" or board_name == "mt7620a" then
	s = m:section(NamedSection, "mt7620", "wifi-device")
elseif board_name == "MT7628" then
	s = m:section(NamedSection, "mt7628", "wifi-device")
else
	s = m:section(NamedSection, "mt7603e", "wifi-device")
end
s.addremove = false

en = s:option(Flag, "clienable", translate("Enable"))
en.default = "0"

ssid = s:option(Value, "clissid", "SSID", translate("Not Support Chinese"))
ssid.rmempty = false
ssid.validate = function(self, value, section)
	if value and #value <= 32 then
		return value
	end
	return nil
end 

bssid = s:option(Value, "clibssid", "BSSID", translate("AP Mac Address (optional)"))
bssid.rmempty = true


encrypt = s:option(ListValue, "cliauthmode", translate("Encrypt Type"))
encrypt:value("OPEN", translate("No Encrypt"))
encrypt:value("SHARED", translate("WEP"))
encrypt:value("WPAPSK", "WPA-PSK")
encrypt:value("WPA2PSK", "WPA2-PSK")
encrypt.default = "none"

cipher = s:option(ListValue, "clienc", translate("Cipher"))
cipher:depends({cliauthmode="WPAPSK"})
cipher:depends({cliauthmode="WPA2PSK"})
cipher:value("AES", "AES")
cipher:value("TKIP", "TKIP")
cipher:value("TKIPAES", "TKIP/AES")
cipher.default = "AES"

wepkey = s:option(Value, "clikey1", translate("Key"), translate("Composed of letters,numbers and most of special letters, the length range is 5 to 13"))
wepkey:depends("cliauthmode", "SHARED")
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

wpakey = s:option(Value, "cliwpapsk", translate("Key"), translate("Composed of letters,numbers and most of special letters, the length range is 8 to 63"))
wpakey.datatype = "wpakey"
wpakey:depends("cliauthmode", "WPAPSK")
wpakey:depends("cliauthmode", "WPA2PSK")
wpakey.validate = function(self, value, section)
	if value and value:match("^[a-zA-Z0-9!@#_%~%$%%%^%&%*%(%%)%-%+%=%.%,%;%:%{%}%[%]%|%>%<%?%'%`]+$") then
		return value
	end
	return nil
end 

function m.on_parse(map)
	local enc = encrypt:formvalue("main")
	if enc == "SHARED" then
		wepkey.rmempty = false
	elseif enc == "WPAPSK" or enc == "WPA2PSK"then
		wpakey.rmempty = false
	else
		wepkey.rmempty = true
		wpakey.rmempty = true
	end
end



return m


