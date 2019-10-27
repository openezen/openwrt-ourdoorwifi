module("luci.controller.onlineupgrade", package.seeall)
local ver = require("luci.version")
local uci = require("luci.model.uci").cursor()
local nixio = require("nixio")

local pcall, dofile, _G = pcall, dofile, _G

require "luci.util"

local product_name = ver.distname
local update_server = uci:get("productinfo", "hardware", "update_server") or "http://www.outdoorrouter.net:8080" 
local ini_file = ver.distname .. ".ini" 
local image_tmp = "/tmp/firmware.img"

function index()
	entry({"admin", "system", "onlineupgrade"}, template("onlineupgrade/onlineupgrade"), _("Online Sysupgrade"), 1)
	
	entry({"admin", "system", "onlineupgrade", "checknewversion"}, call("action_download_inifile")).leaf = true
	entry({"admin", "system", "onlineupgrade", "upgrade"}, call("action_upgrade")).leaf = true
end


function action_download_inifile()
	local url = update_server .. "/" .. product_name .. "/" .. ini_file
	local rv = {}
	local cur_ver = tonumber(ver.distversion:match("%d+"))
	luci.util.exec("wget " .. url .. " -O /tmp/firmware.ini")

	if pcall(dofile, "/tmp/firmware.ini") and _G.FIRMWARE_NAME then
		rv[#rv+1] = {
			filename = _G.FIRMWARE_NAME,
			version = _G.FIRMWARE_VERSION,
			md5sum = _G.FIRMWARE_MD5SUM,
			size = _G.FIRMWARE_SIZE,
			desc = _G.DESCRIPTION,
			errcode = cur_ver >= tonumber(_G.FIRMWARE_VERSION:match("%d+")) and 2 or 0,
		}
	else
		rv[#rv+1] = {
			filename = "---",
			version = "---",
			md5sum = "---",
			size = "---",
			desc = "---",
			errcode = 1,
		}	
	end
	
	if rv then
		luci.http.prepare_content("application/json")
		luci.http.write_json(rv)
	end

	return
end

function fork_exec(command)
	local pid = nixio.fork()
	if pid > 0 then
		return
	elseif pid == 0 then
		-- change to root dir
		nixio.chdir("/")

		-- patch stdin, out, err to /dev/null
		local null = nixio.open("/dev/null", "w+")
		if null then
			nixio.dup(null, nixio.stderr)
			nixio.dup(null, nixio.stdout)
			nixio.dup(null, nixio.stdin)
			if null:fileno() > 2 then
				null:close()
			end
		end

		-- replace with target command
		nixio.exec("/bin/sh", "-c", command)
	end
end

local function storage_size()
	local size = 0
	if nixio.fs.access("/proc/mtd") then
		for l in io.lines("/proc/mtd") do
			local d, s, e, n = l:match('^([^%s]+)%s+([^%s]+)%s+([^%s]+)%s+"([^%s]+)"')
			if n == "linux" or n == "firmware" then
				size = tonumber(s, 16)
				break
			end
		end
	elseif nixio.fs.access("/proc/partitions") then
		for l in io.lines("/proc/partitions") do
			local x, y, b, n = l:match('^%s*(%d+)%s+(%d+)%s+([^%s]+)%s+([^%s]+)')
			if b and n and not n:match('[0-9]') then
				size = tonumber(b) * 1024
				break
			end
		end
	end
	return size
end
		
local function image_checksum(image)
	return (luci.sys.exec("md5sum %q" % image):match("^([^%s]+)"))
end

local function image_supported(image)
	return (os.execute("sysupgrade -T %q >/dev/null" % image) == 0)
end

function action_upgrade()
	local fs = require "nixio.fs"
	local http = require "luci.http"
	local keep = ""
	local step = tonumber(http.formvalue("step") or 1)
	if step == 1 then
		if pcall(dofile, "/tmp/firmware.ini") and _G.FIRMWARE_NAME then
			filename = _G.FIRMWARE_NAME
			version = _G.FIRMWARE_VERSION
			md5sum = _G.FIRMWARE_MD5SUM
			size = _G.FIRMWARE_SIZE
		end

		local url = update_server .. "/" .. product_name .. "/" .. filename 
		luci.util.exec("wget " .. url .. " -O " .. image_tmp)
	
		if image_supported(image_tmp) and md5sum == image_checksum(image_tmp)  then
			luci.template.render("onlineupgrade/online_upgrade", {
				checksum = image_checksum(image_tmp),
				storage  = storage_size(),
				size     = (fs.stat(image_tmp, "size") or 0),
				keep     = (not not http.formvalue("keep"))
			})
		else
			fs.unlink(image_tmp)
			luci.template.render("onlineupgrade/error", {
				image_invalid = true
			})
		end
	elseif step == 2 then
		luci.template.render("admin_system/applyreboot", {
			title = luci.i18n.translate("Flashing..."),
			msg   = luci.i18n.translate("The system will flashing after download firmware.<br /> DO NOT POWER OFF THE DEVICE!<br /> Wait a few minutes before you try to reconnect. It might be necessary to renew the address of your computer to reach the device again, depending on your settings."),
		})
		fork_exec("sleep 1; killall dropbear uhttpd lighttpd; sleep 1; /sbin/sysupgrade %s %q" %{ keep, image_tmp })
	end
	
	
end
