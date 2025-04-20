#! /usr/bin/bash

echo "Sorting Pacman"
pacman-key --init
pacman-key --populate archlinux
sed -i 's/^#\[multilib\]/\[multilib\]/' /etc/pacman.conf
sed -i 's/^#Include = /Include = /' /etc/pacman.conf
pacman -Sy

echo "Generating Locales"
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

read -p "Enter Hostname: " HOSTNAME
echo "$HOSTNAME" > /etc/hostname

echo "Set root password"
passwd

echo "Creating Home User"
read -p "Enter Username: " USERNAME
useradd -m -G wheel $USERNAME
passwd $USERNAME
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo "Installing yay"
pacman -Sy --needed base-devel git
sudo -u $USERNAME bash <<EOF
cd /home/$USERNAME
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
EOF

echo "Installing Grub"
pacman -Sy --noconfirm grub
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

echo "Installing Network Manager"
pacman -S networkmanager
systemctl enable NetworkManager

/SoftwareIndex.sh

#Finish
echo "Please Reboot"
