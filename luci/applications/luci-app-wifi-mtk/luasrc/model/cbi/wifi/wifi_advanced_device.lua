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
m.apply_with_progressbar = true
m.progress_text = translate("The Wi-Fi terminal might be disconnected. Do not power off or restore the factory setting. Please wait a few moment and try again.")
m.progress_interval = 5

require "nixio"
local sys = require "luci.sys"

local board_name = luci.sys.sys_board_name()
local std_name = luci.sys.sys_product_std_model()
local device = luci.sys.get_wifi_24g_device()

s = m:section(NamedSection, device, "wifi-device", translate("2.4G"))
s.addremove = false

mode = s:option(ListValue, "wifimode", translate("Wi-Fi Mode"))
mode:value("9", "802.11b/g/n")
mode:value("0", "802.11b/g")
mode:value("7", "802.11g/n")
mode:value("1", "802.11b")
mode:value("4", "802.11g")
mode:value("6", "802.11n")
mode.default = "9"	

ht = s:option(ListValue, "ht", translate("Channel Bandwidth"))
ht:value("20", "20MHz")
ht:value("20+40", "20/40MHz")
ht:value("40", "40MHz")
ht:depends("wifimode", "9")
ht:depends("wifimode", "7")
ht:depends("wifimode", "6")
ht.default = "20"

chmode = s:option(ListValue, "chmode", translate("Channel Mode"))
chmode.widget = "radio"
chmode:value("1", translate("FCC standard for using in United States, Canada, etc., with 11 channels."))
chmode:value("0", translate("ETSI standard for using in China, Australia, Venezuela, and other regions with 13 channels."))
chmode:value("2", translate("JP standard for using in Japan with 14 channels."))
chmode.default = "0"
chmode.optional = false
chmode.rmempty = false


channel = s:option(ListValue, "channel", translate("Channel"))
channel:value("auto", translate("auto"))

local j = 2.412
for i = 1, 11 do
	channel:value(tostring(i), "%i (%.3f GHz)" %{ i, j })
	j = j + 0.005
end
channel:value("14", "14(2.477 GHz)", {chmode="2"})
channel:value("13", "13(2.472 GHz)", {chmode="0"}, {chmode="2"})
channel:value("12", "12(2.467 GHz)", {chmode="0"}, {chmode="2"})

txpower = s:option(ListValue, "txpower", translate("Transmit Power"))
txpower.rmempty = true
txpower.default = "100"
txpower:value("1", "1%")

for i=1, 10 do
	j = i * 10
	txpower:value(tostring(j), j .. "%")
end 

dtim = s:option(Value, "dtim", translate("DTIM period"))
dtim.default = "1"
dtim.datatype = "range(1, 255)"

beacon = s:option(Value, "beacon", translate("Beacon period"))
beacon.default = "100"
beacon.datatype = "range(20, 1024)"

rts = s:option(Value, "rtsthres", translate("RTS threshold"))
rts.default = "2347"
rts.datatype = "range(1, 2347)"

pre = s:option(Flag, "txpreamble", translate("Tx Preamble"))
pre.default = true

--wmm = s:option(Flag, "wmm", translate("WMM"))


local have_wifi_5G = sys.board_have_wifi_5G()

if have_wifi_5G and have_wifi_5G ~= '0' then
device = luci.sys.get_wifi_5g_device()
s2 = m:section(NamedSection, device, "wifi-device", translate("5G"))
s2.addremove = false

mode5g = s2:option(ListValue, "wifimode", translate("Wi-Fi Mode"))
mode5g:value("14", "802.11a/an/ac")
mode5g:value("2", "802.11a")
--mode:value("3", "802.11a/b/g")
--mode:value("5", "802.11a/b/g/n")
--mode:value("7", "802.11g/n")
--mode:value("10", "802.11a/g/n")
mode5g:value("11", "802.11n")
mode5g.default = "14"

ht5g = s2:option(ListValue, "ht", translate("Channel Bandwidth"))
ht5g:value("20", "20MHz")
ht5g:value("20+40", "20/40MHz")
ht5g:value("20+40+80", "20/40/80MHz")
ht5g:value("40+80", "40/80MHz")
ht5g:value("40", "40MHz")
ht5g:value("80", "80MHz")
ht5g:depends("wifimode", "14")
ht5g:depends("wifimode", "5")
ht5g:depends("wifimode", "10")
ht5g.default = "20+40+80"

chmode5g = s2:option(ListValue, "chmode", translate("Channel Mode"))
chmode5g.widget = "radio"
chmode5g:value("1", translate("5G FCC standard for using in United States, Canada, etc., with 24 channels."))
chmode5g:value("0", translate("5G ETSI standard for using in China, Australia, Venezuela, and other regions with 13 channels."))
chmode5g:value("2", translate("5G JP standard for using in Japan with 19 channels."))
chmode5g.default = "0"
chmode5g.optional = false
chmode5g.rmempty = false


channel5g = s2:option(ListValue, "channel", translate("Channel"))
channel5g:value("auto", translate("auto"))

local j = 5.180
for i = 36, 64, 4 do
	channel5g:value(tostring(i), "%i (%.3f GHz)" %{ i, j }, {chmode="0"}, {chmode="1"}, {chmode="2"})
	j = j + 0.02
end

j = 5.500
for i = 100, 140, 4 do
	channel5g:value(tostring(i), "%i (%.3f GHz)" %{ i, j }, {chmode="1"}, {chmode="2"})
	j = j + 0.02
end

channel5g:value("149", "149(5.725 GHz)", {chmode="0"}, {chmode="1"})
channel5g:value("153", "153(5.745 GHz)", {chmode="0"}, {chmode="1"})
channel5g:value("157", "157(5.765 GHz)", {chmode="0"}, {chmode="1"})
channel5g:value("161", "161(5.785 GHz)", {chmode="0"}, {chmode="1"})
channel5g:value("165", "165(5.805 GHz)", {chmode="0"}, {chmode="1"})

txpower5g = s2:option(ListValue, "txpower", translate("Transmit Power"))
txpower5g.rmempty = true
txpower5g.default = "100"
txpower5g:value("1", "1%")

for i = 1, 10 do
	j = i * 10
	txpower5g:value(tostring(j), j .. "%")
end 

dtim5g = s2:option(Value, "dtim", translate("DTIM period"))
dtim5g.default = "1"
dtim5g.datatype = "range(1, 255)"

beacon5g = s2:option(Value, "beacon", translate("Beacon period"))
beacon5g.default = "100"
beacon5g.datatype = "range(20, 1024)"

rts5g = s2:option(Value, "rtsthres", translate("RTS threshold"))
rts5g.default = "2347"
rts5g.datatype = "range(1, 2347)"

pre5g = s2:option(Flag, "txpreamble", translate("Tx Preamble"))
pre5g.default = true

--wmm5g = s2:option(Flag, "wmm", translate("WMM"))
end


return m


