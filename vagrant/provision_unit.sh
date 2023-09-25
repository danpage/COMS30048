#!/bin/bash

# Copyright (C) 2017 Daniel Page <csdsp@bristol.ac.uk>
#
# Use of this source code is restricted per the CC BY-NC-ND license, a copy of 
# which can be found via http://creativecommons.org (and should be included as 
# LICENSE.txt within the associated archive or repository).

# software install: packaged software
sudo dnf --assumeyes install gnuplot
sudo dnf --assumeyes install gmp
sudo dnf --assumeyes install gmp-devel
sudo dnf --assumeyes install libtool
sudo dnf --assumeyes install openssl
sudo dnf --assumeyes install openssl-devel
sudo dnf --assumeyes install putty
sudo dnf --assumeyes install usbutils

# software install: mambaforge + sage (mamba activate sage)
wget --quiet --output-document="Mambaforge-23.1.0-4-Linux-x86_64.sh" https://github.com/conda-forge/miniforge/releases/download/23.1.0-4/Mambaforge-23.1.0-4-Linux-x86_64.sh
bash ./Mambaforge-23.1.0-4-Linux-x86_64.sh -b -p ./mambaforge
./mambaforge/bin/mamba init
./mambaforge/bin/mamba create --quiet --yes --name sage sage
rm --force ./Mambaforge-23.1.0-4-Linux-x86_64.sh

# software install: PicoScope application, Software Development Kit (SDK), etc.
sudo yum --assumeyes localinstall https://labs.picotech.com/rpm/x86_64/picomono-4.6.2.16-1r02.x86_64.rpm
sudo yum --assumeyes localinstall https://labs.picotech.com/rpm/x86_64/libpicoipp-1.3.0-4r21.x86_64.rpm
sudo yum --assumeyes localinstall https://labs.picotech.com/rpm/x86_64/libusbdrdaq-2.0.0-1r570.x86_64.rpm
sudo yum --assumeyes localinstall https://labs.picotech.com/rpm/x86_64/libpl1000-2.0.0-1r570.x86_64.rpm
sudo yum --assumeyes localinstall https://labs.picotech.com/rpm/x86_64/libps2000-3.0.0-3r570.x86_64.rpm
sudo yum --assumeyes localinstall https://labs.picotech.com/rpm/x86_64/libps2000a-2.1.0-5r570.x86_64.rpm
sudo yum --assumeyes localinstall https://labs.picotech.com/rpm/x86_64/libps3000-4.0.0-3r570.x86_64.rpm
sudo yum --assumeyes localinstall https://labs.picotech.com/rpm/x86_64/libps3000a-2.1.0-6r570.x86_64.rpm
sudo yum --assumeyes localinstall https://labs.picotech.com/rpm/x86_64/libps4000-2.1.0-2r570.x86_64.rpm
sudo yum --assumeyes localinstall https://labs.picotech.com/rpm/x86_64/libps4000a-2.1.0-2r570.x86_64.rpm
sudo yum --assumeyes localinstall https://labs.picotech.com/rpm/x86_64/libps5000-2.1.0-3r570.x86_64.rpm
sudo yum --assumeyes localinstall https://labs.picotech.com/rpm/x86_64/libps5000a-2.1.0-5r570.x86_64.rpm
sudo yum --assumeyes localinstall https://labs.picotech.com/rpm/x86_64/libps6000-2.1.0-6r580.x86_64.rpm
sudo yum --assumeyes localinstall https://labs.picotech.com/rpm/noarch/picoscope-6.13.7-4r707.noarch.rpm

# software install: ARM-based GCC tool-chain
wget --quiet --output-document="arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi.tar.xz" https://developer.arm.com/-/media/Files/downloads/gnu/12.3.rel1/binrel/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi.tar.xz
sudo tar --extract --transform "s|arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi|arm-gnu-toolchain/12.3.rel1|" --directory /opt --file ./arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi.tar.xz
rm --force ./arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi.tar.xz

# software install: lpc21isp programming tool
wget --quiet --output-document="lpc21isp_197.tar.gz" https://sourceforge.net/projects/lpc21isp/files/lpc21isp/1.97/lpc21isp_197.tar.gz
tar --extract --file ./lpc21isp_197.tar.gz
cd ./lpc21isp_197
make
sudo mkdir --parents /opt/lpc21isp/1.97 && sudo install --target-directory="/opt/lpc21isp/1.97" lpc21isp
cd ..
rm --force --recursive ./lpc21isp_197.tar.gz ./lpc21isp_197

# software install: libserialport
git clone git://sigrok.org/libserialport ./libserialport-0.1.1
cd ./libserialport-0.1.1
libtoolize && ./autogen.sh && ./configure --prefix="/opt/libserialport/0.1.1"
make
sudo make install
cd ..
rm --force --recursive ./libserialport-0.1.1

# system configuration: udev rules
sudo tee -a /etc/udev/rules.d/99-scale.rules > /dev/null <<'EOF'
# SCALE board (i.e., FTDI-based UART)
ACTION!="remove", SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", GROUP:="wheel", MODE:="0666", SYMLINK+="scale-board"
# SCALE scope (i.e., PicoScope 2206B)
ACTION!="remove", SUBSYSTEM=="usb", ATTRS{idVendor}=="0ce9", ATTRS{idProduct}=="1016", GROUP:="wheel", MODE:="0666", SYMLINK+="scale-scope"
EOF
sudo udevadm control --reload-rules && sudo udevadm trigger
