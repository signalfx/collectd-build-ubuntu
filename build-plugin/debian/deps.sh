rm -f plugins/requirements.txt
tar -xvzf psutil-3.2.2.tar.gz
cd psutil-3.2.2
python setup.py build
mv build/lib*/psutil ../plugins/.
