
include $(TOPDIR)/rules.mk

PKG_NAME:=datacenter
PKG_RELEASE:=1.0.0


include $(INCLUDE_DIR)/package.mk

define Package/datacenter
  SECTION:=base
  CATEGORY:=Base system
  TITLE:=data center
  DEPENDS:=+lua +lask
endef

define Build/Prepare
  $(CP) ./* $(PKG_BUILD_DIR)/ 
endef

define Build/Compile	
	$(MAKE) -C $(PKG_BUILD_DIR)/luasrc \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		all
endef

define Package/datacenter/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/ajax
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/datacenter  $(1)/usr/sbin/datacenter
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/ajax/qmi  $(1)/usr/lib/lua/ajax/qmi.lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/ajax/qmiinfo  $(1)/usr/lib/lua/ajax
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/ajax/qmisignal  $(1)/usr/lib/lua/ajax
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/datacenter.init  $(1)/etc/init.d/datacenter
endef

$(eval $(call BuildPackage,datacenter))

