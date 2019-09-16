
local tasklet = require 'tasklet'

local M = {}
local prev_ifaces

tasklet.start_task(function ()
	local i = 0
	while true do
		tasklet.sleep(10)
		fs.unlink('/tmp/qmisignal.data')
		if i % 6 == 5 then
			fs.unlink('/tmp/qmiinfo.data')
		end
		i = i + 1
	end
end)

function M.qmisignal()
	local data = {}
	
	data = file_get_content('/tmp/qmisignal.data')
	
	if not data then
		local file = io.popen(string.format('/usr/lib/lua/ajax/qmisignal 2>/dev/null'))
		if file then
			data = file:read('*all')
			file:close()
		end
	end
	
	self.json_str = data or ''
end

function M.qmiinfo()
	local data = {}
	data = file_get_content('/tmp/qmiinfo.data')
	if not data then
		local file = io.popen(string.format('/usr/lib/lua/ajax/qmiinfo 2>/dev/null'))
		if file then
			data = file:read('*all')
			file:close()
		end
	end
	
	self.json_str = data or ''
end

return M
