#!/usr/bin/env bash
# This is a small script pased on https://www.funtoo.org/Undead_USB_Install
# I am using it to quickly build a Funtoo VM.


echo 'KERNEL=="sda*", SYMLINK+="funtoo%n"' > /etc/udev/rules.d/01-funtoo.rules
sleep 3
udevadm control --reload-rules && udevadm trigger
sleep 3


parted  /dev/sda --script \
    mklabel gpt \
    mkpart primary 1MiB 3MiB \
    mkpart primary 3MiB 515MiB \
    mkpart primary ext4 515MiB 100% \
    name 1 "BIOS Boot" \
    name 2 "BOOT" \
    name 3 "FUNTOO" \
    set 1 legacy_boot on\
    set 2 esp on \
    set 3 root on

sleep 3

sync

mkfs.vfat -F 32 /dev/funtoo2 
fatlabel /dev/funtoo2 "BOOT"

mkfs.ext4 /dev/funtoo3
e2label /dev/funtoo3 "FUNTOO"

mkdir /mnt/funtoo/
mount /dev/funtoo3 /mnt/funtoo
mkdir /mnt/funtoo/boot
mount /dev/funtoo2 /mnt/funtoo/boot

cd /mnt/funtoo
#wget -c https://build.funtoo.org/1.4-release-std/x86-64bit/generic_64/gnome-latest.tar.xz
#wget -c https://build.funtoo.org/1.4-release-std/x86-64bit/amd64-zen2/2021-07-23/gnome-stage3-amd64-zen2-1.4-release-std-2021-07-23.tar.xz
wget -c https://build.funtoo.org/1.4-release-std/x86-64bit/amd64-zen2/2021-07-23/stage3-amd64-zen2-1.4-release-std-2021-07-23.tar.xz
tar --numeric-owner --xattrs --xattrs-include='*' -xpf *.tar.xz && rm -f *.tar.xz /mnt/funtoo/mnt && mkdir /mnt/funtoo/mnt/funtoo

cd /mnt/funtoo 

mount -t proc none proc
mount --rbind /sys sys
mount --rbind /dev dev

#wget http://192.168.0.157:8000/run-in-chroot-desktop.sh
wget http://192.168.0.157:8000/run-in-chroot-server.sh


chmod +x run-in-chroot*.sh

env -i HOME=/root TERM=$TERM $(which chroot) /mnt/funtoo bash -l