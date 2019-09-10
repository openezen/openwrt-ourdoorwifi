require 'std'

local cjson = require 'cjson'
local js	 = require "luci.jsonc"
require "luci.util"

local function get_qmiinfo()
	local data = {}
	local device = "/dev/cdc-wdm0"
	local bandtype
	
	local is_dialing = luci.util.exec("ps | grep uqmi | grep cdc-wdm")
	
	if is_dialing and isdialing ~= "" then
		return nil
	end

    local ret = luci.util.exec("timeout -t 1 uqmi -s -d " .. device  .." --get-serving-system")
	local system = js.parse(ret)

	ret = luci.util.exec("timeout -t 1 uqmi -s -d " .. device .. " --get-signal-info")
	local signal = js.parse(ret) 
	ret = luci.util.exec("timeout -t 1 uqmi -s -d " .. device .. " --get-imei")
	local imei = js.parse(ret) 
	ret = luci.util.exec("timeout -t 1 uqmi -s -d " .. device .. " --get-data-status")
	local status = js.parse(ret) 
	ret = luci.util.exec("timeout -t 1 qmicli -d " .. device .. " --dms-get-revision | grep Revision")
	local model = ret:match("Revision: '(%w+)[%s%']")
	ret = luci.util.exec("timeout -t 1 qmicli -d " .. device .. " --nas-get-system-info | grep \"Cell ID\"")
	local cellid = ret:match("Cell ID: '([%w-]+)'")
	ret = luci.util.exec("timeout -t 1 qmicli -d " .. device .. " --nas-get-serving-system | grep \"3GPP location area code\"")
	local areaid = ret:match("3GPP location area code: '([%w-]+)'")

	data = {
		plmn_mcc = system and system.plmn_mcc or nil,
		plmn_mnc = system and system.plmn_mnc or nil,
		plmn_desc = syatem and system.plmn_description or nil,
		model = model,
		imei = imei,
		cellid = cellid,
		areaid = areaid,
        isptype = signal and signal.type or nil,
	}
	return data
end

local rv = cjson.encode(get_qmiinfo() or {})
file_put_content('/tmp/qmiinfo.data', rv)
print(rv)
