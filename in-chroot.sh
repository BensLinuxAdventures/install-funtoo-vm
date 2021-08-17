#!/usr/bin/env bash
# This is a small script pased on https://www.funtoo.org/Undead_USB_Install
# I am using it to quickly build a Funtoo VM.

#echo 'hostname="FunDevelGen"' > /etc/conf.d/hostname
echo 'hostname="FunDevelZen"' > /etc/conf.d/hostname

echo "nameserver 1.1.1.1" > /etc/resolv.conf
ln -sf /usr/share/zoneinfo/Europe/Dublin /etc/localtime



cat > /etc/fstab << "EOF"
LABEL=BOOT /boot vfat noauto,noatime 1 2
LABEL=FUNTOO / ext4 noatime 0 1
tmpfs /var/tmp/portage tmpfs uid=portage,gid=portage,mode=775,noatime 0 0
EOF

mkdir /var/tmp/portage
chown portage:portage /var/tmp/portage
mount /var/tmp/portage

cat > /etc/portage/package.use << "EOF"
sys-kernel/linux-firmware initramfs
app-emulation/qemu static-user qemu_user_targets_aarch64 qemu_user_targets_riscv64 qemu_user_targets_arm
dev-libs/glib static-libs
dev-libs/libpcre static-libs
sys-apps/attr static-libs
EOF

ego sync
emerge sys-boot/shim grub haveged linux-firmware fchroot eix firefox-bin media-fonts/noto fortune-mod cowsay vim syslog-ng logrotate cronie sudo


rc-update del swap boot
rc-update add haveged
rc-update add busybox-ntpd
rc-update add gpm
rc-update add syslog-ng 
rc-update add cronie


cat > /etc/boot.conf << "EOF"
boot {
generate grub
	default "Funtoo Linux"
	timeout 0
}
"Funtoo Linux" {
kernel kernel[-v]
initrd initramfs[-v]
params += real_root=auto rootfstype=auto scandelay=10
	params += quiet gfxpayload=auto loglevel=1 splash=silent
}
EOF

mount -o remount,rw /sys/firmware/efi/efivars
grub-install --target=i386-pc /dev/funtoo 
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id="BOOT" --recheck  --no-nvram /dev/funtoo
cp /usr/share/shim/* /boot/EFI/BOOT/
ego boot update

epro flavor desktop

epro mix-ins vmware-guest
epro mix-ins -gfxcard-radeon
epro mix-ins -gfxcard-amdgpu
epro mix-ins -gfxcard-nvidia
epro mix-ins -gfxcard-intel

emerge xorg-x11 pulseaudio networkmanager gnome open-vm-tools htop

rc-update add xdm
rc-update add NetworkManager
rc-update add vmware-tools
rc-update add sshd

emerge -avuND @world 
emerge -av --depclean
ego boot update

echo -e "VMware123\nVMware123" | passwd ben
echo -e "VMware123\nVMware123" | passwd root

usermod -G wheel,audio,plugdev,portage ben


sync