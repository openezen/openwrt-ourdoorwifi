
local tasklet = require 'tasklet'

local M = {}
local prev_ifaces

tasklet.start_task(function ()
	local i = 0
	while true do
		tasklet.sleep(10)
		fs.unlink('/tmp/mminfo.data')
	end
end)


function M.mminfo()
	local data = {}
	data = file_get_content('/tmp/mminfo.data')
	if not data then
		local file = io.popen(string.format('/usr/lib/lua/ajax/mmcli 2>/dev/null'))
		if file then
			data = file:read('*all')
			file:close()
		end
	end
	
	self.json_str = data or ''
end

return M
