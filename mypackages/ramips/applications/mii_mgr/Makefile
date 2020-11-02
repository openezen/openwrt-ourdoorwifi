#
# Copyright (C) 2010-2013 hua.shao@mediatek.com
#
# MTK Property Software.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mii_mgr
PKG_RELEASE:=1

ifeq ($(CONFIG_TARGET_ralink_mt7620),y)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_mt7620
endif

ifeq ($(CONFIG_TARGET_ralink_RE1000),y)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_mt7620
endif

ifeq ($(CONFIG_TARGET_ralink_RH300),y)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_mt7620
endif

ifeq ($(CONFIG_TARGET_ramips_mt7621),y)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_mt7621
endif

ifeq ($(CONFIG_TARGET_ramips_softrouter),y)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_mt7621
endif

ifeq ($(CONFIG_TARGET_ramips_RE1550),y)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_mt7621
endif

ifeq ($(CONFIG_TARGET_ramips_mt7621a),y)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_mt7621
endif

ifeq ($(CONFIG_TARGET_ramips_S2A),y)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_mt7621
endif

ifeq ($(CONFIG_TARGET_ramips_S3A),y)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_mt7621
endif

ifeq ($(CONFIG_TARGET_ramips_RN1200B),y)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_mt7621
endif

ifeq ($(CONFIG_TARGET_ramips_RSC200BW),y)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_mt7621
endif

ifeq ($(CONFIG_TARGET_ramips_GOCLOUD),y)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_mt7621
endif

ifeq ($(CONFIG_TARGET_ramips_mt7620a),y)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_mt7620a
endif

ifeq ($(CONFIG_TARGET_ramips_POE),y)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_mt7621
endif

ifeq ($(CONFIG_TARGET_ramips_THR80GW),y)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_mt7621
endif

ifeq ($(CONFIG_TARGET_ramips_mt7628),y)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_mt7628
endif

ifeq ($(CONFIG_TARGET_ramips_mt7628P2),y)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_mt7628
endif

PKG_KCONFIG:=RALINK_MT7620 RALINK_MT7621 RALINK_MT7628
PKG_CONFIG_DEPENDS:=$(foreach c, $(PKG_KCONFIG),$(if $(CONFIG_$c),CONFIG_$(c)))


include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/mii_mgr
  SECTION:=MTK Properties
  CATEGORY:=MTK Properties
  TITLE:=mii_mgr
  SUBMENU:=Applications
endef

define Package/mii_mgr/description
  An program.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

TARGET_CFLAGS += $(foreach c, $(PKG_KCONFIG),$(if $(CONFIG_$c),-DCONFIG_$(c)))

ifeq ($(CONFIG_TARGET_ramips_mt7620a),y)
TARGET_CFLAGS += \
	-I$(LINUX_DIR)/drivers/net/raeth \
	-DCONFIG_TARGET_ramips_mt7620
else
  ifeq ($(CONFIG_TARGET_ramips_mt7628),y)
    TARGET_CFLAGS += \
     -I$(LINUX_DIR)/drivers/net/raeth 
  else
    ifeq ($(CONFIG_TARGET_ramips_mt7628P2),y)
      TARGET_CFLAGS += \
       -I$(LINUX_DIR)/drivers/net/raeth 
    else
      TARGET_CFLAGS += \
       -I$(LINUX_DIR)/drivers/net/raeth 
    endif
  endif
endif
	

define Build/Configure
endef

define Package/mii_mgr/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mii_mgr $(1)/usr/bin
endef


$(eval $(call BuildPackage,mii_mgr))

