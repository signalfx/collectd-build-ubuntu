#!/bin/sh

check_for_command(){
 set +e
 which $1 > /dev/null
 if [ $? -ne 0 ]; then
   printf "Unable to find %s. Please install or check your PATH\n" "$1"
   exit 1;
 fi
 set -e
}

BETA_PPA="signalfx/collectd-plugin-beta"
RELEASE_PPA="signalfx/collectd-plugin-release"
OS_ARRAY=("precise" "trusty" "xenial" "bionic")
DEBIAN_OS_ARRAY=("wheezy" "jessie" "stretch")

