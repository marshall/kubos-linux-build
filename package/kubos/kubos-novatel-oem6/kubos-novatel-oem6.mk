###############################################
#
# Kubos NovAtel OEM6 Service
#
###############################################

KUBOS_NOVATEL_OEM6_POST_BUILD_HOOKS += OEM6_BUILD_CMDS
KUBOS_NOVATEL_OEM6_POST_INSTALL_TARGET_HOOKS += OEM6_INSTALL_TARGET_CMDS
KUBOS_NOVATEL_OEM6_POST_INSTALL_TARGET_HOOKS += OEM6_INSTALL_INIT_SYSV

define OEM6_BUILD_CMDS
	cd $(BUILD_DIR)/kubos-$(KUBOS_VERSION)/services/novatel-oem6-service && \
	PATH=$(PATH):~/.cargo/bin:/usr/bin/iobc_toolchain/usr/bin && \
	cargo build --target $(CARGO_TARGET) --release
endef

# Install the application into the rootfs file system
define OEM6_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/sbin
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/kubos-$(KUBOS_VERSION)/$(CARGO_OUTPUT_DIR)/novatel-oem6-service \
		$(TARGET_DIR)/usr/sbin
endef

# Install the init script
define OEM6_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_KUBOS_LINUX_PATH)/package/kubos/kubos-novatel-oem6/kubos-novatel-oem6 \
	    $(TARGET_DIR)/etc/init.d/S$(BR2_KUBOS_NOVATEL_OEM6_INIT_LVL)kubos-novatel-oem6
endef

$(eval $(virtual-package))