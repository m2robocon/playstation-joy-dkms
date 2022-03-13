PACKAGE=playstation-joy-dkms
VERSION=20220314-1
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
# make fake package root
	mkdir -p $(DEB_BUILD_PATH)/DEBIAN
	mkdir -p $(DKMS_SRC_PATH)
# generate config and scripts from templates
	sed -e "s/@@PACKAGE@@/$(PACKAGE)/g" -e "s/@@VERSION@@/$(VERSION)/g" dkms-template.conf > $(DKMS_SRC_PATH)/dkms.conf
	sed -e "s/@@PACKAGE@@/$(PACKAGE)/g" -e "s/@@VERSION@@/$(VERSION)/g" control-template > $(DEB_BUILD_PATH)/DEBIAN/control
	sed -e "s/@@PACKAGE@@/$(PACKAGE)/g" -e "s/@@VERSION@@/$(VERSION)/g" pre-uninstall-template.sh > $(DEB_BUILD_PATH)/DEBIAN/prerm
	sed -e "s/@@PACKAGE@@/$(PACKAGE)/g" -e "s/@@VERSION@@/$(VERSION)/g" post-install-template.sh > $(DEB_BUILD_PATH)/DEBIAN/postinst
	chmod 0555 $(DEB_BUILD_PATH)/DEBIAN/prerm
	chmod 0555 $(DEB_BUILD_PATH)/DEBIAN/postinst
# copy src
	cp -v src/playstation-joy-dkms/* $(DKMS_SRC_PATH)/
# copy modprobe config
	mkdir -p $(DEB_BUILD_PATH)/etc/modprobe.d
	cp -v playstation-joy-dkms.conf $(DEB_BUILD_PATH)/etc/modprobe.d/

deb:
	cd build; \
	dpkg-deb --build $(PACKAGE)_$(VERSION)
