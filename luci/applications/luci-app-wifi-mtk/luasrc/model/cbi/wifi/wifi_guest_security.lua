--[[
tittle: wifi UI
author: xiaguohua
date: 2014/6/26
]]--

local m = Map("wireless")
if luci.verctrl.module_status("ourtabmenus") then
	require("luci.tabmenu.wifi.wifi_tabmenu")
	luci.tabmenu.wifi.wifi_tabmenu.wifi_guest_set_tab_menu_items(m)
end
m.apply_with_progressbar = true
m.progress_text = translate("The Wi-Fi terminal might be disconnected. Do not power off or restore the factory setting. Please wait a few moment and try again.")
m.progress_interval = 5

local have_wifi_5G = luci.sys.board_have_wifi_5G()
local std_name = luci.sys.sys_product_std_model()

s = m:section(NamedSection, "guest", "wifi-iface", translate("2.4G"))
s.addremove = false

isolate = s:option(Flag, "noforward", translate("Separate Access Users"), translate("The wireless users cannot visit each other"))
isolate.default = "0"

hidden = s:option(Flag, "hidden", translate("Hide SSID"))
hidden.default = "0"

maxassoc = s:option(Value, "maxassoc", translate("Max Access Users"), translate("0 means to be not limited"))
maxassoc.datatype = "range(0, 200)"

mp = s:option(ListValue, "macpolicy", translate("MAC Filter"))
mp.widget = "radio"
mp:value("disable", translate("Disable"))
mp:value("allow", translate("Allow Listed Only"))
mp:value("deny", translate("Allow All Except Listed"))
mp.default = "disable"

ml = s:option(DynamicList, "maclist", translate("MAC List"))
ml.datatype = "macaddr"

if std_name == "S3A" or std_name == "S3A_AP" then
	ft = s:option(Flag, "ftenable", translate("802.11R"))
	ft.addremove = false

	md = s:option(Value, "ftmdid", translate("Mobility domain ID"), translate("4 HEX word"))
	md:depends("ftenable", "1")
	md.validate = function(self, value, section)
		if value and (#value >= 1) and (#value <= 4) and value:match("^[0-9a-f]+$") then
			return value
		end
		return nil
	end

	r0 = s:option(Value, "ftr0khid", translate("R0kh ID"))
	r0:depends("ftenable", "1")
	r0.validate = function(self, value, section)
		if value and (#value >= 1) and (#value <= 48) and value:match("^[0-9a-z]+$") then
			return value
		end
		return nil
	end
end

if have_wifi_5G and have_wifi_5G ~= '0' then
s2 = m:section(NamedSection, "guest_5g", "wifi-iface", translate("5G"))
s2.addremove = false

isolate5g = s2:option(Flag, "noforward", translate("Separate Access Users"), translate("The wireless users cannot visit each other"))
isolate5g.default = "0"

hidden5g = s2:option(Flag, "hidden", translate("Hide SSID"))
hidden5g.default = "0"

maxassoc5g = s2:option(Value, "maxassoc", translate("Max Access Users"), translate("0 means to be not limited"))
maxassoc5g.datatype = "range(0, 200)"

mp5g = s2:option(ListValue, "macpolicy", translate("MAC Filter"))
mp5g.widget = "radio"
mp5g:value("disable", translate("Disable"))
mp5g:value("allow", translate("Allow Listed Only"))
mp5g:value("deny", translate("Allow All Except Listed"))
mp5g.default = "disable"

ml5g = s2:option(DynamicList, "maclist", translate("MAC List"))
ml5g.datatype = "macaddr"

if std_name == "S3A" or std_name == "S3A_AP" then
	ft5g = s2:option(Flag, "ftenable", translate("802.11R"))
	ft5g.addremove = false

	md5g = s2:option(Value, "ftmdid", translate("Mobility domain ID"), translate("4 HEX word"))
	md5g:depends("ftenable", "1")
	md5g.validate = function(self, value, section)
		if value and (#value >= 1) and (#value <= 4) and value:match("^[0-9a-f]+$") then
			return value
		end
		return nil
	end

	r05g = s2:option(Value, "ftr0khid", translate("R0kh ID"))
	r05g:depends("ftenable", "1")
	r05g.validate = function(self, value, section)
		if value and (#value >= 1) and (#value <= 48) and value:match("^[0-9a-z]+$") then
			return value
		end
		return nil
	end
end

end
return m
