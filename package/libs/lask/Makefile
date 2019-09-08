
include $(TOPDIR)/rules.mk

PKG_NAME:=lask
PKG_RELEASE:=1.2.0

PKG_SOURCE_URL:=https://github.com/spyderj-cn/lask.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2018-1-12
PKG_SOURCE_VERSION:=a8fe0491d382abbc77892ca945619a498ffe8d26

include $(INCLUDE_DIR)/package.mk

define Package/lask
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Lua
  TITLE:=lask
  DEPENDS:=+liblua +libopenssl +zlib +librt +lua
endef

TARGET_CFLAGS+=-I$(PKG_BUILD_DIR)/include -fPIC -std=c99
TARGET_LDFLAGS+=-llua -shared

define Build/Compile	
	$(MAKE) -C $(PKG_BUILD_DIR)/contrib/cjson \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		all
	$(MAKE) -C $(PKG_BUILD_DIR)/lask/ssl \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		all
	$(MAKE) -C $(PKG_BUILD_DIR)/lask/std \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		all
	$(MAKE) -C $(PKG_BUILD_DIR)/lask/zlib \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		all
endef

define Package/lask/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/lib/lua/tasklet
	$(INSTALL_DIR) $(1)/usr/lib/lua/tasklet/channel
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/contrib/cjson/cjson.so $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lask/std/_std.so $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lask/zlib/_zlib.so $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lask/zlib/zlib.lua $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lask/ssl/ssl.so  $(1)/usr/lib/lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lask/luasrc/*.lua $(1)/usr/lib/lua/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lask/luasrc/tasklet/*.lua $(1)/usr/lib/lua/tasklet
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/lask/luasrc/tasklet/channel/*.lua $(1)/usr/lib/lua/tasklet/channel
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lask/tools/ajax.lua  $(1)/usr/sbin/ajax
endef

$(eval $(call BuildPackage,lask))

