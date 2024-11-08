SERVER=$1
PASSWORD=$2

sudo sysctl -w net.ipv4.conf.all.forwarding=1

sudo mkdir -p /etc/trojan-go

wget https://github.com/p4gefau1t/trojan-go/releases/download/v0.10.6/trojan-go-linux-amd64.zip
unzip trojan-go-linux-amd64.zip
install trojan-go /usr/bin/
rm -rf example  geoip.dat  geoip-only-cn-private.dat  geosite.dat trojan-go  trojan-go-linux-amd64.zip

# config file
cat <<EOF >config.json
{
    "run_type": "nat",
    "local_addr": "0.0.0.0",
    "local_port": 1080,
    "remote_addr": "$SERVER",
    "remote_port": 443,
    "password": [
        "$PASSWORD"
    ]
}
EOF
sudo mv config.json /etc/trojan-go/config.json


# service file
cat <<EOF >trojan-go.service
[Unit]
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=trojan-go -config /etc/trojan-go/config.json
ExecStartPost=sh /etc/trojan-go/nat.sh
Restart=on-failure
RestartSec=3s
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target    
EOF

sudo mv trojan-go.service /etc/systemd/system/


# etc file
mkdir -p /etc/trojan-go/
cp nat.sh /etc/trojan-go/nat.sh
