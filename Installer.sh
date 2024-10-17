#!/bin/bash

function greetings {
    while true; do
        echo "Добро пожаловать в скрипт установки Arch Linux!"
        echo ""
        echo "######################################################################"
        echo "#                                                                    #"
        echo "#                          Приветствую!                              #"
        echo "#                  Начнем установку ArchLinux?                       #"
        echo "#                                                                    #"
        echo "#                                                     by SogoHimo    #"
        echo "#                                                                    #"
        echo "######################################################################"
        echo ""

        echo ""
        echo "----------------------------------------------------------------------"
        echo "######################################################################"
        echo "----------------------------------------------------------------------"
        echo ""

        read -p "Приступим к установке (да/нет): " askinstall

        if [[ \$askinstall == "да" ]]; then
            break
        elif [[ \$askinstall == "нет" ]]; then
            echo "Установка отменена. Выход."
            exit 0
        else
            echo "Неверный выбор. Попробуйте снова."
        fi
    done
}

function select_disk {
    while true; do
        fdisk -l
        echo ""
        echo "----------------------------------------------------------------------"
        echo "######################################################################"
        echo "----------------------------------------------------------------------"
        echo ""
        echo "Какой диск вы хотите использовать?"
        echo "1. /dev/sda"
        echo "2. /dev/sdb"
        echo "3. /dev/sdc"

        read -p "Введите номер диска (1, 2 или 3): " disk_number
        case $disk_number in
            1)
                selected_disk="/dev/sda"
                break
                ;;
            2)
                selected_disk="/dev/sdb"
                break
                ;;
            3)
                selected_disk="/dev/sdc"
                break
                ;;
            *)
                echo "Неверный выбор. Попробуйте снова."
                ;;
        esac
    done

    echo "Выбран диск: $selected_disk"
}

function partition_disk {
    (
        echo o;
        # boot
        echo n;
        echo;
        echo;
        echo;
        echo +300M;
        # root
        echo n;
        echo;
        echo;
        echo;
        echo +3G;
        # swap
        echo n;
        echo;
        echo;
        echo;
        echo +512M;
        # home
        echo n;
        echo p;
        echo;
        echo;
        echo a;
        echo 1;
        echo w;
    ) | fdisk $selected_disk
}
function create_filesystems {
    mkfs.ext2 ${selected_disk}1 -L boot
    mkfs.ext4 ${selected_disk}2 -L root
    mkswap ${selected_disk}3 -L swap
    mkfs.ext4 ${selected_disk}4 -L home
}

function mount_filesystems {
    mount ${selected_disk}2 /mnt
    mkdir /mnt/{boot,home}
    mount ${selected_disk}1 /mnt/boot
    swapon ${selected_disk}3
    mount ${selected_disk}4 /mnt/home
}

function install_base_packages {
    pacstrap /mnt base base-devel linux linux-firmware nano dhcpcd netctl
}

function generate_fstab {
    genfstab -pU /mnt >> /mnt/etc/fstab
}

function configure_system {
    read -p "Введи имя компьютера: " hostname
    read -p "Введи имя пользователя: " username

    echo $hostname > /mnt/etc/hostname
    ln -svf /usr/share/zoneinfo/Europe/Moscow /mnt/etc/localtime

    arch-chroot /mnt locale-gen

    echo 'LANG="ru_RU.UTF-8"' > /mnt/etc/locale.conf
    echo 'KEYMAP=ru' >> /mnt/etc/vconsole.conf
    echo 'FONT=cyr-sun16' >> /mnt/etc/vconsole.conf

    mkinitcpio -p linux

    pacman -Syy
    pacman -S grub --noconfirm
    grub-install /dev/${selected_disk}
    grub-mkconfig -o /boot/grub/grub.cfg
}

function configure_wifi {
    while true; do
        read -p "Есть ли Wi-Fi? (да/нет): " wifi_answer

        if [[ $wifi_answer == "да" ]]; then
            arch-chroot /mnt pacman -S dialog wpa_supplicant --noconfirm
            break
        elif [[ $wifi_answer == "нет" ]]; then
            break
        else
            echo "Неверный выбор. Попробуйте снова."
        fi
    done
}

function create_user {
    useradd -m -g users -G wheel -s /bin/bash $username

    passwd

    passwd $username

    echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
}

function install_gui {
    while true; do
        echo "xorg или plasma?"
        read -p "1 - xorg, 0 - plasma: " vm_setting

        if [[ $vm_setting == 0 ]]; then
            gui_install="plasma-wayland-session"
            break
        elif [[ $vm_setting == 1 ]]; then
            gui_install="xorg-server xorg-drivers xorg-xinit"
            break
        else
            echo "Неверный выбор. Попробуйте снова."
        fi
    done

    pacman -S $gui_install

    pacman -S plasma kde-applications sddm --noconfirm
    systemctl enable sddm

    pacman -S ttf-liberation ttf-dejavu --noconfirm

    sudo pacman -S ufw reflector timeshift nginx konsole tigervnc --noconfirm

    pacman -S networkmanager network-manager-applet ppp --noconfirm

    systemctl enable NetworkManager
}

greetings
select_disk
partition_disk
create_filesystems
mount_filesystems
install_base_packages
generate_fstab
configure_system
configure_wifi
create_user
install_gui
