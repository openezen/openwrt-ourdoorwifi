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

require "nixio"
local sys = require "luci.sys"

local board_name = luci.sys.sys_board_name()
local std_name = luci.sys.sys_product_std_model()
local device = luci.sys.get_wifi_5g_device()

s = m:section(NamedSection, device, "wifi-device")
s.addremove = false

en = s:option(Flag, "bndstrg_enable", translate("Enable"))

low = s:option(Value, "rssilow", translate("RSSI threshold"), translate("If 5G signal strength is weaker than RSSI threshold, then this client can not connect to 5G."))
low.default = "-88"
low.datatype = "range(-100, 0)"
low:depends("bndstrg_enable", "1")

diff = s:option(Value, "rssidiff", translate("RSSI difference"), translate("If difference between 2.4G signal and 5G signal is greater than RSSI difference, then allow client to connect to 2.4G Wi-Fi."))
diff.default = "15"
diff.datatype = "range(0,50)"
diff:depends("bndstrg_enable", "1")

age = s:option(Value, "agetime", translate("Aging time"), translate("Entry Age Time (ms)"))
age.default = "600000"
age.datatype = "uinteger"
age:depends("bndstrg_enable", "1")

hold = s:option(Value, "holdtime", translate("Hold time"), translate("If no 5G request is received after exceed 2.4G requested hold time, then allow to connect to 2.4G Wi-Fi network. The unit is ms."))
hold.default = "3000"
hold.datatype = "uinteger"
hold:depends("bndstrg_enable", "1")

check = s:option(Value, "checktime", translate("5G Check time"), translate("Detection time period of determine whether the terminal is the 2.4G single-frequency device. The unit is ms."))
check.default = "6000"
check.datatype = "uinteger"
check:depends("bndstrg_enable", "1")



return m


