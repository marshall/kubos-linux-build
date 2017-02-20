################################################################################
#
# xe-guest-utilities
#
################################################################################

XE_GUEST_UTILITIES_VERSION = v6.6.80
XE_GUEST_UTILITIES_SITE = https://github.com/xenserver/xe-guest-utilities/archive
XE_GUEST_UTILITIES_SOURCE = $(XE_GUEST_UTILITIES_VERSION).tar.gz

XE_GUEST_UTILITIES_LICENSE = Apache-2.0
XE_GUEST_UTILITIES_LICENSE_FILES = LICENSE

XE_GUEST_UTILITIES_DEPENDENCIES = host-go

XE_GUEST_UTILITIES_GLDFLAGS = \
	-X github.com/xenserver/xe-guest-utilities/version.Version=$(XE_GUEST_UTILITIES_VERSION) \

ifeq ($(BR2_STATIC_LIBS),y)
XE_GUEST_UTILITIES_GLDFLAGS += -extldflags '-static'
endif

XE_GUEST_UTILITIES_MAKE_ENV = \
	$(HOST_GO_TARGET_ENV) \
	GOBIN="$(@D)/bin" \
	GOPATH="$(@D)/gopath" \
	CGO_ENABLED=1 \
	GO_BUILD="$(HOST_DIR)/usr/bin/go build" \
	GO_FLAGS="-a -x -ldflags '$(XE_GUEST_UTILITIES_GLDFLAGS)'"

XE_SOURCEDIR = "$(@D)/mk"
XE_OBJECTDIR = "$(@D)/build/obj"

define XE_GUEST_UTILITIES_CONFIGURE_CMDS
	# Put sources at prescribed GOPATH location.
	mkdir -p $(@D)/gopath/src/github.com/xenserver
	ln -s $(@D) $(@D)/gopath/src/github.com/xenserver/xe-guest-utilities
endef

define XE_GUEST_UTILITIES_BUILD_CMDS
	cd $(@D) && $(XE_GUEST_UTILITIES_MAKE_ENV) make -e \
		$(@D)/build/obj/xe-daemon $(@D)/build/obj/xenstore
endef

define XE_GUEST_UTILITIES_INSTALL_TARGET_CMDS
	$(INSTALL) -m 755 $(XE_SOURCEDIR)/xe-linux-distribution.init $(TARGET_DIR)/etc/init.d/xe-linux-distribution
	$(INSTALL) -m 755 $(XE_SOURCEDIR)/xe-linux-distribution $(TARGET_DIR)/usr/sbin/xe-linux-distribution
	$(INSTALL) -m 755 $(XE_OBJECTDIR)/xe-daemon $(TARGET_DIR)/usr/sbin/xe-daemon
	$(INSTALL) -m 755 $(XE_OBJECTDIR)/xenstore $(TARGET_DIR)/usr/bin/xenstore
	ln -sf /usr/bin/xenstore $(TARGET_DIR)/usr/bin/xenstore-read
	ln -sf /usr/bin/xenstore $(TARGET_DIR)/usr/bin/xenstore-write
	ln -sf /usr/bin/xenstore $(TARGET_DIR)/usr/bin/xenstore-exists
	ln -sf /usr/bin/xenstore $(TARGET_DIR)/usr/bin/xenstore-rm
	$(INSTALL) -d $(TARGET_DIR)/etc/udev/rules.d/
	$(INSTALL) -m 644 $(XE_SOURCEDIR)/xen-vcpu-hotplug.rules $(TARGET_DIR)/etc/udev/rules.d/z10_xen-vcpu-hotplug.rules
endef

$(eval $(generic-package))
