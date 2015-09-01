#!/bin/bash


# ========================================================================================
# NOTE

# This script downloads from aws s3 bucket, the packages you have uploaded from the jenkins job
# and sign them. It uploads the source package to TEST_PPA on launchpad from where you can 
# install and check if everything is working fine and as expected.

# USAGE: ./sign_and_upload.sh KEYID

# For this script,
# you are expected to have the key imported on to your system and supply the key-ID.
# 
# To get the KEY-ID,
# 1. Import the secret key associated with your launchpad account into this computer
# using the below command
# gpg --allow-secret-key-import --import path/secret.key
# 2. Run gpg --fingerprint

# /home/vagrant/.gnupg/pubring.gpg
# --------------------------------
# pub   2048R/['KEY-ID'] 2015-07-10
#      Key fingerprint = 5212 C1F1 1482 93D7 42F9  A120 EPDD 4893 963B 523C
# uid                  signalfx <uday@signalfx.com>
# sub   2048R/6H2HDFGC 2015-07-10
# 
# IMPORTANT
# Please build your package locally using pdebuild and 
# proceed further only if there are no errors.
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
  printf "Usage: ./sign_and_upload.sh KEYID\n" 1>&2
  exit 2;
fi


check_for_command aws
check_for_command debsign

KEYID=$1
TEST_PPA="ppa:signalfx/collectd-test"
OS_ARRAY=("precise" "trusty" "vivid")

rm -rf /tmp/collectd-ppa-uploads/
mkdir /tmp/collectd-ppa-uploads/
cd /tmp/collectd-ppa-uploads/
echo  "Downloading files from S3 Bucket, It may take some time..."
aws s3 cp --recursive s3://collectd-builds-ubuntu/ .

for DISTRIBUTION in ${OS_ARRAY[@]}
do
        if [ -f /tmp/collectd-ppa-uploads/$DISTRIBUTION/debuild/*.dsc ]
        then
                cd /tmp/collectd-ppa-uploads/$DISTRIBUTION/debuild/
		debsign -k$KEYID *.changes
                dput -f $TEST_PPA *.changes
        fi
done
rm -rf /tmp/collectd-ppa-uploads/
