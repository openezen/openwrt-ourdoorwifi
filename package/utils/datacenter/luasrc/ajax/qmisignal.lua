require 'std'

local cjson = require 'cjson'
local js	 = require "luci.jsonc"
require "luci.util"

local function get_qmisignal()
	local data = {}
	local device = "/dev/cdc-wdm0"
	local bandtype

	local is_dialing = luci.util.exec("ps | grep uqmi | grep cdc-wdm")
	
	if is_dialing and is_dialing ~= "" then
		return nil
	end

	ret = luci.util.exec("timeout -t 1 uqmi -s -d " .. device .. " --get-signal-info")
	local signal = js.parse(ret) 
	ret = luci.util.exec("timeout -t 1 uqmi -s -d " .. device .. " --get-data-status")
	local status = js.parse(ret) 
	ret = luci.util.exec("timeout -t 1 qmicli -d " .. device .. " --nas-get-rf-band-info | grep \"Active Band Class\"")
	local band = ret:match("Active Band Class: '([%w-]+)'")
	ret = luci.util.exec("timeout -t 1 qmicli -d " .. device .. " --wds-get-autoconnect-settings | grep Roaming")
	local roam = ret:match("Roaming: '([%w-]+)'")
	ret = luci.util.exec("timeout -t 1 qmicli -d " .. device .. " --nas-get-signal-info | grep \"SNR\"")
	local snr = ret:match("SNR: '([%w%s-%.]+)'")

	if band and signal.type then
		bandtype = signal.type:upper() .. "  " ..band:upper()
	else
		bandtype = nil;
	end

	data = {
		status = status,
		roam = roam,
		band = bandtype,
		rssi = signal and signal.rssi and signal.rssi .. " dBm" or nil,
		rsrq = signal and signal.rsrq and signal.rsrq .. " dBm" or nil,
		rsrp = signal and signal.rsrp and signal.rsrp .. " dBm" or nil,
		snr = snr,
	}

	return data
end

local rv = cjson.encode(get_qmisignal() or {})
file_put_content('/tmp/qmisignal.data', rv)
print(rv)
