local uci = require("luci.model.uci").cursor()

require "luci.util"
require "nixio"
local i18n = require "luci.i18n"
local translate = i18n.translate
local bit = nixio.bit

module("luci.wifi", package.seeall)

function wifi_is_dbdcmode()	
		return 1
end


function wifi_get_assocdev()
	local lstatus = require "luci.tools.status"
	local nixio = require "nixio"
	local lsys = require "luci.sys"
	
	local enable_5g = true
	local dbdcmode = wifi_is_dbdcmode()
	
	local total_tbl = {}  -- mac = ip
	local iw_tbl = {}  -- mac = ssid
	local host_tbl = {}  -- ip = hostname
	
	local function collect_dhcp()
		local leases = lstatus.dhcp_leases() or {}
		for _, v in pairs(leases) do
			total_tbl[string.lower(v.macaddr)] = v.ipaddr
			if v.owner ~= nil then
				host_tbl[string.lower(v.macaddr)] = v.owner
			else
				host_tbl[string.lower(v.macaddr)] = v.hostname
			end
		end
	end
	
	local function collect_arp()
		local arptable = lsys.net.arptable() or {}
		for _, arpentry in ipairs(arptable) do
			local dev = arpentry["Device"] or ""
			dev = string.lower(dev)
			if string.match(dev,"br%-lan") then
				local ip = arpentry["IP address"]
				local mac = string.lower(arpentry["HW address"])
				
				-- FIXME: 过滤可能无效的arp表项
				if string.find(mac, ":") and mac ~= "00:00:00:00:00:00" then  
					total_tbl[mac] = ip
				end
			end
		end
	end
	
	local if_ssid_tab={}
	local uci = require("luci.model.uci").cursor_state()
	uci:foreach("wireless", "wifi-iface",
		function(ss)
			if ss[".name"] == "main" or ss[".name"] == "guest" then
				if ss["ifname"] and ss["ssid"] then
					local bss = ss["ifname"]:match("(%d)$")
					if bss then 
						if_ssid_tab[bss] = ss["ssid"]
					end					
				end
			end
			if ss[".name"] == "main_5g" or ss[".name"] == "guest_5g" then
				if ss["ifname"] and ss["ssid"] then
					local bss = ss["ifname"]:match("(%d)$")
					if bss then
						if dbdcmode == 0 then
							bss = tostring(bss + 4)
						else
							bss = tostring(bss + 2)
						end
						if_ssid_tab[bss] = ss["ssid"] 
					end					
				end
			end
		end)

	local function collect_iw()	
		local cmd = [[iwpriv ra0 get_mac_table]]
		for line in luci.util.execi(cmd) do
			local mac, bss, rssi0, rssi1, rate = string.match(line, "(%x%x:%x%x:%x%x:%x%x:%x%x:%x%x)%s+[^%s]+%s+([^%s])%s+[^%s]%s+[^%s]%s+[^%s]%s+([^%s]+)%s+([^%s]+)%s+([^%s]+)")
			if mac then
				local ssid, dev
				mac = string.lower(mac)
				if bss and if_ssid_tab[bss] then
					ssid = if_ssid_tab[bss]
				else
					ssid = tostring(translate("Unknown"))
				end
				if dbdcmode == 0 or tonumber(bss) < 2 then
					dev = "2.4G"
				else
					dev = "5G"
				end
				local iw_info = {
					mac = mac,
					ssid = ssid,
					rssi0 = rssi0 or "0",
					rssi1 = rssi1 or "0",
					rate = rate or "-",
					device = dev,
				}
				iw_tbl[#iw_tbl + 1] = iw_info
			end
		end

		if dbdcmode == 0 and enable_5g ~= "0" then
			local cmd = [[iwpriv rai0 get_mac_table]]
			for line in luci.util.execi(cmd) do
				local mac, bss, rssi0, rssi1, rate = string.match(line, "(%x%x:%x%x:%x%x:%x%x:%x%x:%x%x)%s+[^%s]+%s+([^%s])%s+[^%s]%s+[^%s]%s+[^%s]%s+([^%s]+)%s+([^%s]+)%s+([^%s]+)")
				
				if mac then
					local ssid
					mac = string.lower(mac)
					if bss then
						bss = tostring(bss + 4)
						if if_ssid_tab[bss] then
							ssid = if_ssid_tab[bss]
						else
							ssid = tostring(translate("Unknown"))
						end
					else
						ssid = tostring(translate("Unknown"))
					end
					local iw_info = {
						mac = mac,
							ssid = ssid,
						rssi0 = rssi0 or "0",
						rssi1 = rssi1 or "0",
						rate = rate or "-",
						device = "5G",
					}
					iw_tbl[#iw_tbl + 1] = iw_info
				end
			end
		end
	end
	
	collect_arp()
	collect_dhcp() 
	collect_iw()
	
	local dev_tbl = {}
	local iw_info = {}	
	for i, iw_info in  pairs(iw_tbl) do
		local ip = total_tbl[iw_info.mac]
		local host = host_tbl[iw_info.mac]
		if ip and not host then
			host = nixio.getnameinfo(ip)
		end
		local dev = {
			mac = iw_info.mac,
			ip = ip or tostring(translate("Unknown")),
			host = host or tostring(translate("Unknown")),
			ssid = iw_info.ssid,
			rssi0 = iw_info.rssi0 .. " dbm",
			rssi1 = iw_info.rssi1 .. " dbm",
			rate = iw_info.rate .. " Mbps" or "-",
			device = iw_info.device,
		}
		dev_tbl[#dev_tbl + 1] = dev
	end
	return dev_tbl
end


function get_wifi_client(macaddr)
	if not macaddr then
		return nil
	end
	
	local wifi_list = wifi_get_assocdev()
	local client = {}
	
	for i, client in pairs(wifi_list) do
		if string.upper(client.mac) == string.upper(macaddr) then
			return client	
		end
	end
end

function get_wifi_client_by_ip(ip)
	if not ip then
		return nil
	end
	
	local wifi_list = wifi_get_assocdev()
	local client = {}
	
	for i, client in pairs(wifi_list) do
		if client.ip == ip then
			return client	
		end
	end
end

