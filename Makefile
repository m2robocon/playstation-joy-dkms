PACKAGE=playstation-joy-dkms
VERSION=20220317-1-multicolor
DEB_BUILD_PATH=build/$(PACKAGE)_$(VERSION)
DKMS_SRC_PATH=build/$(PACKAGE)_$(VERSION)/usr/src/$(PACKAGE)-$(VERSION)

.PHONY: clean prepare deb

all: clean prepare deb

clean:
	rm -rfv build

prepare:
# download the submodules
	git submodule update --init
# reset the linux repo to original state
	cd src/linux; \
	git reset --hard
# apply patches
	patch -u src/linux/drivers/hid/hid-playstation.c patches/0001-enable-hid-playstation-ff.patch
	patch -u src/linux/drivers/hid/hid-sony.c patches/0002-enable-hid-sony-ff.patch
	patch -u src/linux/drivers/hid/hid-playstation.c patches/0003-define-led-function-player-wrapper.patch
	patch -u src/linux/drivers/hid/hid-sony.c patches/0004-revert-hid-sony-no-hid-is-usb.patch
# make fake package root
	mkdir -p $(DEB_BUILD_PATH)/DEBIAN
	mkdir -p $(DKMS_SRC_PATH)
# generate config and scripts from templates
	sed -e "s/@@PACKAGE@@/$(PACKAGE)/g" -e "s/@@VERSION@@/$(VERSION)/g" control-template > $(DEB_BUILD_PATH)/DEBIAN/control; \
	sed -e "s/@@PACKAGE@@/$(PACKAGE)/g" -e "s/@@VERSION@@/$(VERSION)/g" pre-uninstall-template.sh > $(DEB_BUILD_PATH)/DEBIAN/prerm; \
	sed -e "s/@@PACKAGE@@/$(PACKAGE)/g" -e "s/@@VERSION@@/$(VERSION)/g" post-install-template.sh > $(DEB_BUILD_PATH)/DEBIAN/postinst
	chmod 0555 $(DEB_BUILD_PATH)/DEBIAN/prerm
	chmod 0555 $(DEB_BUILD_PATH)/DEBIAN/postinst
# copy src
	if [ "$$INCLUDE_LED_CLASS_MULTICOLOR" = true ] ; then \
		echo Applying LED class multicolor patches; \
		patch -u src/linux/drivers/hid/hid-playstation.c patches/0091-hid-playstation-use-our-multicolor.patch; \
		patch -u src/linux/include/linux/led-class-multicolor.h patches/0092-enable-led-class-multicolor.patch; \
		patch -u src/linux/drivers/leds/led-class-multicolor.c patches/0093-led-class-multicolor-source-fix-header.patch; \
		echo Copying led-class-multicolor files; \
		cp -v src/playstation-joy-dkms/leds.h $(DKMS_SRC_PATH)/; \
		cp -v src/playstation-joy-dkms/led-class-multicolor.* $(DKMS_SRC_PATH)/; \
		cp -v src/playstation-joy-dkms/Makefile.multicolor $(DKMS_SRC_PATH)/Makefile; \
		sed -e "s/@@PACKAGE@@/$(PACKAGE)/g" -e "s/@@VERSION@@/$(VERSION)/g" dkms-multicolor-template.conf > $(DKMS_SRC_PATH)/dkms.conf; \
	else \
		cp -v src/playstation-joy-dkms/Makefile.default $(DKMS_SRC_PATH)/Makefile; \
		sed -e "s/@@PACKAGE@@/$(PACKAGE)/g" -e "s/@@VERSION@@/$(VERSION)/g" dkms-template.conf > $(DKMS_SRC_PATH)/dkms.conf; \
	fi
	cp -v src/playstation-joy-dkms/hid-* $(DKMS_SRC_PATH)/
# copy modprobe config
	mkdir -p $(DEB_BUILD_PATH)/etc/modprobe.d
	cp -v playstation-joy-dkms.conf $(DEB_BUILD_PATH)/etc/modprobe.d/

deb:
	cd build; \
	dpkg-deb --build $(PACKAGE)_$(VERSION)
