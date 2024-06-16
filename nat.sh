#!/bin/bash

SERVER=$1
PORT=1080

NO_PROXY_IP=$(dig $SERVER +short)
CHAIN_NAME=TROJAN

sysctl -w net.ipv4.conf.all.forwarding=1 

if [ -z "$SERVER" ]; then
    echo 'server not found in param $1, quiting'
    exit 1
fi

if [ -z "$NO_PROXY_IP" ]; then
    echo 'server ip not found, quiting'
    exit 1
fi

# clean first
iptables -t nat -F $CHAIN_NAME
iptables -t nat -D PREROUTING -j $CHAIN_NAME 2>/dev/null
iptables -t nat -D OUTPUT -j $CHAIN_NAME 2>/dev/null
iptables -t nat -X $CHAIN_NAME

iptables -t mangle -F $CHAIN_NAME
iptables -t mangle -D PREROUTING -j $CHAIN_NAME 2>/dev/null
iptables -t mangle -X $CHAIN_NAME

# Create new chain
iptables -t nat -N $CHAIN_NAME
iptables -t mangle -N $CHAIN_NAME

# nat
iptables -t nat -A $CHAIN_NAME -d $NO_PROXY_IP -j RETURN
iptables -t nat -A $CHAIN_NAME -d 0.0.0.0/8 -j RETURN
iptables -t nat -A $CHAIN_NAME -d 10.0.0.0/8 -j RETURN
iptables -t nat -A $CHAIN_NAME -d 127.0.0.0/8 -j RETURN
iptables -t nat -A $CHAIN_NAME -d 169.254.0.0/16 -j RETURN
iptables -t nat -A $CHAIN_NAME -d 172.16.0.0/12 -j RETURN
iptables -t nat -A $CHAIN_NAME -d 192.168.0.0/16 -j RETURN
iptables -t nat -A $CHAIN_NAME -d 224.0.0.0/4 -j RETURN
iptables -t nat -A $CHAIN_NAME -d 240.0.0.0/4 -j RETURN
iptables -t nat -A $CHAIN_NAME -p tcp -j REDIRECT --to-ports $PORT

iptables -t nat -A PREROUTING -j $CHAIN_NAME
iptables -t nat -A OUTPUT -j $CHAIN_NAME

# mangle
ip route add local default dev lo table 100
ip rule add fwmark 1 lookup 100

iptables -t mangle -A $CHAIN_NAME -d $NO_PROXY_IP -j RETURN
iptables -t mangle -A $CHAIN_NAME -d 0.0.0.0/8 -j RETURN
iptables -t mangle -A $CHAIN_NAME -d 10.0.0.0/8 -j RETURN
iptables -t mangle -A $CHAIN_NAME -d 127.0.0.0/8 -j RETURN
iptables -t mangle -A $CHAIN_NAME -d 169.254.0.0/16 -j RETURN
iptables -t mangle -A $CHAIN_NAME -d 172.16.0.0/12 -j RETURN
iptables -t mangle -A $CHAIN_NAME -d 192.168.0.0/16 -j RETURN
iptables -t mangle -A $CHAIN_NAME -d 224.0.0.0/4 -j RETURN
iptables -t mangle -A $CHAIN_NAME -d 240.0.0.0/4 -j RETURN
iptables -t mangle -A $CHAIN_NAME -p udp -j TPROXY --on-port $PORT --tproxy-mark 0x01/0x01

iptables -t mangle -A PREROUTING -j $CHAIN_NAME
