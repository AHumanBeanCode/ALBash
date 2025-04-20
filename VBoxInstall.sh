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

cp /ALBash/VBox-Chrooted.sh /mnt/VBox-Chrooted.sh

#Finish
echo "Please Reboot"
EOF

chmod +x /mnt/chroot-setup.sh

# Chroot into the new system
echo "Chrooting into the new system. Please run ./chroot-setup.sh"
arch-chroot /mnt
