module("luci.tabmenu.wifi.wifi_tabmenu", package.seeall)

local sys = require "luci.sys"
local have_wifi_5G = luci.sys.board_have_wifi_5G()

function wifi_main_set_tab_menu_items(m)

	require("luci.i18n")
	local translate = luci.i18n.translate
	
	m.tabcount=0
	m.tabname = {};
	m.tabmenu = {};
	m.isact = {};
	
	m.tabcount = m.tabcount+1
	m.tabname[m.tabcount] = translate("Network Setting")
	m.tabmenu[m.tabcount] = luci.dispatcher.build_url("admin", "wifi", "main", "basic")
	
	m.tabcount = m.tabcount+1
	m.tabname[m.tabcount] = translate("Security Setting")
	m.tabmenu[m.tabcount] = luci.dispatcher.build_url("admin", "wifi", "main", "security")

	m.istabform = true
	m.embedded = false
end

function wifi_guest_set_tab_menu_items(m)

	require("luci.i18n")
	local translate = luci.i18n.translate
	
	m.tabcount=0
	m.tabname = {};
	m.tabmenu = {};
	m.isact = {};
	
	m.tabcount = m.tabcount+1
	m.tabname[m.tabcount] = translate("Network Setting")
	m.tabmenu[m.tabcount] = luci.dispatcher.build_url("admin", "wifi", "guest", "basic")
	
	m.tabcount = m.tabcount+1
	m.tabname[m.tabcount] = translate("Security Setting")
	m.tabmenu[m.tabcount] = luci.dispatcher.build_url("admin", "wifi", "guest", "security")
	
	m.istabform = true
	m.embedded = false
end

function wifi_advanced_set_tab_menu_items(m)

	require("luci.i18n")
	local translate = luci.i18n.translate
	
	m.tabcount=0
	m.tabname = {};
	m.tabmenu = {};
	m.isact = {};
	
	m.tabcount = m.tabcount+1
	m.tabname[m.tabcount] = translate("Device Setting")
	m.tabmenu[m.tabcount] = luci.dispatcher.build_url("admin", "wifi", "advanced", "device")
	if have_wifi_5G and have_wifi_5G ~= '0' then
		m.tabcount = m.tabcount+1
		m.tabname[m.tabcount] = translate("Band Steering")
		m.tabmenu[m.tabcount] = luci.dispatcher.build_url("admin", "wifi", "advanced", "bndstrg")
	end
	--[[
	m.tabcount = m.tabcount+1
	m.tabname[m.tabcount] = translate("Wi-Fi relay")
	m.tabmenu[m.tabcount] = luci.dispatcher.build_url("admin", "wifi", "advanced", "client")

	if have_wifi_5G and have_wifi_5G ~= '0' then
		m.tabcount = m.tabcount+1
		m.tabname[m.tabcount] = translate("5G Wi-Fi relay")
		m.tabmenu[m.tabcount] = luci.dispatcher.build_url("admin", "wifi", "advanced", "client_5g")
	end]]--
	m.istabform = true
	m.embedded = false
end

