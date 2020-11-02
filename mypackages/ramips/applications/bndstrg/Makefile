#
# Copyright (C) 2010-2013 hua.shao@mediatek.com
#
# MTK Property Software.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bndstrg
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_KCONFIG:=RALINK_MT7620 RALINK_MT7621 RALINK_MT7628
PKG_CONFIG_DEPENDS:=$(foreach c, $(PKG_KCONFIG),$(if $(CONFIG_$c),CONFIG_$(c)))


include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/bndstrg
  SECTION:=MTK Properties
  CATEGORY:=MTK Properties
  TITLE:=Daemon to band steering
  SUBMENU:=Applications
  DEPENDS:=+libpthread +librt +libcurl
endef

define Package/bndstrg/description
  Daemon to monitor gpio buttons
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef


define Package/bndstrg/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/bndstrg
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bndstrg $(1)/usr/bin
	-$(CP) ./files/*.sh  $(1)/etc/bndstrg/
endef


$(eval $(call BuildPackage,bndstrg))

