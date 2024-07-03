#!/usr/bin/env bash

SECURE_DNS_SERVICE='mozilla.cloudflare-dns.com'
read -p "Enter a secure DoH DNS server name (default: $SECURE_DNS_SERVICE): " user_dns

if [ -z "$user_dns" ]; then
    # strip https:// from the beginning and /dns-query from the end if the user entered it
    SECURE_DNS_SERVICE=${SECURE_DNS_SERVICE#https://}
    SECURE_DNS_SERVICE=${SECURE_DNS_SERVICE#http://}
    SECURE_DNS_SERVICE=${SECURE_DNS_SERVICE%/dns-query}
fi

echo 'Testing secure DoH DNS server...'
curl -s -H "accept: application/dns-json" "https://$SECURE_DNS_SERVICE"/dns-query?name=apple.com > /dev/null
if [ $? -ne 0 ]; then
    echo "Failed to connect to $SECURE_DNS_SERVICE"
    exit 1
fi

echo "Using $SECURE_DNS_SERVICE as secure DoH DNS server"

echo 'Running the official spoof-dpi install script, please wait...'
curl -fsSL https://raw.githubusercontent.com/xvzc/SpoofDPI/main/install.sh | bash -s linux

echo 'Installing systemd service...'
cat > /home/$USER/.config/systemd/user/spoofdpi.service <<EOF
[Unit]
Description=SpoofDPI

[Service]
ExecStart=/home/$USER/.spoof-dpi/bin/spoof-dpi --port=9696 --addr=127.0.0.1 --no-banner=true --dns=$SECURE_DNS_SERVICE
    
[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now spoofdpi.service

echo 'Configuring Gaming Mode to use SpoofDPI...'

mkdir -p /home/$USER/.steam/steam/config
cat > /home/$USER/.steam/steam/config/proxyconfig.vdf <<EOF
"proxyconfig"
{
	"proxy_mode"		"2"
	"address"		"http://127.0.0.1"
	"port"		"9696"
	"exclude_local"		"1"
}
EOF

echo 'Done.'