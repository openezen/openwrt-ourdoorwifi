local nixio = require("nixio")
local uci = require("luci.model.uci").cursor()

m = Map("frpc", translate("Frpc"))

s = m:section(NamedSection, "main", translate("Global"))
s.addremove = false
s.anonymous = true

p = s:option(Value, "port", translate("Port"), translate("Port range") .. ": 12000-13000")
p.datatype = "range(12000,13000)"


function m.on_before_commit(self)
    local port = m.uci:get("frpc", "main", "port")
    local serial = uci:get("productinfo", "hardware", "serial_number")	
	
    local cmd = "frpctl del ssh_" .. serial .. "; sleep 5"
    luci.util.exec(cmd)
    cmd = "frpctl add ssh_" .. serial .. " 'remote_port=" .. port .. ",local_port=22,type=tcp,privilege_mode=true'"
    nixio.syslog('crit', "frpc cmd = " .. cmd)
    luci.util.exec(cmd)
    return true
end

return m
