-- Copyright 2016 David Thornley <david.thornley@touchstargroup.com>
-- Licensed to the public under the Apache License 2.0.

local map, section, net = ...

local device, apn, pincode, username, password
local auth, ipv6, simcard
local simnum = luci.sys.get_simcard_num()

device = section:taboption("general", Value, "device", translate("Modem device"))
device.rmempty = false

local device_suggestions = nixio.fs.glob("/dev/cdc-wdm*")

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

	apn1 = section:taboption("primary", Value, "apn1", translate("APN"))
	pincode1 = section:taboption("primary", Value, "pincode1", translate("PIN"))
	username1 = section:taboption("primary", Value, "username1", translate("PAP/CHAP username"))
	password1 = section:taboption("primary", Value, "password1", translate("PAP/CHAP password"))
	password1.password = true	
	auth1 = section:taboption("primary", Value, "auth1", translate("Authentication Type"))
	auth1:value("", translate("-- Please choose --"))
	auth1:value("both", "PAP/CHAP (both)")
	auth1:value("pap", "PAP")
	auth1:value("chap", "CHAP")
	auth1:value("none", "NONE")

	apn2 = section:taboption("secondary", Value, "apn2", translate("APN"))
	pincode2 = section:taboption("secondary", Value, "pincode2", translate("PIN"))
	username2 = section:taboption("secondary", Value, "username2", translate("PAP/CHAP username"))
	password2 = section:taboption("secondary", Value, "password2", translate("PAP/CHAP password"))
	password2.password = true
	auth2 = section:taboption("secondary", Value, "auth2", translate("Authentication Type"))
	auth2:value("", translate("-- Please choose --"))
	auth2:value("both", "PAP/CHAP (both)")
	auth2:value("pap", "PAP")
	auth2:value("chap", "CHAP")
	auth2:value("none", "NONE")
else
	apn = section:taboption("general", Value, "apn", translate("APN"))
	pincode = section:taboption("general", Value, "pincode", translate("PIN"))
	username = section:taboption("general", Value, "username", translate("PAP/CHAP username"))
	password = section:taboption("general", Value, "password", translate("PAP/CHAP password"))
	password.password = true
	auth = section:taboption("general", Value, "auth", translate("Authentication Type"))
	auth:value("", translate("-- Please choose --"))
	auth:value("both", "PAP/CHAP (both)")
	auth:value("pap", "PAP")
	auth:value("chap", "CHAP")
	auth:value("none", "NONE")
end

if luci.model.network:has_ipv6() then
    ipv6 = section:taboption("advanced", Flag, "ipv6", translate("Enable IPv6 negotiation"))
    ipv6.default = ipv6.disabled
end
