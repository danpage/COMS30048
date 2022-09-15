#!/bin/bash

# Copyright (C) 2017 Daniel Page <csdsp@bristol.ac.uk>
#
# Use of this source code is restricted per the CC BY-NC-ND license, a copy of 
# which can be found via http://creativecommons.org (and should be included as 
# LICENSE.txt within the associated archive or repository).

# software install: packaged software
sudo apt --quiet --assume-yes install autoconf
sudo apt --quiet --assume-yes install gnuplot
sudo apt --quiet --assume-yes install libgmp-dev
sudo apt --quiet --assume-yes install libssl-dev
sudo apt --quiet --assume-yes install libtool
sudo apt --quiet --assume-yes install openssl
sudo apt --quiet --assume-yes install putty
sudo apt --quiet --assume-yes install python3
sudo apt --quiet --assume-yes install python3-pip
sudo apt --quiet --assume-yes install python3-pycryptodome
sudo apt --quiet --assume-yes install python3-venv
sudo apt --quiet --assume-yes install python3-wheel
sudo apt --quiet --assume-yes install sagemath

# software install: PicoScope application, Software Development Kit (SDK), etc.
wget --quiet --output-document - https://labs.picotech.com/Release.gpg.key | sudo apt-key add -
sudo echo "deb https://labs.picotech.com/rc/picoscope7/debian/ picoscope main" > /etc/apt/sources.list.d/picoscope7.list
sudo apt --quiet --assume-yes update
sudo apt --quiet --assume-yes install picoscope

# software install: ARM-based GCC tool-chain
wget --quiet --output-document="gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2" https://developer.arm.com/-/media/Files/downloads/gnu-rm/7-2017q4/gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2
sudo tar --extract --transform "s|gcc-arm-none-eabi-7-2017-q4-major|gcc-arm-none-eabi/7-2017-q4-major|" --directory /opt --file gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2
rm --force gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2

# software install: lpc21isp programming tool
wget --quiet --output-document="lpc21isp_197.tar.gz" https://sourceforge.net/projects/lpc21isp/files/lpc21isp/1.97/lpc21isp_197.tar.gz
tar --extract --file lpc21isp_197.tar.gz
cd ./lpc21isp_197
make
sudo install -D --target-directory="/opt/lpc21isp/bin" lpc21isp
cd ..
rm --force --recursive lpc21isp_197.tar.gz lpc21isp_197

# software install: libserialport
git clone git://sigrok.org/libserialport ./libserialport-0.1.1
cd ./libserialport-0.1.1
./autogen.sh
./configure --prefix="/opt/libserialport/0.1.1"
make
sudo make install
cd ..
rm --force --recursive libserialport-0.1.1

# software install: SCALE repo. (e.g., for BSP)
git clone --branch ${UNIT_CODE}_${UNIT_YEAR} http://www.github.com/danpage/scale-hw.git /home/vagrant/${UNIT_CODE}/scale-hw

# system configuration: group membership
sudo usermod --append --groups dialout vagrant
sudo usermod --append --groups plugdev vagrant

# system configuration: udev rules
sudo cat > /etc/udev/rules.d/99-scale.rules <<EOF
# SCALE board (i.e., FTDI-based UART)
ACTION!="remove", SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", GROUP:="plugdev", MODE:="0666", SYMLINK+="scale-board"
# SCALE scope (i.e., PicoScope 2206B)
ACTION!="remove", SUBSYSTEM=="usb", ATTRS{idVendor}=="0ce9", ATTRS{idProduct}=="1016", GROUP:="plugdev", MODE:="0666", SYMLINK+="scale-scope"
EOF
sudo udevadm control --reload-rules && sudo udevadm trigger

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
