#
# Copyright (C) 2015-2018 neil.zhang@siflower.com.cn
#
# sifiower Software.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=autotest
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_KCONFIG:=RALINK_MT7620 RALINK_MT7621 RALINK_MT7628
PKG_CONFIG_DEPENDS:=$(foreach c, $(PKG_KCONFIG),$(if $(CONFIG_$c),CONFIG_$(c)))


include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/autotest
  SECTION:=MTK Properties
  CATEGORY:=MTK Properties
  TITLE:=autotest
  SUBMENU:=Applications
endef

define Package/autotest/description
  autotest.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

TARGET_CFLAGS += \
	-I$(LINUX_DIR)/arch/mips/include \
	-I$(LINUX_DIR)/include \
	-I$(LINUX_DIR)/drivers/char \
	$(foreach c, $(PKG_KCONFIG),$(if $(CONFIG_$c),-DCONFIG_$(c)))

define Build/Configure
endef

define Package/autotest/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/autotest
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/autotest $(1)/usr/bin
	-$(CP) ./files/*  $(1)/etc/autotest/
endef


$(eval $(call BuildPackage,autotest))

