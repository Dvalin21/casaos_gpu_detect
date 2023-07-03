#!/bin/bash

#After Ubuntu Server install
sudo apt-get update
sudo apt-get upgrade -y

#Installing Dependencies
sudo apt-get install ffmpeg -y

#Installing Drivers for Nvidia GPU
if lspci | grep -i nvidia; then
  echo "Nvidia GPU detected"
  sudo apt-get update && sudo apt install nvidia-driver-515 nvidia-dkms-515 && sudo apt-get install nvidia-smi -y
else
  echo "Nvidia GPU not detected"
fi

#Installing Drivers for AMD GPU
if lspci | grep -i amd; then
  echo "AMD GPU detected"
sudo apt-get update
wget https://repo.radeon.com/amdgpu-install/22.40.5/ubuntu/jammy/amdgpu-install_5.4.50405-1_all.deb
sudo chmod +x amdgpu-install_5.4.50405-1_all.deb
sudo apt-get install ./amdgpu-install_5.4.50405-1_all.deb -y #Required to hit "Enter" after install and then the rest will continue.
sudo amdgpu-install --usecase=rocm -y --accept-eula --no-32 && sudo apt install vainfo radeontop && sudo apt install docker-compose && sudo apt install libgl1-mesa-glx libgl1-mesa-dri xserver-xorg-video-amdgpu -y && sudo usermod -a -G video $LOGNAME && sudo usermod -a -G render $LOGNAME
else
  echo "AMD GPU not detected"
fi

if lspci -nn | grep 089a; then
  echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" | sudo tee /etc/apt/sources.list.d/coral-edgetpu.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-get update
sudo apt-get install gasket-dkms libedgetpu1-std
sudo sh -c "echo 'SUBSYSTEM==\"apex\", MODE=\"0660\", GROUP=\"apex\"' >> /etc/udev/rules.d/65-apex.rules"
sudo groupadd apex
sudo adduser $USER apex
else
  echo "Coral EdgeTpu PCIE not detected"
fi

#Installing Git if missing
if ! [ -x "$(command -v git)" ]; then
  echo 'Error: git is not installed.' >&2
  sudo apt-get install git -y
fi

#CasaOS install
curl -fsSL https://get.casaos.io | sudo bash

#After complete install.
sudo apt-get update
sudo apt-get install aptitude
sudo aptitude safe-upgrade -y
sudo apt-get autoremove

# System Restart
sudo reboot
