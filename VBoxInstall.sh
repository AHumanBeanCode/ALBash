#! /usr/bin/bash

# Partition the disk
echo "Partitioning disk /dev/sda"

DISK="/dev/sda"
DISK_SIZE=$(lsblk -b -dn -o SIZE $DISK)          # size in bytes
DISK_SIZE_MIB=$((DISK_SIZE / 1024 / 1024))       # convert to MiB
ROOT_END=$((DISK_SIZE_MIB - 2048))          

parted -s /dev/sda mklabel msdos
parted /dev/sda --script mkpart primary ext4 0% $ROOT_END
parted /dev/sda --script mkpart primary ext4 $ROOT_END 100%

# Format the partitions
echo "Formatting partitions"
mkfs.ext4 /dev/sda1
mkswap /dev/sda2

# Mount the partitions
echo "Mounting partitions"
mount /dev/sda1 /mnt
swapon /dev/sda2

# Install base system
echo "Installing base system"
pacstrap -K /mnt base linux linux-firmware

# Generate fstab
echo "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

cat << 'EOF' > /mnt/chroot-setup.sh
#!/bin/bash

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
EOF

chmod +x /mnt/chroot-setup.sh

# Chroot into the new system
echo "Chrooting into the new system"
arch-chroot /mnt ./chroot-setup.sh

#Finish
echo "Please Reboot."
