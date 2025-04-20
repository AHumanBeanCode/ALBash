!# /usr/bin/bash

# Partition the disk
echo "Partitioning disk /dev/sda"

DISK="/dev/sda"
DISK_SIZE=$(parted $DISK --script unit MiB print | awk '/^Disk/ {gsub("MiB",""); print int($3)}')
ROOT_END=$(($DISK_SIZE - 2048))

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

# Chroot into the new system
echo "Chrooting into the new system"
arch-chroot /mnt
