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
read $choice

if [ "$choice" == "y" ]; then
	echo '$UserName ALL=(ALL) NOPASSWD: ALL' | EDITOR='tee -a' visudo
fi

echo Downloading applications

pacman -S ntfs-3g gvfs gvfs-smb jq pkgfile go wget noto-fonts polkit-gnome playerctl pcmanfm file-roller zsh python-pip pulseaudio pavucontrol ttf-font-awesome base-devel sway vim neovim waybar kitty dunst wl-clipboard swayidle slurp grim noto-fonts-emoji noto-fonts-cjk firefox gnome-disk-utility baobab seahorse lxappearance qt5-wayland qt6-wayland xorg-xwayland git swaybg gtk2 gtk3 

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

if [ "$bootlaoderchoice" == "y" ]; then
	pacman -S grub efibootmgr os-prober
	grub-install --target=x86_64-efi --efi-directory=$EFILocation	--bootloader-id=GRUB
	grub-mkconfig -o /boot/grub/grub.cfg
else
	echo Feel free to install other bootloader options

fi

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
cd ..
cp -r /home/$UserName/dotfiles/.config /home/$UserName
cp -r /home/$UserName/dotfiles/.z* /home/$UserName
cp -r /home/$UserName/dotfiles/.gitconfig /home/$UserName
cp -r /home/$UserName/dotfiles/.xinitrc /home/$UserName

echo Installing aur packages
su $UserName  -c "yay -S networkmanager network-manager-applet swaylock-effects-git swappy redshift-wayland-git autotiling breeze-default-cursor-theme rofi-lbonn-wayland-git discord signal-desktop mellowplayer pass"

echo Setting up MellowPlayer plugins
echo installing WideVine DRM plugin
curl -s "https://gitlab.com/ColinDuquesnoy/MellowPlayer/-/raw/master/scripts/install-widevine.sh" | bash

