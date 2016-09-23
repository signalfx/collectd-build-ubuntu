#!/bin/bash

# ========================================================================================
# NOTE

# This script promotes the packages from BETA_PPA to RELEASE_PPA. It does this by downloading
# the source code tar ball of the version you have provided as argument, rebuilding the source package,
# signing the package with your secret key and then uploading the package to RELEASE_PPA.

# USAGE: ./promote_beta_to_release.sh KEYID UBUNTU_PACKAGE_VERSION

# UBUNTU_PACKAGE_VERSION: The version number of the package you want to promote from beta to release ppa
# example: 5.5.0-sfx1
# KEYID: Id of your secret key

# To get the KEYID,
# 1. Import the secret key associated with your launchpad account into this computer
# using the below command
# gpg --allow-secret-key-import --import path/secret.key
# 2. Run gpg --fingerprint

# /home/vagrant/.gnupg/pubring.gpg
# --------------------------------
# pub   2048R/['KEYID'] 2015-07-10
#      Key fingerprint = 5212 C1F1 1482 93D7 42F9  A120 EPDD 4893 963B 523C
# uid                  signalfx <uday@signalfx.com>
# sub   2048R/6H2HDFGC 2015-07-10

# ========================================================================================

set -e

if [ $# -eq 0 ]; then
  printf "Usage: ./promote_beta_to_release.sh KEYID UBUNTU_PACKAGE_VERSION\n" 1>&2
  exit 2;
fi

. environ.sh

check_for_command debsign

rm -rf /tmp/beta_upgrade
mkdir -p /tmp/beta_upgrade
cd /tmp/beta_upgrade
sudo apt-get -y install wget dpatch autoconf automake flex bison libtool devscripts
sudo apt-get -y install debhelper po-debconf pkg-config iptables-dev javahelper

template="http://ppa.launchpad.net/${BETA_PPA}/ubuntu/pool/main/s/signalfx-collectd-plugin/signalfx-collectd-plugin_version~distribution.tar.gz"

KEYID=$1
UBUNTU_PACKAGE_VERSION=$2

for DISTRIBUTION in ${OS_ARRAY[@]}
do
        mkdir $DISTRIBUTION
        cd $DISTRIBUTION
        URL=${template//version/$UBUNTU_PACKAGE_VERSION}
        URL=${URL//distribution/$DISTRIBUTION}
        wget $URL
        tar xvf *.tar.gz
        cd signalfx-collectd-plugin
        debuild -us -uc -S
        cd ..
        debsign -k$KEYID *.changes
        dput -f ppa:$RELEASE_PPA *.changes
done

for DISTRIBUTION in ${DEBIAN_OS_ARRAY[@]}
do
  S3_BUCKET="s3://public-downloads--signalfuse-com/debs/signalfx-collectd-plugin"
  aws s3 rm --recursive $S3_BUCKET/$DISTRIBUTION/release/
  aws s3 cp --recursive $S3_BUCKET/$DISTRIBUTION/beta/ $S3_BUCKET/$DISTRIBUTION/release/ --cache-control="max-age=0, no-cache"
done

rm -rf /tmp/beta_upgrade
