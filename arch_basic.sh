#/bin/bash

pacstrap /mnt base xorg-server xf86-video-radeon xf86-video-nouveau xorg-xinit firefox chromium xfce4 gvfs git vim thunderbird hexchat base-devel pulseaudio pulseaudio-alsa pulseaudio-bluetooth pavucontrol mesa-demos accountsservice lightdm lightdm-gtk-greeter xfce4-pulseaudio-plugin dmidecode light-locker openssh rsync zsh curl sudo
genfstab -U /mnt >> /mnt/etc/fstab
cp /etc/locale.conf /mnt/etc/locale.conf
cp /etc/vconsole.conf /mnt/etc/vconsole.conf

cat << EOF > /mnt/etc/X11/xorg.conf.d/10-evdev.conf
Section "InputClass"
        Identifier "evdev keyboard catchall"
        MatchIsKeyboard "on"
        MatchDevicePath "/dev/input/event*"
        Driver "evdev"
    	Option	"XkbLayout"	"fr"
	    Option	"XkbVariant"	"oss"
EndSection
EOF

#arch-chroot /mnt
# Don't forget to install a bootloader ! grub for bios or refind-efi for uefi
