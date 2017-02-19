#!/bin/bash

# OpenOCD does not make releases very often,
# and many times you are relied on having
# support for the latest chips and features.
#
# Then you clone git master and build your
# own version of openocd, though you could
# have bad lock and get an unstable version.
#
# The openocd4all does try to define a relaease
# including patches in git gerrit that are
# required to get the latest features I need.
#
# Version 1.
# Git master openocd-0.10.0 snapshot from 20160831.
# Commit id 81631e49a608be93af0a473ec3f099cb556a2c8a.
# Added patches for TI cc13xx from gerrit.
#
# Version 2.
# Added patches for Nordic Semi NRF52.
# Mixed realpath not available on all Linux dists.
#
# Version 3.
# Added patches for Energy Micro/Silicon Labs EFR32.
# Update git repo paths with mirror.
#
# You need to have automake package installed to build.
#   sudo apt-get install automake
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
#
# Note for CMSIS-DAP you nedd libhidapi-dev
#   sudo apt-get install libhidapi-dev

OPENOCD_DIR=.openocd

# checkout openocd master git repository
# links taken from http://openocd.org/repos/
rm -rf $OPENOCD_DIR
# official git
#git clone git://git.code.sf.net/p/openocd/code $OPENOCD_DIR
# mirror if behind firewall, try HTTP
git clone http://repo.or.cz/r/openocd.git $OPENOCD_DIR

# enter openocd source dir
cd $OPENOCD_DIR

# checkout known working commit
git checkout -q 81631e49a608be93af0a473ec3f099cb556a2c8a

# patches from zylin git gerrit to get extra TI cc13xx support
patch -p1 -i ../patches/27c74939.diff
patch -p1 -i ../patches/8eeaaee5.diff
# patches from zylin git gerrit to get extra Nordic semi nrf52 support
patch -p1 -i ../patches/688f0ad9.diff
patch -p1 -i ../patches/nrf52.diff
# patche to get extra Energy Micro/Silicon Labs EFR32 support
patch -p1 -i ../patches/efr32.diff

# configure openocd, enable all available dongles and some verbose debug
./bootstrap
./configure --verbose --disable-verbose-usb-io --disable-verbose-usb-comms --enable-ftdi --enable-stlink --enable-jlink --enable-rlink --enable-ti-icdi --enable-cmsis-dap --enable-maintainer-mode

# build openocd, do not do make install, keep binary in src dir
make

# dir up
cd ..

# To get absolute path on some platforms have realpath, some readlink
# http://stackoverflow.com/questions/284662/how-do-you-normalize-a-file-path-in-bash
#OPENOCD_DIR_CANONICAL=$(realpath "$OPENOCD_DIR")
OPENOCD_DIR_CANONICAL=$(readlink -e "$OPENOCD_DIR")
OPENOCD_FOR_ALL=oo4all

# create start script
echo "#!/bin/bash" > $OPENOCD_FOR_ALL
echo "$OPENOCD_DIR_CANONICAL/src/openocd -s $OPENOCD_DIR_CANONICAL -s $OPENOCD_DIR_CANONICAL/tcl \"\$@\"" >> $OPENOCD_FOR_ALL
chmod a+x $OPENOCD_FOR_ALL

# done
echo "Start openocd with: sudo $OPENOCD_FOR_ALL -f your_script.cfg"
