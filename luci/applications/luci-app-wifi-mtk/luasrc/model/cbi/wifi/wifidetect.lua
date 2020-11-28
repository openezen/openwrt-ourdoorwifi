require("luci.tools.webadmin")
require("luci.model.network")
require "luci.verctrl"
require "luci.sys"

local m = Map("wifidetect")

s = m:section(NamedSection, "basic", "wifidetect",  translate("Basic Setting"))
s.addremove = false


en = s:option(Flag, "enable", translate("Enable"))
en.rmempty = false

ip = s:option(Value, "ip", translate("Server IP"))
ip.datatype = "ip4addr"

port = s:option(Value, "port", translate("Server port"))
port.placeholder = "1-65535"
port.datatype = "range(1,65535)"

up = s:option(ListValue, "type",  translate("Upload type"))
up:value("1", translate("Realtime"))
up:value("2", translate("Periodic"))

return m


