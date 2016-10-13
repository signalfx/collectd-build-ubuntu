FROM ubuntu:14.04

RUN apt-get update && \
    apt-get -y install dpatch build-essential devscripts fakeroot quilt dh-make automake libdistro-info-perl autoconf flex bison libtool pkg-config pbuilder debootstrap wget git-core debhelper po-debconf autotools-dev libltdl-dev libgcrypt11-dev libglib2.0-dev gcc python-dev curl python-pip python-virtualenv debian-archive-keyring curl && \
    curl http://repo.varnish-cache.org/debian/GPG-key.txt | apt-key add - && \
    echo "deb http://repo.varnish-cache.org/ubuntu/ trusty varnish-4.1" >> /etc/apt/sources.list && \
    echo "deb-src http://repo.varnish-cache.org/ubuntu/ trusty varnish-4.1" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get clean && \
    apt-get update
