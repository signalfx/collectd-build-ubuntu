set -ex
tar -xvzf psutil-3.2.2.tar.gz
(cd psutil-3.2.2 && python setup.py build && mv build/lib*/psutil ../plugins/. )

tar -xvzf simplejson-3.8.1.tar.gz
(cd simplejson-3.8.1 && python setup.py build && mv build/lib*/simplejson ../plugins/. )

find venv
(cd venv/lib/python*/*packages && mv pyformance requests google signalfx ../../../../plugins/. )
