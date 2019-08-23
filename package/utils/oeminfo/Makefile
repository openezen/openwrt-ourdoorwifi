#
# Copyright (C) 2006-2010 OpenWrt.org.cn
#

include $(TOPDIR)/rules.mk

PKG_NAME:=oeminfo
PKG_VERSION:=1.0
PKG_RELEASE:=0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -r ./* $(PKG_BUILD_DIR)/
endef


define Build/Compile	
	$(MAKE) -C $(PKG_BUILD_DIR)/luasrc $(TARGET_CONFIGURE_OPTS)
endef

define Package/oeminfo
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Oem utilities
  DEFAULT:=n
endef

define Package/oeminfo/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/zz-oeminfo $(1)/etc/uci-defaults/
	$(INSTALL_DIR) $(1)/usr/lib/lua/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/oeminfo $(1)/usr/lib/lua/oeminfo.lua
endef

$(eval $(call BuildPackage,oeminfo))
