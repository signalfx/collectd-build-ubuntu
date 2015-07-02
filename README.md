collectd-build-ubuntu
=====================

Builds the collectd-5.5.0 packages for Ubuntu 12.04, 14.04, 14.10 and 15.04 distributions.

Use Docker to build the packages in a clean manner. The Dockerfile to setup the environment is 

```shell
FROM ubuntu:14.10

RUN yes | sudo apt-get install git
RUN yes | sudo apt-get update
RUN yes | sudo apt-get install dpatch
RUN yes | sudo apt-get install build-essential devscripts fakeroot quilt dh-make automake libdistro-info-perl less nano autoconf flex bison libtool pkg-config
RUN yes | sudo apt-get install pbuilder debootstrap
RUN yes | sudo apt-get install wget git-core debhelper po-debconf autotools-dev libltdl-dev pkg-config iptables-dev javahelper libgcrypt11-dev libglib2.0-dev
```

Build the source package for upload to the launchpad using debuild command. Before uploading, test locally whether the binary packages are building correctly from the created source package using pdebuild command.

The command sequence to run the entire process inside a docker container is:

```
sudo docker build -t ubuntu_setup/14.10 .
sudo docker run --privileged -v /opt/:/opt/mount/ ubuntu_setup/14.10 /bin/bash -c "
DISTRIBUTION=precise &&

git clone https://gist.github.com/udaysagar2177/51164d3070660d663666 pbuilderrc &&
cat pbuilderrc/gistfile1.txt > ~/.pbuilderrc &&
mkdir collectd && cd collectd &&
git clone --branch collectd-5.5.0 https://github.com/signalfx/collectd.git collectd-5.5.0 &&
tar -cvzf collectd-5.5.0.tar.gz collectd-5.5.0 &&
git clone https://github.com/udaysagar2177/collectd-build-ubuntu collectd_build &&
rm -rf collectd-5.5.0/debian/ &&
cp -rf collectd_build/debian/ collectd-5.5.0/ &&
cd collectd-5.5.0 &&

sed -i 's/trusty/'\${DISTRIBUTION}'/g' debian/changelog &&

if [ \"\$DISTRIBUTION\" = \"precise\" ]; then
patch -p0 < debian/patches/precise_control.patch
patch -p0 < debian/patches/precise_rules.patch
fi &&

./build.sh &&
DIST=\${DISTRIBUTION} ARCH=i386 yes | debuild -us -uc -S &&
rm -rf /opt/mount/pbuilder_results/\${DISTRIBUTION}/ &&
mkdir -p /opt/mount/pbuilder_results/\${DISTRIBUTION}/debuild &&
cp -rf ../* /opt/mount/pbuilder_results/\${DISTRIBUTION}/debuild/ &&
sudo DIST=\${DISTRIBUTION} ARCH=i386 pbuilder create &&
DIST=\${DISTRIBUTION} ARCH=i386 pdebuild ../collectd_5.5.0-sfx1~\${DISTRIBUTION}.dsc &&
mkdir -p /opt/mount/pbuilder_results/\${DISTRIBUTION}/pdebuild/ &&
cp /var/cache/pbuilder/\${DISTRIBUTION}-i386/result/* /opt/mount/pbuilder_results/\${DISTRIBUTION}/pdebuild/"
```

#####NOTE
  1. After execution, all source and binary packages are copied back to the docker host system and stored inside /opt/pbuilder_results/ directory.
  2. The build is written for the Ubuntu 14.04 distribution. To build the packages for other distributions, change the environment variable DISTRIBUTION in the above script.
  3. For Ubuntu 12.04 precise distribution, two patches will be applied which removes the unsupported libraries under build-depends of control file and disables the same plugins inside rules file.
  4. Before uploading the source package to the launchpad, sign the source package using debsign command.
