#!/bin/bash

# ========================================================================================
# NOTE

# This script promotes the packages from TEST_PPA to BETA_PPA. It does this by downloading
# the source code tar ball of the version you have provided as argument, rebuilding the source package,
# signing the package with your secret key and then uploading the package to BETA_PPA.

# USAGE: ./promote_test_to_beta.sh VERSION KEYID

# VERSION: The version number of the package you want to promote from test to beta ppa
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
  printf "Usage: ./promote_test_to_beta.sh VERSION KEYID\n" 1>&2
  exit 2;
fi

. environ.sh

check_for_command debsign

rm -rf /tmp/test_upgrade
mkdir -p /tmp/test_upgrade
cd /tmp/test_upgrade
sudo apt-get -y install wget dpatch autoconf automake flex bison libtool devscripts
sudo apt-get -y install debhelper po-debconf pkg-config iptables-dev javahelper

template="http://ppa.launchpad.net/${TEST_PPA}/ubuntu/pool/main/s/signalfx-collectd-plugin/signalfx-collectd-plugin_version~distribution.tar.gz"

VERSION=$1
KEYID=$2

for DISTRIBUTION in ${OS_ARRAY[@]}
do
        mkdir $DISTRIBUTION
        cd $DISTRIBUTION
        URL=${template//version/$VERSION}
        URL=${URL//distribution/$DISTRIBUTION}
        wget $URL
        tar xvf *.tar.gz
        cd signalfx-collectd-plugin
        debuild -us -uc -S
        cd ..
        debsign -k$KEYID *.changes
        dput -f ppa:$BETA_PPA *.changes
done
rm -rf /tmp/test_upgrade
