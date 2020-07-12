require 'std'

local fs	= require "nixio.fs"
local cjson = require 'cjson'
local js	= require "luci.jsonc"
local uci	= require "luci.model.uci".cursor()
require "luci.util"
require "luci.sys"


local function get_mminfo()
	local modem = luci.sys.mmcli_get_modem()
	local modem_info,ret,bearer,sim
	local info = {}

	if not modem then
		return nil
	end

	ret = luci.util.exec("mmcli -J -m " .. modem)
	if ret and ret ~= "" then
		modem_info = cjson.decode(ret)
	end

	if not modem_info or not modem_info["modem"] then
		return nil
	end
	

	if modem_info["modem"]["generic"] then
		ret = modem_info["modem"]["generic"]
		if ret["bearers"] then
			bearer = ret["bearers"][1]
		end
		sim = ret["sim"]
		info.model 		= ret["revision"]
		info.capabilities = ret["current-capabilities"][1]
		info.signal 		= ret["signal-quality"]["value"]
		info.simstate		= ret["state"]
		info.failed_raeson = ret["state-failed-reason"]
		info.manufacturer	= ret["manufacturer"]
		info.imei			= ret["equipment-identifier"]
		info.plmn_desc		= ret["operator-name"]
	end

	if bearer then
		ret = luci.util.exec("mmcli -J -b " .. bearer)
		local bearinfo = cjson.decode(ret)
		if bearinfo then
			ret = bearinfo["bearer"]
			if ret then
				info.status	= ret["status"]["connected"] == "yes" and "Connected" or "Disconnected"
				info.roaming	= ret["properties"]["roaming"]
				info.apn		= ret["properties"]["apn"]
			end
		end
	end

	if sim and sim ~= "--" then
		ret = luci.util.exec("mmcli -J -i " .. sim)
		local siminfo = cjson.decode(ret)
		if siminfo then
			ret = siminfo["sim"]
			if ret then
				info.iccid = ret["properties"]["iccid"]
				info.imsi = ret["properties"]["imsi"]
				info.plmn = ret["properties"]["operator-code"]
				if not info.plmn_desc then
					info.plmn_desc = ret["properties"]["operator-name"]
				end
			end
		end
	end

	return info
end

local rv = cjson.encode(get_mminfo() or {})
file_put_content('/tmp/mminfo.data', rv)
print(rv)
