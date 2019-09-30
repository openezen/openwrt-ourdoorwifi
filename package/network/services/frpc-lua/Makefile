include $(TOPDIR)/rules.mk

PKG_NAME:=frpc-lua
PKG_RELEASE:=0.9.3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/spyderj-cn/frpc-in-lua.git
PKG_SOURCE_DATE:=2018-1-12
PKG_SOURCE_VERSION:=f2a90e94d9d91650e711e07ae5c72c6e96b97575


include $(INCLUDE_DIR)/package.mk


define Package/frpc-lua
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+lua +lask
  TITLE:=Frp client in lua
endef

define Build/Compile
endef


define Package/frpc-lua/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/frpc.lua $(1)/usr/sbin/frpc
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/frpctl.lua $(1)/usr/sbin/frpctl
endef


$(eval $(call BuildPackage,frpc-lua))

