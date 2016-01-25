#!/bin/bash

# ========================================================================================
# NOTE

# This script promotes the packages from TEST_PPA to BETA_PPA. 
# For Ubuntu packages in launchpad, It does this by downloading
# the source code tar ball of the version you have provided as argument, rebuilding the source package,
# signing the package with your secret key and then uploading the package to BETA_PPA.
# For Debian packages in our Amazon S3 bucket, it will simply copy all files from test folder in to beta
# folder.

# USAGE: ./promote_test_to_beta.sh KEYID UBUNTU_PACKAGE_VERSION

# UBUNTU_PACKAGE_VERSION: The version number of the package you want to promote from test to beta ppa
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

check_for_command(){
 set +e
 which $1 > /dev/null
 if [ $? -ne 0 ]; then
   printf "Unable to find %s. Please install or check your PATH\n" "$1"
   exit 1;
 fi
 set -e
}

if [ $# -eq 0 ]; then
  printf "Usage: ./promote_test_to_beta.sh KEYID UBUNTU_PACKAGE_VERSION\n" 1>&2
  printf "UBUNTU_PACKAGE_VERSION is the latest version in your Launchpad test ppa that you want to upgrade to beta"
  exit 2;
fi

check_for_command debsign

TEST_PPA="signalfx/collectd-test"
BETA_PPA="signalfx/collectd-beta"
OS_ARRAY=("precise" "trusty" "vivid")
DEBIAN_OS_ARRAY=("wheezy" "jessie")

rm -rf /tmp/test_upgrade
mkdir -p /tmp/test_upgrade
cd /tmp/test_upgrade
sudo apt-get -y install wget dpatch autoconf automake flex bison libtool devscripts
sudo apt-get -y install debhelper po-debconf pkg-config iptables-dev javahelper

template="http://ppa.launchpad.net/${TEST_PPA}/ubuntu/pool/main/c/collectd/collectd_version~distribution.tar.gz"

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
        cd collectd*
        debuild -us -uc -S
        cd ..
        debsign -k$KEYID *.changes
        dput -f ppa:$BETA_PPA *.changes
done

for DISTRIBUTION in ${DEBIAN_OS_ARRAY[@]}
do
  S3_BUCKET="s3://public-downloads--signalfuse-com/debs/collectd"
  aws s3 rm --recursive $S3_BUCKET/$DISTRIBUTION/beta/
  aws s3 cp --recursive $S3_BUCKET/$DISTRIBUTION/test/ $S3_BUCKET/$DISTRIBUTION/beta/
done

rm -rf /tmp/test_upgrade
