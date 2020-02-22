#!/usr/bin/lua

if not arg[1]  then
        io.stderr:write('argument #1 is a must.\n')
        os.exit(1)
end

function dostring(str, ...)
        local func, errmsg = loadstring(str)
        if func then
                argv = {...}
                return func()
        else
                io.stderr:write(errmsg)
                os.exit(1)
        end
end

require 'std'

local segments = arg[1]:tokenize('.')
local depth = #segments
local pkg = false
local M = _G

for i = 1, depth - 1 do 
        M = M[segments[i]]
        if not M then
                pkg = pkg and pkg .. '.' .. segments[i] or segments[i]
                local ok, ret = pcall(require, pkg)
                if not ok then
                        io.stderr:write('module "', pkg, '" is not found\n')
                        os.exit(1)
                end
                M = ret
        end
end
table.remove(arg, 1)

local func = M[segments[depth]]
if not func then
        io.stderr:write('function "', segments[depth], '" is not found.\n')
        os.exit(1)
end
local ok, val = pcall(func, unpack(arg))
if not ok then
        io.stderr:write('execution error: ', val, '\n')
        os.exit(1)
end
local tval = type(val)
if tval == 'table' then
        if #val > 0 then
                for _, v in ipairs(val) do 
                        io.stdout:write(v, '\n')
                end
        else
                for k, v in ipairs(val) do 
                        io.stdout:write(k, '=', v, '\n')
                end
        end
elseif tval == 'boolean' then
        io.stdout:write(val and 1 or 0)
elseif val then
        io.stdout:write(val)
end