#!/bin/bash

# ========================================================================================
# NOTE

# This script promotes the packages from BETA_PPA to RELEASE_PPA. It does this by downloading
# the source code tar ball of the version you have provided as argument, rebuilding the source package,
# signing the package with your secret key and then uploading the package to RELEASE_PPA.

# USAGE: ./promote_beta_to_release.sh VERSION KEYID

# VERSION: The version number of the package you want to promote from beta to release ppa
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
  printf "Usage: ./promote_beta_to_release.sh VERSION KEYID\n" 1>&2
  exit 2;
fi

check_for_command debsign

BETA_PPA="signalfx/collectd-beta"
RELEASE_PPA="signalfx/collectd-release"
OS_ARRAY=("precise" "trusty" "vivid")
DEBIAN_OS_ARRAY=("wheezy" "jessie")

rm -rf /tmp/beta_upgrade
mkdir -p /tmp/beta_upgrade
cd /tmp/beta_upgrade
sudo apt-get -y install wget dpatch autoconf automake flex bison libtool devscripts
sudo apt-get -y install debhelper po-debconf pkg-config iptables-dev javahelper

template="http://ppa.launchpad.net/${BETA_PPA}/ubuntu/pool/main/c/collectd/collectd_version~distribution.tar.gz"

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
        cd collectd*
        debuild -us -uc -S
        cd ..
        debsign -k$KEYID *.changes
        dput -f ppa:$RELEASE_PPA *.changes
done

for DISTRIBUTION in ${DEBIAN_OS_ARRAY[@]}
do
  S3_BUCKET="s3://public-downloads--signalfuse-com/debs/collectd"
  mkdir $DISTRIBUTION
  cd $DISTRIBUTION
  aws s3 cp --recursive $S3_BUCKET/$DISTRIBUTION/beta/ .
  DIR="/tmp/test_upgrade/$DISTRIBUTION/pdebuild/"
  if [ "$(ls -A $DIR)" ]; then
    cd $DIR/..
    rm -rf debuild
    mv pdebuild debs
    dpkg-scanpackages debs /dev/null > Packages
    gzip -k Packages
    apt-ftparchive release . > Release
    gpg --default-key $KEYID -abs -o Release.gpg Release
    aws s3 rm --recursive $S3_BUCKET/$DISTRIBUTION/release/
    aws s3 cp --recursive . $S3_BUCKET/$DISTRIBUTION/release
  fi
done

rm -rf /tmp/beta_upgrade
