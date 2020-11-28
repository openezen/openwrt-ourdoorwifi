--[[
tittle: wifi UI
author: xiaguohua
date: 2014/6/26
]]--

module("luci.controller.wifi", package.seeall)
function index()
	local has_wifi = nixio.fs.stat("/etc/config/wireless")

	if has_wifi and has_wifi.size > 0 then
		local page

		page = node("admin", "wifi")
		page.target = firstchild()
		page.title  = _("Wi-Fi")
		page.order  = 60
		page.index  = true	

		page = entry({"admin", "wifi", "basic"},  arcombine(cbi("admin_network/wifi_overview"), cbi("admin_network/wifi_mtk")), _("Basic Setting"), 10)
		page.leaf = true
		page.subindex = true

		if page.inreq then
			local wdev
			local net = require "luci.model.network".init(uci)
			for _, wdev in ipairs(net:get_wifidevs()) do
				local wnet
				for _, wnet in ipairs(wdev:get_wifinets()) do
					entry({"admin", "wifi", "basic", wnet:id()},
						alias("admin", "wifi", "basic"),
						wdev:name() .. ": " .. wnet:shortname())
				end
			end
		end
		
		
		-- access device
	--	pos = luci.menu_pos.wifi["sta"]
		page = entry({"admin", "wifi", "sta"}, alias("admin", "wifi", "sta", "list"), _("User Status"), 40)
		page.dependent = true
		
		page = entry({"admin", "wifi", "sta", "list"}, cbi("wifi/wifi_sta_list"), _("STA List"), 10)
		page.leaf = true
		
		-- for 5G
		--page = entry({"admin", "wifi", "sta", "list_5g"}, cbi("wifi/wifi_sta_list_5g"), _("5G Stalist"), 20)
		--page.leaf = true
		
		-- client
		page = entry({"admin", "wifi", "client"}, alias("admin", "wifi", "client", "client"), _("Wi-Fi relay"), 50)
		page.dependent = true
		
		page = entry({"admin", "wifi", "client", "client"}, call("action_render_wifi_client"), _(""), nil)
		page.leaf = true
		page.hidden = true
		
		page = entry({"admin", "wifi", "client", "client_5g"}, call("action_render_wifi_client_5g"), _(""), nil)
		page.leaf = true
		page.hidden = true
		
		page = entry({"admin", "wifi", "client", "client_scan"}, call("action_scan_wifi"), _(""), nil)
		page.leaf = true
		page.hidden = true
		
		page = entry({"admin", "wifi", "client", "client_apply"}, call("action_apply_client"), _(""), nil)
		page.leaf = true
		page.hidden = true
		
		page = entry({"admin", "wifi", "client", "get_client_info"}, call("action_get_client_info"), _(""), nil)
		page.leaf = true
		page.hidden = true
	end
end

function action_render_wifi_client()
	luci.template.render("admin_wifi/wifi_client",{client_type=0})
end

function action_render_wifi_client_5g()
	luci.template.render("admin_wifi/wifi_client",{client_type=1})
end

function action_scan_wifi()
	local scan_cmd
	local params = luci.http.formvalue()

	if params.type == "0" then
		scan_cmd = "iwpriv ra0 set SiteSurvey=1; sleep 5; iwpriv ra0 get_site_survey"
	elseif params.type == "1" then
		scan_cmd = "iwpriv rai0 set SiteSurvey=1; sleep 5; iwpriv rai0 get_site_survey"
	else
		luci.http.prepare_content("application/json")
		luci.http.write_json({error="unknow type"})
		return false
	end
	
	local ret = {}
	local index = 0
	local f = io.popen(scan_cmd)
	for line in f:lines() do
		index = index + 1
		--sprintf(msg + strlen(msg), "%-4s%-4s%-33s%-20s%-23s%-9s%-7s%-7s%-3s%-8s\n",
		--	"No", "Ch", "SSID", "BSSID", "Security", "Siganl(%)", "W-Mode", " ExtCH", " NT", " SSID_Len");
		if index > 3  and #line > 0 then
			ret[index-3] = {}
			ret[index-3].ch = string.sub(line,5,8)
			ret[index-3].ssid = string.sub(line,9,41)
			ret[index-3].bssid = string.sub(line,42,61)
			ret[index-3].security = string.sub(line,62,84)
			ret[index-3].siganl = string.sub(line,85,93)
			ret[index-3].mode = string.sub(line,94,100)

			local old_ssid = luci.util.trim(ret[index-3].ssid)
			local new_ssid = ""
			if string.sub(old_ssid,1,2) == "0x" then
				for i=3,#old_ssid,2 do
					new_ssid = new_ssid .. string.char(tonumber("0x"..string.sub(old_ssid,i,i+1)))
				end
				ret[index-3].ssid = new_ssid
			end
			
		end
	end
	
	luci.http.prepare_content("application/json")
	luci.http.write_json(ret)
	return true
end

local sleep = function(n)
	n = n or 1
	luci.util.exec("sleep "..n)
end

function action_get_client_info()
	local uci = luci.model.uci.cursor()
	local uci_state = uci.cursor(nil, "/var/state")
	
	local res = {}
	
	local ipaddr_24g = uci_state:get("network", "wwan_2g", "ipaddr")
	if ipaddr_24g then
		local section_name_24g = luci.sys.get_wifi_24g_device()
		local client_ssid_24g = uci:get("wireless", section_name_24g, "clissid") or ""
		res.ipaddr24g = ipaddr_24g
		res.ssid24g = client_ssid_24g
	end

	local have_wifi_5G = luci.sys.board_have_wifi_5G()
	if have_wifi_5G == "1" then
		local ipaddr_5g = uci_state:get("network", "wwan_5g", "ipaddr")
		if ipaddr_5g then
			local section_name_5g = luci.sys.get_wifi_5g_device()
			local client_ssid_5g = uci:get("wireless", section_name_5g, "clissid") or ""
			res.ipaddr5g = ipaddr_5g
			res.ssid5g = client_ssid_5g
		end
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json(res)
end

function action_apply_client()
	local params      = luci.http.formvalue()
	local client_type = params.type
	local sectionname = params.sectionname
	local clienable   = params.clienable or "0"
	local clissid     = params.clissid	or ""
	local clibssid    = params.clibssid or ""
	local cliauthmode = params.cliauthmode or ""
	local clienc      = params.clienc or ""
	local clikey1     = params.clikey1 or ""
	local cliwpapsk   = params.cliwpapsk or ""
	local channel     = params.clich or "auto"
	local cliautoch   = params.cliautoch or "3"
	
	local ret = {}
	ret.error = "none"
	
	if not sectionname then
		ret.error = "section name nil"
	end
	
	local nw_section = ""
	local nw_ifname = ""
	if client_type == "0" then
		nw_section = "wwan_2g"
		nw_ifname = "apcli0"
	elseif client_type == "1" then
		nw_section = "wwan_5g"
		nw_ifname = "apclii0"
	else
		ret.error = "unknow type"
	end

	if clienable == "1" and clissid == "" then
		ret.error = "ssid nil"
	end
	
	if ret.error == "none" then
		local uci         = require "luci.model.uci"
		local cursor      = uci.cursor()
		local uci_state   = uci.cursor(nil, "/var/state")
		
		cursor:delete("network", nw_section)
		if clienable == "1" then
			cursor:set("network", nw_section, "interface")
			cursor:set("network", nw_section, "ifname", nw_ifname)
			cursor:set("network", nw_section, "intftype", "wan")
			cursor:set("network", nw_section, "proto", "dhcp")
			cursor:set("network", nw_section, "probetype", "disable")
		end
		cursor:commit("network")
		
		cursor:set("wireless", sectionname, "clienable", clienable)
		cursor:set("wireless", sectionname, "clissid", clissid)
		cursor:set("wireless", sectionname, "clibssid", clibssid)
		cursor:set("wireless", sectionname, "cliauthmode", cliauthmode)
		cursor:set("wireless", sectionname, "clienc", clienc)
		cursor:set("wireless", sectionname, "clikey1", clikey1)
		cursor:set("wireless", sectionname, "cliwpapsk", cliwpapsk)
		cursor:set("wireless", sectionname, "channel", channel)
		cursor:set("wireless", sectionname, "cliautoch", cliautoch)
		cursor:commit("wireless")

		luci.util.exec("/etc/init.d/wireless reload")
		luci.util.exec("ifup "..nw_section)
		
		local ipaddr = nil
        local otherIpaddr = nil
		if clienable == "1" then
            local otherClienable = '0'
            local otherNwSection
            if client_type == "1" then
                local section_name_24g = luci.sys.get_wifi_24g_device()
                otherClienable = cursor:get("wireless", section_name_24g, "clienable") or '0'
                otherNwSection = 'wwan_2g'
            else
                local have_wifi_5G = luci.sys.board_have_wifi_5G()
                if have_wifi_5G == "1" then
                    local section_name_5g = luci.sys.get_wifi_5g_device()
                    otherClienable = cursor:get("wireless", section_name_5g, "clienable") or '0'
                    otherNwSection = 'wwan_5g'
                end
            end
			for i=1,3 do
				sleep(5)
				ipaddr = uci_state:get("network", nw_section, "ipaddr")
                if otherClienable == '1' then
                    otherIpaddr = uci_state:get("network", otherNwSection, "ipaddr")
                end
				if (otherClienable == '1') and (ipaddr and otherIpaddr) or ipaddr then
					ret.error = "success"
					break;
				end
			end
        else
            ret.error = "success"
		end
	end
	
	luci.http.prepare_content("application/json")
	luci.http.write_json(ret)
end
