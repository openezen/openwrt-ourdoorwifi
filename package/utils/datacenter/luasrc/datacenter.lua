#!/usr/bin/lua

require "std"
local tasklet = require 'tasklet'
local http = require 'http'
local log = require 'log'
local urlparse = require 'urlparse'
local cjson = require 'cjson'
require 'tasklet.channel.stream'


local ajax_tree = {}
local MAX_FD = 64

local usage = [[
usage:
	-l --loglevel=
	-f --foregroud
	-d --debug
	-h --help
]]

local env = setmetatable({
	tasklet = tasklet,
	log = log,
	self = false,
	table = table,
	io = io,
	os = os,
	string = string,
	table = table,
	fs = fs,
	errno = errno,
	time = time,
	math = math,
	type = type,
	tonumber = tonumber,
	tostring = tostring,
	pairs = pairs,
	ipairs = ipairs,
	unpack = unpack,
	pcall = pcall,
	xpcall = xpcall,
	require = function (str) return package.loaded[str] end,
	dump = dump,
	NULL = NULL,
	file_get_content = file_get_content,
	file_put_content = file_put_content,
}, {__index = NULL})

local connection = {}
connection.__index = connection

function connection:reset()
	self.status = false
	self.req:reset()
	self.wbuf:reset()
	self.status = false
	self.headers = {}
	self.content_length = -1
end

local const_headers = {
	Server = 'datacenter',
	['Access-Control-Allow-Origin'] =  '*',
	['Access-Control-Allow-Headers'] =  'X-datacenter-Token',
	['Access-Control-Allow-Methods'] =  'GET,POST,OPTIONS',
	['Access-Control-Expose-Headers'] = 'Server',
	['Content-Type'] = 'application/json',
	['Cache-Control'] = 'no-cache'
}

function connection:serl_headers()
	local headers = self.headers
	
	if not headers then return end

	local wbuf = self.wbuf	
	wbuf:putstr(string.format('HTTP/1.1 %d %s\r\n', self.status or 200, self.reason or 'OK'))
	if self.content_length < 0 then
		headers['Transfer-Encoding'] = 'chunked'
	else
		headers['Content-Length'] = tostring(self.content_length)
	end
		
	for k, v in pairs(headers) do
		wbuf:putstr(k, ": ", v, "\r\n")
	end
	for k, v in pairs(const_headers) do 
		if not headers[k] then
			wbuf:putstr(k, ": ", v, "\r\n")
		end
	end
	wbuf:putstr("\r\n")
	self.headers = false
end

function connection:options()
	self.content_length = 1
	self.status = 200
	self.reason = 'OK'
	self.headers.Allow = 'GET,POST,OPTIONS'
	self:serl_headers()
	self.ch:write(self.wbuf:putstr('0'))
end

function connection:reply_json(data)
	local json_str = self.json_str or cjson.encode(data == nil and NULL or data)
	
	self.json_str = false
	self.content_length = #json_str
	self.reason = 'OK'
	self:serl_headers()
	
	local buf = self.wbuf
	buf:putstr(json_str)

	self.ch:write(buf)
end

function connection:error(status, reason, msg)
	if msg then
		if msg:match('^%<html%>') then
			self.headers['Content-Type'] = 'text/html'
		else
			self.headers['Content-Type'] = 'text/plain'
		end
		self.content_length = #msg
	else
		self.content_length = 0
	end
	
	self.status = status
	self.reason = reason or http.reasons[status]
	self.content_length = msg and #msg or 0
	
	self:serl_headers()
	if msg then
		self.wbuf:putstr(msg)
	end

	self.ch:write(self.wbuf)
end

function connection:process()
	local urlinfo = self.req.urlinfo
	local segments = urlparse.split_path(urlinfo.path)
	local params = self.req.params
	
	local branch_name = segments[2]
	local node_name = segments[3]
	local node 
	local code = 200
    
	if segments[1] == 'ajax' and branch_name and node_name then
		local branch = ajax_tree[branch_name]
		if branch then
			node = branch[node_name]
		end
	end
	
	if not node then
		self:error(404)
		code = 404
	else
		env.self = self
		setfenv(node, env)
		local ok, ret = pcall(node, segments[4], params)
		if ok then
			self:reply_json(ret)
		else
			log.error(ret)
			self:error(500)
			code = 500
		end
	end
	log[code == 200 and 'debug' or 'warn'](code, ' for ', self.req.urlpath, ' from ', self.addr or 'unix-socket')
end



local function http_hanlder(fd, addr, port)
	if fd > MAX_FD then
		os.close(fd)
		os.execute('logger "datacenter fd overflow"')
		os.exit(1)
	end

	if addr then
		log.info('connection establish with ', addr)
	end

	local channel = tasklet.create_stream_channel(fd)
	local req = http.request.new()
	local task = setmetatable({
		ch = channel,
		req = req,
		status = false,
		reason = false,
		headers = {},
		content_length = -1,
		addr = addr,
		port = port,
		wbuf = buffer.new(),
		nreq = 0
		}, connection)

	local function http_task()
		local authed = addr == '127.0.0.1'
		while channel.ch_fd >= 0 do
			local exit = false
			local err = req:read_header(channel, 20)
			if err == 0 and channel.ch_state > 0 then
				if req.method == "OPTIONS" then
					task:options()
					if addr then
						task:reset()
					else
						channel:close()
					end
				else
					if not authed then
						task:process()
					else
						task:error(403)
					end

					if addr and authed then
						task:reset()
					else
						channel:close()
					end
				end
			else
				channel:close()
			end
		end
		if addr then
			log.info('connection closed with ', addr)
		end
	end

	tasklet.start_task(http_task, task)
end


local function main()
	local opt = getopt(arg, "l:fdh", {'loglevel=', 'foregroud', 'debug', 'help'})
	
	if opt.help or opt.h then
		print(usage)
		os.exit(0)
	end

	local port = "23333"
	local app = require 'app'
	app.APPNAME = "datacenter"
	os.exit(app.run(opt,function()
		app.start_tcpserver_task(nil, port, http_hanlder)
		app.start_unserver_task('/tmp/23333.sock', http_hanlder)
		for filepath in fs.glob("/usr/lib/lua/ajax/*") do 
			local base = string.match(filepath, "([^/]*)%.lua$")
			if base then
				local ok, mod = pcall(dofile, filepath)
				if ok then 
					ajax_tree[base] = mod 
				else
					log.error(mod)
				end
			end
		end
	end
		)
	)

end

main()
