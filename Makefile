all: prepare deb

PACKAGE=playstation-joy-dkms
VERSION=20220314-1
BUILD_PATH=build/$(PACKAGE)_$(VERSION)/usr/src/$(PACKAGE)-$(VERSION)

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
	mkdir -p $(BUILD_PATH)/DEBIAN
	sed -e "s/PACKAGE/$(PACKAGE)/g" -e "s/VERSION/$(VERSION)/g" dkms-template.conf > $(BUILD_PATH)/dkms.conf
	sed -e "s/PACKAGE/$(PACKAGE)/g" -e "s/VERSION/$(VERSION)/g" control-template > $(BUILD_PATH)/DEBIAN/control

clean:
	rm -rfv build

reset:
	cd src/linux; \
	git reset --hard

deb:
	$(MAKE) prepare	

.PHONY: prepare clean reset deb