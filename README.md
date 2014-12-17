collectd-build-ubuntu
=====================

To build run the following steps

```shell
sudo apt-get update
sudo apt-get install git-core build-essential debhelper po-debconf dpatch bison flex autotools-dev libltdl-dev pkg-config iptables-dev javahelper libcurl4-gnutls-dev libdbi-dev libesmtp-dev libganglia1-dev  libgcrypt11-dev libglib2.0-dev liblvm2-dev libmemcached-dev libmodbus-dev libmnl-dev libmysqlclient-dev libnotify-dev libopenipmi-dev liboping-dev libow-dev  libpcap-dev libperl-dev libpq-dev librabbitmq-dev librrd-dev libsensors4-dev libsnmp-dev libvirt-dev libxml2-dev libyajl-dev default-jdk protobuf-c-compiler python-dev libprotobuf-c0-dev libtokyocabinet-dev libtokyotyrant-dev libupsclient1-dev
git clone https://github.com/signalfx/collectd-build-ubuntu collectd
wget https://collectd.org/files/collectd-5.4.1.tar.gz
tar xzf collectd-5.4.1.tar.gz -C collectd --strip-components=1
cd collectd
dpkg-buildpackage -us -uc
```
