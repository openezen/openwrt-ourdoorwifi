-- Copyright 2019 Xingwang Liao <kuoruan@gmail.com>
-- Licensed to the public under the MIT License.

local uci = require "luci.model.uci".cursor()
local util = require "luci.util"
local fs = require "nixio.fs"
local sys = require "luci.sys"

local m, s, o

m = Map("frpc", translate("Traversal cloud"))

m:append(Template("frpc/status_header"))

s = m:section(SimpleSection)

return m
