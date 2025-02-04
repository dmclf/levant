#!/bin/bash 
#
# quick n dirty .deb generation
#

VERSION=$(scripts/version.sh version/version.go version/version.go)
PACKAGE="levant"

rm -rf tmpdebs/
mkdir tmpdebs/ tmpdebs/arm64 tmpdebs/arm64/DEBIAN tmpdebs/arm64/usr tmpdebs/arm64/usr/bin tmpdebs/amd64 tmpdebs/amd64/DEBIAN tmpdebs/amd64/usr tmpdebs/amd64/usr/bin
touch tmpdebs/arm64/DEBIAN/conffiles tmpdebs/arm64/DEBIAN/control tmpdebs/arm64/DEBIAN/md5sums
touch tmpdebs/amd64/DEBIAN/conffiles tmpdebs/amd64/DEBIAN/control tmpdebs/amd64/DEBIAN/md5sums


for arch in arm64 amd64
do

ln bin/levant.${arch} tmpdebs/${arch}/usr/bin/levant 
md5sum tmpdebs/${arch}/usr/bin/levant > tmpdebs/${arch}/DEBIAN/md5sums


cat << EOF > tmpdebs/${arch}/DEBIAN/control
Package: ${PACKAGE}-dmclf
Version: $VERSION
Section: 
Priority: optional
Architecture: ${arch}
Maintainer: DMcLF
UnMaintained: HashiCorp
Installed-Size: `du -ks bin/levant.${arch} |cut -f1`
Depends: openssl
Conflicts: levant
Replaces: levant
Homepage: https://github.com/dmclf/levant
Description: Levant is a templating and deployment tool for HashiCorp Nomad, but HashiCorp no longer maintains it.
EOF

if test ! -d debs;then mkdir debs;fi
fakeroot dpkg-deb -Zgzip -b tmpdebs/${arch} debs/${PACKAGE}_${VERSION}_${arch}.deb

done
