#!/usr/bin/env bash
echo 'Running the official spoof-dpi install script, please wait...'
curl -fsSL https://raw.githubusercontent.com/xvzc/SpoofDPI/main/install.sh | bash -s linux-amd64

echo 'Installing systemd service...'
cat >/home/$USER/.config/systemd/user/spoofdpi.service <<EOF
[Unit]
Description=SpoofDPI

[Service]
ExecStart=/home/$USER/.spoof-dpi/bin/spoof-dpi -port=9696 -addr=127.0.0.1 -no-banner=true -enable-doh=true
    
[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now spoofdpi.service

echo 'Configuring Gaming Mode to use SpoofDPI...'

mkdir -p /home/$USER/.steam/steam/config
cat >/home/$USER/.steam/steam/config/proxyconfig.vdf <<EOF
"proxyconfig"
{
	"proxy_mode"		"2"
	"address"		"http://127.0.0.1"
	"port"		"9696"
	"exclude_local"		"1"
}
EOF

echo 'Done. Please restart your Steam Deck'
