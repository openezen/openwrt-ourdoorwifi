-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"

local m, s, o

local sid = arg[1]

m = Map("frpc", "%s - %s" % { translate("Traversal cloud"), translate("Edit Server") })
m.redirect = dsp.build_url("admin/services/frpc/servers")

if m.uci:get("frpc", sid) ~= "server" then
	luci.http.redirect(m.redirect)
	return
end

s = m:section(NamedSection, sid, "server")
s.anonymous = true
s.addremove = false

o = s:option(Value, "alias", translate("Server Domain"))
if sid == "outdoorrouter"  then
	o.readonly = true                                   
end  

o = s:option(Value, "server_addr", translate("Server Address"))
o.datatype = "host"
o.rmempty = false
if sid == "outdoorrouter"  then
	o.readonly = true                                   
end  

o = s:option(Value, "server_port", translate("Server Port"))
o.datatype = "port"
o.rmempty = false
if sid == "outdoorrouter"  then
	o.readonly = true                                   
end  

o = s:option(Value, "auth_token", translate("Token"))
o.password = true
if sid == "outdoorrouter"  then
	o.readonly = true                                   
end  

o = s:option(Value, "privilege_token", translate("Privilege Token"))
o.password = true
o.hidden = true
if sid == "outdoorrouter"  then
	o.readonly = true                                   
end  

return m
