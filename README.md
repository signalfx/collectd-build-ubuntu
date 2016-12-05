collectd-build-ubuntu
=====================

Build files for the debian packages of collectd and signalfx collectd plugin for Ubuntu 12.04, 14.04 and 15.04 distributions.

# Revisioning

## Collectd
1. Go to `/build-collectd/debian/changelog`
2. Add a statement to the changelog file that looks like this

**Template**
```
collectd (X.X.X-sfxX~trusty) trusty; urgency=medium

  * List of changes

 -- Signalfx Support <support+deb@signalfx.com>  Ddd, DD Mmm YYYY 20:05:00 +0000
 ```

| Description | Value In Template | Example Value |
| ----------- | ----------------- | ------------- |
| Substitute the version | `X.X.X-sfxX` | `5.6.2-sfx0` |
| Substitute the 3 character abreviated day | `Ddd` | `Wed` |
| Substitute the numerical date | `DD` | `03` |
| Substitute the 3 character abreviated month | `Mmm` | `Jul` |
| Substitute the numerical year | `YYYY` | `2016` |

**Example**
```
collectd (5.6.2-sfx0~trusty) trusty; urgency=medium

  * package release of 5.6.2

 -- Signalfx Support <support+deb@signalfx.com>  Wed, 07 Dec 2016 20:05:00 +0000
 ```

## Plugin
1. Go to `/build-collectd/debian/changelog`
2. Add a statement to the changelog file that looks like this

**Template**
```
signalfx-collectd-plugin (X.X.X~trusty) trusty; urgency=low
  * Description of changes

 -- SignalFx, Inc. <support+deb@signalfx.com>  Ddd, DD Mmm YYYY 10:50:00 +0000
 ```

**Description of Values To Change**
| Description | Value In Template | Example Value |
| ----------- | ----------------- | ------------- |
| Substitute the version | `X.X.X-sfxX` | `5.6.2-sfx0` |
| Substitute the 3 character abreviated day | `Ddd` | `Wed` |
| Substitute the numerical date | `DD` | `03` |
| Substitute the 3 character abreviated month | `Mmm` | `Jul` |
| Substitute the numerical year | `YYYY` | `2016` |

**Example**
```
signalfx-collectd-plugin (0.2.24~trusty) trusty; urgency=low
  * rev to 0.0.29
  * Added python dependency six

 -- SignalFx, Inc. <support+deb@signalfx.com>  Wed, 02 Nov 2016 10:50:00 +0000
 ```


# Building Locally (Bash)
The shell script `local_build.sh` is used to build the collectd and SignalFx 
collectd plugin debian packages.

In order to do this checkout the signalfx repository and the collectd repsoitories
to `local_dev_resources`.

```bash
Locally build collectd, (!) signalfx collectd plugin, or builder image
for ubuntu linux

USAGE: sh local_build.sh COMMAND [options]

Commands:

            collectd  - build the signalfx collectd ubuntu package
                        [options]
                            'wheezy'  - Wheezy debian build
                            'jessie'  - Jessie debian build
                            'precise' - Precise ubuntu build
                            'vivid'   - Vivid ubuntu build
                            'trusty'  - Trusty ubuntu build
                            'xenial'  - Xenial ubuntu build
                            No Option - Build for all platforms
            plugin    - (Not ready)   
                        build the signalfx collectd metadata plugin
                        ubuntu apk package
            container - build the builder image
                        quay.io/signalfuse/collectd-build-ubuntu
                        and store in local docker image reposit

Requirements:
            collectd  - the collectd repo should be checked out to 
                        /local_dev_resources
            plugin    - the signalfx-collectd-plugin repo should be checked 
                        out to /local_dev_resources
```
