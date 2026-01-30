#!/bin/bash

mkdir .temp
cd .temp
git clone https://codeberg.org/Limine/Limine.git --branch=v10.x-binary --depth=1
cd ./Limine/
make

mkdir -p ../../iso_root/EFI/BOOT/

mv ./BOOTX64.EFI ../../iso_root/EFI/BOOT/
mv ./limine ../../
mv ./limine-bios.sys ../../iso_root/
mv ./limine-bios-cd.bin ../../iso_root/
mv ./limine-uefi-cd.bin ../../iso_root

cd ../../
rm -rf .temp/
