#!/usr/bin/env bash

echo 'Configuring systemd-resolved...'

sudo mkdir -p /etc/systemd/resolved.conf.d/
cat | sudo tee /etc/systemd/resolved.conf.d/99-dot-dns.conf <<EOF
[Resolve]
DNS=1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com 2606:4700:4700::1001#cloudflare-dns.com
DNSOverTLS=yes
EOF

sudo systemctl restart systemd-resolved

echo 'Done.'
