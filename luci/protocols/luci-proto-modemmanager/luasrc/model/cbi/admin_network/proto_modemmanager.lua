-- Copyright 2019 Telco Antennas Pty Ltd <nicholas.smith@telcoantennas.com.au>
-- SPDX-License-Identifier: Apache-2.0
require "luci.sys"

local map, section, net = ...

local device, apn, pincode, username, password, iptype
local auth, ipv6
local simnum = luci.sys.get_simcard_num()


device = section:taboption("general", Value, "device", translate("Modem device"))
device.rmempty = false

-- Supports only one modem that has already been registered by MM.  Ensures the modem is usable.
-- Assumes modem is on index 0
local modem = luci.sys.mmcli_get_modem()
if not modem or modem == "" then
	modem = 0
end

local handle = io.popen("mmcli -m " .. modem .. " | grep 'device: ' | grep -Eo '/sys/devices/.*' | tr -d \"'\"", "r")
local device_suggestions = handle:read("*l")
handle:close()

if handle then
	device:value(device_suggestions)
	device.default=device_suggestions
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

	auth1 = section:taboption("primary", Value, "auth1", translate("Authentication type"))
	auth1:value("", translate("-- Please choose --"))
	auth1:value("both", "PAP/CHAP (both)")
	auth1:value("pap", "PAP")
	auth1:value("chap", "CHAP")
	auth1:value("none", "NONE")

	iptype1 = section:taboption("primary", Value, "iptype1", translate("IP connection type"))
	iptype1:value("", translate("-- Please choose --"))
	iptype1:value("ipv4", "IPv4 only")
	iptype1:value("ipv6", "IPv6 only")


	apn2 = section:taboption("secondary", Value, "apn2", translate("APN"))
	pincode2 = section:taboption("secondary", Value, "pincode2", translate("PIN"))
	username2 = section:taboption("secondary", Value, "username2", translate("PAP/CHAP username"))
	password2 = section:taboption("secondary", Value, "password2", translate("PAP/CHAP password"))
	password2.password = true

	auth2 = section:taboption("secondary", Value, "auth2", translate("Authentication type"))
	auth2:value("", translate("-- Please choose --"))
	auth2:value("both", "PAP/CHAP (both)")
	auth2:value("pap", "PAP")
	auth2:value("chap", "CHAP")
	auth2:value("none", "NONE")

	iptype2 = section:taboption("secondary", Value, "iptype2", translate("IP connection type"))
	iptype2:value("", translate("-- Please choose --"))
	iptype2:value("ipv4", "IPv4 only")
	iptype2:value("ipv6", "IPv6 only")

else
	apn = section:taboption("general", Value, "apn", translate("APN"))
	pincode = section:taboption("general", Value, "pincode", translate("PIN"))
	username = section:taboption("general", Value, "username", translate("PAP/CHAP username"))
	password = section:taboption("general", Value, "password", translate("PAP/CHAP password"))
	password.password = true

	auth = section:taboption("general", Value, "auth", translate("Authentication type"))
	auth:value("", translate("-- Please choose --"))
	auth:value("both", "PAP/CHAP (both)")
	auth:value("pap", "PAP")
	auth:value("chap", "CHAP")
	auth:value("none", "NONE")

	iptype = section:taboption("general", Value, "iptype", translate("IP connection type"))
	iptype:value("", translate("-- Please choose --"))
	iptype:value("ipv4", "IPv4 only")
	iptype:value("ipv6", "IPv6 only")
	iptype:value("ipv4v6", "IPv4/IPv6 (both - defaults to IPv4)")
end

metric = section:taboption("general", Value, "metric", translate("Gateway metric"))
