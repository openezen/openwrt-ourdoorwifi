require 'std'

local fs     = require "nixio.fs"
local cjson = require 'cjson'
local js	 = require "luci.jsonc"
require "luci.util"

local function get_qmiinfo()
	local data = {}
	local device = "/dev/cdc-wdm0"
	local bandtype
	local plmn_desc

	if not fs.access(device) then
		return nil
	end

	local is_dialing = luci.util.exec("ps | grep uqmi | grep cdc-wdm | grep -v grep")
	
	if is_dialing and is_dialing ~= "" then
		return nil
	end

    local ret = luci.util.exec("timeout -t 1 uqmi -s -d " .. device  .." --get-serving-system")
	local system = js.parse(ret)

	if not system or not system.plmn_description then
		ret = luci.util.exec("timeout -t 1 qmicli -d " .. device .. " --nas-get-home-network | grep Description")
		plmn_desc = ret:match("Description: '([%w-]+)'") 
	else
		plmn_desc = system.plmn_description
	end

	ret = luci.util.exec("timeout -t 1 uqmi -s -d " .. device .. " --get-signal-info")
	local signal = js.parse(ret) 
	
	ret = luci.util.exec("timeout -t 1 uqmi -s -d " .. device .. " --get-imei")
	local imei = js.parse(ret) 

	ret = luci.util.exec("timeout -t 1 uqmi -s -d " .. device .. " --get-data-status")
	local status = js.parse(ret) 
	
	ret = luci.util.exec("timeout -t 1 qmicli -d " .. device .. " --dms-get-revision | grep Revision")
	local model = ret:match("Revision: '(%w+)[%s%']")
	if not model then
		ret = luci.util.exec("timeout -t 1 qmicli -d " .. device .. " --dms-get-model")
		model = ret:match("Model: '([%w-]+)'")
	end

	
	ret = luci.util.exec("timeout -t 1 qmicli -d " .. device .. " --nas-get-system-info | grep \"Cell ID\"")
	local cellid = ret:match("Cell ID: '([%w-]+)'")

	ret = luci.util.exec("timeout -t 1 qmicli -d " .. device .. " --nas-get-serving-system | grep \"3GPP location area code\"")
	local areaid = ret:match("3GPP location area code: '([%w-]+)'")

	data = {
		plmn_mcc = system and system.plmn_mcc or nil,
		plmn_mnc = system and system.plmn_mnc or nil,
		plmn_desc = plmn_desc,
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
