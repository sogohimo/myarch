#!/bin/bash
mkdir ~/downloads
cd ~/downloads

echo 'Установка AUR (yay)'
sudo pacman -Syu
sudo pacman -S wget --noconfirm
wget git.io/yay-install.sh && sh yay-install.sh --noconfirm

echo 'Создаем нужные директории'
sudo pacman -S xdg-user-dirs --noconfirm
xdg-user-dirs-update

echo 'Установка базовых программ и пакетов'
sudo pacman -S reflector ufw f2fs-tools dosfstools ntfs-3g alsa-lib alsa-utils file-roller p7zip gvfs aspell-ru pulseaudio pavucontrol --noconfirm

echo 'Установить рекомендумые программы?'
read -p "1 - Да, 0 - Нет: " prog_set
if [[ $prog_set == 1 ]]; then
  #Можно заменить на pacman -Qqm > ~/.pacmanlist.txt
  sudo pacman -S chromium flameshot veracrypt vlc filezilla gimp libreoffice libreoffice-fresh-ru neofetch qbittorrent telegram-desktop --noconfirm
  yay -Syy
  yay -S xflux sublime-text-dev hunspell-ru pamac-aur-git trello xorg-xkill ttf-symbola ttf-clear-sans --noconfirm
elif [[ $prog_set == 0 ]]; then
  echo 'Установка программ пропущена.'
fi

# Подключаем zRam
yay -S zramswap --noconfirm
sudo systemctl enable zramswap.service

echo 'Включаем сетевой экран'
sudo ufw enable

echo 'Добавляем в автозагрузку:'
sudo systemctl enable ufw

# Очистка
rm -rf ~/downloads/

echo 'Установка завершена!'
