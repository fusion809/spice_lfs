#!/bin/bash

# Originally a Slackware build script for spice
# Brenton Horne maintains it as LFS build script

# Originally maintained by 2013-2025 Matteo Bernardini <ponce@slackbuilds.org>, Pisa, Italy
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

cd $(dirname $0) ; CWD=$(pwd)

PRGNAM=xf86-video-qxl
VERSION=${VERSION:-0.1.6}

if [ -z "$ARCH" ]; then
  case "$( uname -m )" in
    i?86) ARCH=i586 ;;
    arm*) ARCH=arm ;;
       *) ARCH=$( uname -m ) ;;
  esac
fi

# If the variable PRINT_PACKAGE_NAME is set, then this script will report what
# the name of the created package would be, and then exit. This information
# could be useful to other scripts.
if [ ! -z "${PRINT_PACKAGE_NAME}" ]; then
  echo "$PRGNAM-$VERSION-$ARCH-$BUILD$TAG.$PKGTYPE"
  exit 0
fi

if [ "$ARCH" = "i586" ]; then
  SLKCFLAGS="-O2 -march=i586 -mtune=i686"
elif [ "$ARCH" = "i686" ]; then
  SLKCFLAGS="-O2 -march=i686 -mtune=i686"
elif [ "$ARCH" = "x86_64" ]; then
  SLKCFLAGS="-O2 -fPIC"
else
  SLKCFLAGS="-O2"
fi

if [ "${XSPICE:-no}" = "yes" ]; then
  with_xspice="--enable-xspice=yes"
else
  with_xspice=""
fi

set -e

rm -rf $PRGNAM-$VERSION
filename=$PRGNAM-$VERSION.tar.xz
if ! [[ -f $filename ]]; then
	wget -c https://xorg.freedesktop.org/releases/individual/driver/$filename
fi
tar xvf $CWD/$filename
cd $PRGNAM-$VERSION
patch -p1 < $CWD/libdrm.patch

# autogen.sh can be used in place of configure
./configure \
  --prefix=/usr \
  --libdir=/usr/lib \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --mandir=/usr/man \
  --docdir=/usr/share/doc/$PRGNAM-$VERSION \
  $with_xspice

make -j$(nproc)
sudo make install DESTDIR=/

# add a config file for Xorg and another one for Xspice (if needed)
sudo install -m 0644 -D $CWD/05-qxl.conf \
  /usr/share/X11/xorg.conf.d/05-qxl.conf.new
sudo install -m 0644 -D examples/spiceqxl.xorg.conf.example \
    /etc/X11/spiceqxl.xorg.conf.new
sudo install -m 0755 -D scripts/Xspice /usr/bin/Xspice

sudo mkdir -p /usr/share/doc/$PRGNAM-$VERSION
sudo cp -a COPYING README* TODO* /usr/share/doc/$PRGNAM-$VERSION

