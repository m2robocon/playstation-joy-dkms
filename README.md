# playstation-joy-dkms
Use the new `hid-sony` and `hid-playstation` modules from the mainline in old Linux kernels!

## How this works?

This package blacklists the existing `hid-sony` and `hid-playstation` kernel modules from loading. Instead, the new kernel modules `hid-sony-joy` and `hid-playstation-joy` provided by this package will be used instead.

```console
$ lsmod | grep joy
hid_sony_joy           40960  0
hid_playstation_joy    20480  0
ff_memless             20480  2 hid_playstation_joy,hid_sony_joy
joydev                 32768  0
```

## How to install

1. Update your Ubuntu to the latest version first, and reboot (with the latest Linux kernel)

```bash
sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade
sudo reboot
```

2. Prepare the environment for kernel module compiling. Ensure your `/etc/apt/sources.list` whether the below `deb-src` are enabled/uncommented or not. Replace `focal` with your distribution version of Ubuntu.

```bash
deb-src http://archive.ubuntu.com/ubuntu focal main
deb-src http://archive.ubuntu.com/ubuntu focal-updates main
```

3. Install the build dependencies of the linux kernel

```bash
sudo apt-get update
sudo apt-get build-dep linux linux-image-$(uname -r)
```

4. Download latest release from [here](https://github.com/m2robocon/playstation-joy-dkms/releases/latest), or build it yourself using the instructions below.

5. Install required `playstation-joy-dkms` dependencies

```bash
sudo apt-get install build-essential dkms
```

6. Install the deb package

```bash
sudo apt-get install ./playstation-joy-dkms_20220314-1.deb

# or

sudo dpkg -i ./playstation-joy-dkms_20220314-1.deb

```

- This command will automatically compile the DKMS modules upon install. If the build failed, verify have you installed the kernel build dependencies correctly.
    - Retry DKMS installation: `sudo dkms autoinstall`
    - If `make` keeps failing, manually debug by `cd` to `/usr/src/playstation-joy-dkms-VERSIONHERE` and run `make` here manually.

7. Reboot your computer to take effect

```bash
sudo reboot
```

## Building new Debian package (.deb) yourself

1. You will need `git` and `make` to build the files. Installing `build-essential` in Ubuntu will do.

```bash
sudo apt-get update
sudo apt-get install git build-essential
```

2. Clone or download this repository

```bash
git clone git@github.com:m2robocon/playstation-joy-dkms.git
```

3. If you have modification to the files and want to update on existing machines, change the version parameter in the root `Makefile`. The format is `YYYYMMDD + revision number`:

```makefile
PACKAGE=playstation-joy-dkms
VERSION=20220314-1
```

4. Package it with `make`

```bash
make clean # clean build folder
make prepare # fetch linux from upstream, reset to HEAD, patch files, prepare fakeroot
make deb # package into deb

# or simply:

make all
```

## What files are they?

- `patches`
    - Contains necessary patches for the modules to work properly and better. Will be patched on deb packaging.
- `src/linux`
    - The official `kernel.org` Linux kernel submodule, currently checked out to tag `v5.15`
- `src/playstation-joy-dkms`
    - Simply have symbolic links back to the Linux kernel submodules for editing convenience
    - `Makefile` for dkms compilation on target machine
- `control-template`
    - A template file of `DEBIAN/control`, specifies the debian package metadata
- `pre-uninstall-template.sh`
    - A template file of `DEBIAN/prerm`, the pre-remove script
- `post-install-template.sh`
    - A template file of `DEBIAN/postinst`, the post-install script
- `dkms-template.conf`
    - A template file of `dkms.conf`, specifies the DKMS configurations
- `playstation-joy-dkms.conf`
    - A `/etc/modprobe.d` file to blacklist existing `hid-sony` and `hid-playstation` modules.
- `Makefile`
    - Handles the deb packaging

## Referenced kernel
Sources of `hid-sony` and `hid-playstation` are checked out from the kernel.org tag `v5.15`.

To use an another version of reference kernel. `cd` to the `src/linux` submodule and checkout the commit or tag you want:

```bash
cd src/linux
git fetch --all --tags
git checkout tags/v5.15
```

## License
Licensed under GPLv3.
