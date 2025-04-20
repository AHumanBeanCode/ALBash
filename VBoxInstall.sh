!# /usr/bin/bash

# Partition the disk
echo "Partitioning disk /dev/sda"
parted /dev/sda --script mklabel msdos
parted /dev/sda --script mkpart primary ext4 0% -2GiB
parted /dev/sda --script mkpart primary ext4 -2GiB 100%

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
