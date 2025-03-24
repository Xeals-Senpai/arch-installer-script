#!/bin/bash

ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

hwclock --systohc

echo Setting up the following configurations
echo Setting up locales

echo -e "en_GB.UTF-8" >> /etc/locale.gen
locale-gen

echo Setting up keyboard mappings and keyboard language
echo LANG=en_GB.UTF-8 >> /etc/locale.conf
echo KEYMAP=uk >> /etc/vconsole.conf

echo setting up device hostname and user accounts
echo enter the device hostname
read HostName
echo $HostName >> /etc/hostname
echo -e "127.0.0.1  localhost\n::1 localhost\n127.0.0.1   $HostName.localdomain $HostName" >> /etc/hosts

echo set root password
passwd

echo Setting up User accounts
echo Enter username
read UserName
useradd -m $UserName
echo set $UserName password
passwd $UserName

echo setting up user priviliges
gpasswd -a $UserName wheel
gpasswd -a $UserName video
gpasswd -a $UserName audio
gpasswd -a $UserName input

echo "Do you wish to elevate the accounts privilige to root? (y/n)"
read choice

if [ "$choice" == "y" ]; then
	echo '$UserName ALL=(ALL) NOPASSWD: ALL' | EDITOR='tee -a' visudo
fi

echo Downloading applications

pacman -S ntfs-3g gvfs gvfs-smb jq pkgfile go wget noto-fonts polkit-gnome playerctl nemo nemo-fileroller nemo-terminal zsh python-pip pipewire pipewire-pulse pavucontrol ttf-font-awesome base-devel sway vim neovim waybar kitty dunst wl-clipboard swayidle slurp grim noto-fonts-emoji noto-fonts-cjk firefox gnome-disk-utility baobab seahorse qt5-wayland qt6-wayland xorg-xwayland git swaybg gtk2 gtk3 mpv imv feh man htop

#Other recommended packages to download 
#thunar thunar-archive-plugin file-roller pulseaudio

echo "What is your cpu type? (a = AMD or i = Intel)"
read cputype

if [ "$cputype" == "a" ]; then
	pacman -S amd-ucode
	ucode=amd-ucode.img

else
	pacman -S intel-ucode
	ucode=intel-ucode.img

fi

echo Setting up bootloader
echo "Enter EFI/boot directory location (Default: /boot"
read EFILocation

[ -d $EFILocation ] || $EFILocation=/boot

echo "Do you wish to install a bootloader? (y will install grub otherwise user feel free to install other bootloaders)"
read bootloaderchoice

#if [ "$bootloaderchoice" == "y" ]; then
	#pacman -S grub efibootmgr os-prober
	#grub-install --target=x86_64-efi --efi-directory=$EFILocation	--bootloader-id=GRUB
	#grub-mkconfig -o /boot/grub/grub.cfg
#else
	#echo Feel free to install other bootloader options

#fi

echo installing yaourt-git or yay :D
cd /home/$UserName
git clone https://aur.archlinux.org/yay-git.git
chown $UserName yay-git
cd yay-git
su $UserName -c "makepkg -si"
cd /home/$UserName
rm -rfd yay-git

echo Downloading dotfiles
cd /home/$UserName/Documents
git clone https://github.com/xeals-senpai/dotfiles.git
cd dotfiles
git submodule init
git submodule update
cp -r /home/$UserName/Documents/dotfiles/.config /home/$UserName
cp -r /home/$UserName/Documents/dotfiles/.z* /home/$UserName
cp -r /home/$UserName/Documents/dotfiles/.gitconfig /home/$UserName
cd /home/$Username

echo Installing aur packages
su $UserName  -c "yay -S networkmanager network-manager-applet swaylock-effects-git swappy redshift-wayland-git autotiling breeze-default-cursor-theme rofi-lbonn-wayland-git discord-screenaudio signal-desktop cmatrix nwg-look materia-gtk-theme  "

echo Activating Networkmanager services
su $Username -c "sudo systemctl enable NetworkManager.services"
su $Username -c "sudo systemctl start NetworkManager.services"

echo changing the users shell to zsh
chsh -s /bin/zsh $Username
