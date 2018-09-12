#!/bin/bash

#
# Openocd For All.
#
# OpenOCD does not make releases very often,
# and many times you are dependent on having
# support for the latest chips and features.
#
# Then you clone git master and build your
# local snapshot of openocd, though you could
# have bad luck and get an unstable version.
#
# The openocd4all does try to define a relaease
# including patches in git gerrit that are
# required to get the latest features I need.
#
# You need to have automake package installed to build.
#   sudo apt-get install automake
#
# For Ubuntu 17.04 and possibly others you need libtool-bin.
#   sudo apt-get install libtool-bin
#
# You also need libusb-1.0-0-dev, libusb-dev and libftdi-dev/dbg
#   sudo apt-get install libusb-1.0-0-dev
#   sudo apt-get install libusb-1.0-0-dbg
#   sudo apt-get install libusb-dev
#   sudo apt-get install libftdi1
#   sudo apt-get install libftdi-dev
#   sudo apt-get install libftdi1-dev
#   sudo apt-get install libftdi1-dbg
#   sudo apt-get install libftdi1-2
#   sudo apt-get install libftdi1-2-dbg
#   sudo apt-get install build-essential
#   sudo apt-get install libtool
#   sudo apt-get install automake
#   sudo apt-get install pkg-config
#
# Note for CMSIS-DAP you nedd libhidapi-dev
#   sudo apt-get install libhidapi-dev
#
# ------------------------------------------
# Version 1.
# Git master version
#

# Set default names
OPENOCD_DIR=.openocd
OPENOCD_EXE=oo4all

# Clean old builds
rm -rf $OPENOCD_DIR
rm $OPENOCD_EXE

# To get absolute path on some platforms have realpath, some readlink
# http://stackoverflow.com/questions/284662/how-do-you-normalize-a-file-path-in-bash
#OPENOCD_DIR_CANONICAL=$(realpath "$OPENOCD_DIR")
OPENOCD_DIR_CANONICAL=$(readlink -m "$OPENOCD_DIR")
echo "Canonical path to build: $OPENOCD_DIR_CANONICAL"

# Checkout openocd master git repository
# links taken from http://openocd.org/repos/
# official git
#git clone git://git.code.sf.net/p/openocd/code $OPENOCD_DIR
# mirror if behind firewall, try HTTP
git clone http://repo.or.cz/r/openocd.git $OPENOCD_DIR

# Enter openocd source dir
cd $OPENOCD_DIR

# Checkout known working commit
#git checkout -q 81631e49a608be93af0a473ec3f099cb556a2c8a
git checkout -q c2b2a7a3b84913465420ae7fa0394304943cf035
#git checkout master

# Apply patches
# patches from zylin git gerrit to get extra TI cc13xx support
#patch -p1 -i ../patches/27c74939.diff
#patch -p1 -i ../patches/8eeaaee5.diff
# patches from zylin git gerrit to get extra Nordic semi nrf52 support
#patch -p1 -i ../patches/688f0ad9.diff
#patch -p1 -i ../patches/nrf52.diff
# patch to get extra Energy Micro/Silicon Labs EFR32 support
#patch -p1 -i ../patches/efr32.diff

# patch to get extra IMX7 Sabre board support
patch -p1 -i ../patches/911d198.diff
# patch to get extra EFR32 support
patch -p1 -i ../patches/3510e88.diff

# Configure openocd, enable all available dongles and some verbose debug
./bootstrap
./configure --verbose --disable-verbose-usb-io --disable-verbose-usb-comms --enable-ftdi --enable-stlink --enable-jlink --enable-rlink --enable-ti-icdi --enable-cmsis-dap --enable-maintainer-mode --prefix="$OPENOCD_DIR_CANONICAL/build" --exec-prefix="$OPENOCD_DIR_CANONICAL/build"

# Build openocd, do not do make install, keep binary in src dir
make
# Copies from src dir into build dir
make install

# Dir up
cd ..

# Create start script
echo "#!/bin/bash" > $OPENOCD_EXE
echo "$OPENOCD_DIR_CANONICAL/build/bin/openocd -s $OPENOCD_DIR_CANONICAL/build/share/openocd/scripts \"\$@\"" >> $OPENOCD_EXE
chmod a+x $OPENOCD_EXE

# Done
echo "Start openocd with: sudo $OPENOCD_EXE -f your_script.cfg"
