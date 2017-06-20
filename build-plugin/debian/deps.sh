set -ex
tar -xvzf psutil-3.3.0.tar.gz
(cd psutil-3.3.0 && python setup.py build && mv build/lib*/psutil ../plugins/. )

tar -xvzf simplejson-3.8.1.tar.gz
(cd simplejson-3.8.1 && python setup.py build && mv build/lib*/simplejson ../plugins/. )

find 
(cd venv/lib/python*/*packages && mv pyformance requests google signalfx six* ../../../../plugins/.)
