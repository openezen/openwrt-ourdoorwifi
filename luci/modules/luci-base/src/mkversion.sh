#!/bin/sh

cat <<EOF > $1
local pcall, dofile, _G = pcall, dofile, _G

module "luci.version"

if pcall(dofile, "/etc/openwrt_release") and _G.DISTRIB_DESCRIPTION then
	distname    = _G.DISTRIB_ID
	distoemname = _G.DISTRIB_NAME
	distversion = _G.DISTRIB_DESCRIPTION
	distrevision = _G.DISTRIB_REVISION
else
	distname    = "OpenWrt"
	distversion = "Development Snapshot"
end

luciname    = "${3:-LuCI}"
luciversion = "${2:-Git}"
EOF
