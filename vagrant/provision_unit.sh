#!/bin/bash

# Copyright (C) 2017 Daniel Page <csdsp@bristol.ac.uk>
#
# Use of this source code is restricted per the CC BY-NC-ND license, a copy of 
# which can be found via http://creativecommons.org (and should be included as 
# LICENSE.txt within the associated archive or repository).

# software install: packaged software
sudo apt-get --quiet --assume-yes install gnuplot
sudo apt-get --quiet --assume-yes install libgmp-dev
sudo apt-get --quiet --assume-yes install libssl-dev
sudo apt-get --quiet --assume-yes install openssl
sudo apt-get --quiet --assume-yes install putty
sudo apt-get --quiet --assume-yes install python2.7
sudo apt-get --quiet --assume-yes install python-pip

sudo pip install capstone  --upgrade --upgrade-strategy=eager
sudo pip install intelhex  --upgrade --upgrade-strategy=eager
sudo pip install numpy     --upgrade --upgrade-strategy=eager
sudo pip install picoscope --upgrade --upgrade-strategy=eager
sudo pip install pycrypto  --upgrade --upgrade-strategy=eager
sudo pip install pyserial  --upgrade --upgrade-strategy=eager
sudo pip install scipy     --upgrade --upgrade-strategy=eager
sudo pip install unicorn   --upgrade --upgrade-strategy=eager

# software install: libpng12 (needed for PicoScope application)
wget --quiet --output-document="libpng12-0_1.2.54-1ubuntu1.1_amd64.deb" http://security.ubuntu.com/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1.1_amd64.deb
sudo dpkg --install libpng12-0_1.2.54-1ubuntu1.1_amd64.deb
rm --force libpng12-0_1.2.54-1ubuntu1.1_amd64.deb

# software install: PicoScope
sudo echo "deb https://labs.picotech.com/debian/ picoscope main" > /etc/apt/sources.list.d/picoscope.list
wget --quiet --output-document - https://labs.picotech.com/debian/dists/picoscope/Release.gpg.key | sudo apt-key add -
sudo apt-get --quiet --assume-yes update
sudo apt-get --quiet --assume-yes install picoscope

# software install: ARM GCC tool-chain
wget --quiet --output-document="gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2" https://developer.arm.com/-/media/Files/downloads/gnu-rm/7-2017q4/gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2
sudo tar --extract --transform 's|gcc-arm-none-eabi-7-2017-q4-major|gcc-arm-none-eabi/7-2017-q4-major|' --directory /opt --file gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2
rm --force gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2

# software install: lpc21isp
wget --quiet --output-document="lpc21isp_197.tar.gz" https://sourceforge.net/projects/lpc21isp/files/lpc21isp/1.97/lpc21isp_197.tar.gz
tar --extract --file lpc21isp_197.tar.gz
cd lpc21isp_197
make
sudo install -D --target-directory=/opt/lpc21isp/bin lpc21isp
cd ..
rm --force --recursive lpc21isp_197.tar.gz lpc21isp_197

# software install: libserialport
wget --quiet --output-document="libserialport-0.1.1.tar.gz" https://sigrok.org/download/source/libserialport/libserialport-0.1.1.tar.gz
tar --extract --file libserialport-0.1.1.tar.gz
cd libserialport-0.1.1
./configure --prefix=/opt/libserialport-0.1.1
make
sudo make install
cd ..
rm --force --recursive libserialport-0.1.1.tar.gz libserialport-0.1.1

# software install: SCALE repo. (e.g., for BSP)
git clone --branch ${UNIT_CODE}_${UNIT_YEAR} http://www.github.com/danpage/scale-hw.git /home/vagrant/${UNIT_CODE}/scale-hw

# system configuration: group membership
sudo usermod --append --groups pico    vagrant
sudo usermod --append --groups dialout vagrant
sudo usermod --append --groups plugdev vagrant

# system configuration: udev rules
sudo cat > /etc/udev/rules.d/99-scale.rules <<EOF
# SCALE board
SUBSYSTEM=="tty", ACTION=="add", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", GROUP:="vagrant", MODE:="0666", SYMLINK+="scale-board"
# SCALE scope (i.e., PicoScope)
SUBSYSTEM=="usb", ACTION=="add", ATTRS{idVendor}=="0ce9", ATTRS{idProduct}=="1016", GROUP:="vagrant", MODE:="0666", SYMLINK+="scale-scope"
EOF
sudo udevadm control --reload-rules
sudo udevadm trigger

# teaching material: download
for SHEET in 1-1 1-2 2 3 4 5 ; do
  wget --quiet --directory-prefix /home/vagrant/${UNIT_CODE} http://assets.phoo.org/${UNIT_PATH}/csdsp/sheet/lab-${SHEET}.pdf
  wget --quiet --directory-prefix /home/vagrant/${UNIT_CODE} http://assets.phoo.org/${UNIT_PATH}/csdsp/sheet/lab-${SHEET}.tar.gz
done

# teaching material: unarchive 
for SHEET in 1-1 1-2 2 3 4 5 ; do
  tar --extract --gunzip --directory /home/vagrant/${UNIT_CODE} --file /home/vagrant/${UNIT_CODE}/lab-${SHEET}.tar.gz
done

# teaching material: permissions
sudo chown --recursive vagrant:vagrant /home/vagrant/${UNIT_CODE}
