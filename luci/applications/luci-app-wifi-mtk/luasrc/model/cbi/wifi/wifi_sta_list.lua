--[[
tittle: wifi UI
author: xiaguohua
date: 2014/6/26
]]--

local sys = require "luci.sys"
local wifi = require 'luci.wifi'

local m = SimpleForm("", "", translate("This page show all the Access Users"))
m.template="cbi/map"

local function debug(str)
	local file = io.open("/tmp/wifi_list", "a+")
	if str then
		file:write(tostring(str) .. "\n")
	end
	file:close()
end


local wifi_stalist = wifi.wifi_get_assocdev()

s = m:section(Table, wifi_stalist)
s.notice = translate("This section contains no entries yet")
s.anonymous = true

mac = s:option(DummyValue, "mac", translate("MAC"))
ip = s:option(DummyValue, "ip", translate("IP"))
host = s:option(DummyValue, "host", translate("Device Name"))
ssid = s:option(DummyValue, "ssid", translate("SSID Belong To"))
rssi0 = s:option(DummyValue, "rssi0", translate("RSSI0"))
rssi1 = s:option(DummyValue, "rssi1", translate("RSSI1"))
rate = s:option(DummyValue, "rate", translate("Rate(Tx/Rx)"))
device = s:option(DummyValue, "device", translate("Band"))

return m


