#!/usr/bin/env bash

echo 'Configuring systemd-swap...'

cat | sudo tee /etc/systemd/system/systemd-swap.service <<EOF
zswap_enabled=0
zram_enabled=1
zram_size=$(( RAM_SIZE / 2 ))
zram_count=1
EOF

sudo systemctl enable --now systemd-swap

# Resize the Deck's built in swapfile to 4G
sudo swapoff /home/swapfile
sudo rm /home/swapfile
sudo /usr/bin/mkswapfile /home/swapfile 4096

echo 'Done. Reboot your Deck'