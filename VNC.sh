#!/bin/bash

# Не забудь chmod +x setup_vnc.sh

vncpasswd
echo ":1=SogoHimo" >> /etc/tigervnc/vncserver.users
sudo mkdir -p ~/.vnc/
cd ~/.vnc/

sudo cat <<EOL > config
session=lxqt
geometry=1920x1080
localhost # comment this out to allow connections from anywhere
alwaysshared
EOL

sudo systemctl enable --now vncserver@:1.service
sudo systemctl start vncserver@:1

sudo ufw allow 5901

echo "VNC сервер настроен и запущен."
