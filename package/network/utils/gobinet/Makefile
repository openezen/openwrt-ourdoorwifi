#
# Copyright (C) 2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=gobinet
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define KernelPackage/gobinet
  SUBMENU:=Other modules
  TITLE:=Button Reset driver
  DEPENDS:= +kmod-usb-core +kmod-usb-net 
  FILES:=$(PKG_BUILD_DIR)/GobiNet.$(LINUX_KMOD_SUFFIX)
  KCONFIG:=
  AUTOLOAD:=$(call AutoProbe,GobiNet)
  $(call AddDepends/usb-net,+kmod-usb-serial-qualcomm)
endef

define KernelPackage/gobinet/description
  Kernel module to generate button reset events
endef

EXTRA_KCONFIG:= \
	CONFIG_BUTTON_RESET=m

EXTRA_CFLAGS:= \
	$(patsubst CONFIG_%, -DCONFIG_%=1, $(patsubst %=m,%,$(filter %=m,$(EXTRA_KCONFIG)))) \
	$(patsubst CONFIG_%, -DCONFIG_%=1, $(patsubst %=y,%,$(filter %=y,$(EXTRA_KCONFIG)))) \

EXTRA_CFLAGS+= -DDATA_MODE_RP

MAKE_OPTS:= \
	ARCH="$(LINUX_KARCH)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	SUBDIRS="$(PKG_BUILD_DIR)" \
	EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
	$(EXTRA_KCONFIG)

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
		$(MAKE_OPTS) \
		modules
endef

$(eval $(call KernelPackage,gobinet))
