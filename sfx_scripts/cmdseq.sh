#!/bin/bash
set -e
cd /opt/mount/input

cat /opt/mount/input/collectd-build/sfx_scripts/pbuilderrc > ~/.pbuilderrc

rm -rf collectd/debian/
cp -rf collectd-build/debian/ collectd/
cd collectd/

sed -i 's/trusty/'${DISTRIBUTION}'/g' debian/changelog

if [ "$DISTRIBUTION" = "precise" ]; then
patch -p0 < debian/patches/precise_control.patch
patch -p0 < debian/patches/precise_rules.patch
fi

./build.sh
DIST=${DISTRIBUTION} ARCH=amd64 yes | debuild -us -uc -S
rm -rf /opt/mount/pbuilder_results/
mkdir -p /opt/mount/pbuilder_results/debuild
cp -rf ../* /opt/mount/pbuilder_results/debuild/
rm -rf /var/cache/pbuilder/*
sudo DIST=${DISTRIBUTION} ARCH=amd64 pbuilder create
DIST=${DISTRIBUTION} ARCH=amd64 pdebuild /opt/mount/pbuilder_results/debuild/*.dsc
mkdir -p /opt/mount/pbuilder_results/pdebuild/
cp /var/cache/pbuilder/${DISTRIBUTION}-amd64/result/* /opt/mount/pbuilder_results/pdebuild/
rm -rf /var/cache/pbuilder/*
cd ..
rm -rf collectd_*
rm -rf /opt/mount/pbuilder_results/debuild/collectd
rm -rf /opt/mount/pbuilder_results/debuild/collectd-build
