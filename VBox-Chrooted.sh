#! /usr/bin/bash

echo "Sorting Pacman"
pacman-key --init
pacman-key --populate archlinux
pacman -Sy

echo "Generating Locales"
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

read -p "Enter Hostname: " HOSTNAME
echo "$HOSTNAME" > /etc/hostname

echo "Set root password"
passwd

echo "Installing Grub"
pacman -Sy --noconfirm grub
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

#Finish
echo "Please Reboot"
