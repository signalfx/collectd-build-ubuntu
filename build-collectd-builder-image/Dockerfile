FROM ubuntu:16.04

RUN apt-get update

RUN apt-get -y install dpatch build-essential devscripts fakeroot quilt dh-make automake libdistro-info-perl autoconf flex bison libtool pkg-config pbuilder debootstrap wget git-core debhelper po-debconf autotools-dev libltdl-dev libgcrypt11-dev libglib2.0-dev gcc python-dev curl python-pip python-virtualenv debian-archive-keyring curl gnupg2 apt-transport-https

RUN curl -L https://packagecloud.io/varnishcache/varnish41/gpgkey | apt-key add - &&\
    echo "deb https://packagecloud.io/varnishcache/varnish41/ubuntu/ xenial main" >> /etc/apt/sources.list && \
    echo "deb-src https://packagecloud.io/varnishcache/varnish41/ubuntu/ xenial main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get clean && \
    apt-get update
