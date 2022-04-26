#!/bin/bash
wget -O toxiproxy-2.1.4.deb https://github.com/Shopify/toxiproxy/releases/download/v2.1.4/toxiproxy_2.1.4_amd64.deb
sudo dpkg -i toxiproxy-2.1.4.deb
service_config="[Unit]
Description=ToxiProxy Server
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
WorkingDirectory=/tmp/
ExecStart=/usr/bin/toxiproxy-server -port 8474 -host 0.0.0.0
Restart=on-failure
RestartSec=10
StartLimitInterval=0
PrivateTmp=true
PrivateDevices=true
[Install]
WantedBy=multi-user.target"
printf "${service_config}" > toxiproxy.service
sudo cp toxiproxy.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start toxiproxy.service