#!/bin/sh

echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -F
iptables -t nat -F
iptables -X

iptables -t nat -A PREROUTING -p tcp --dport 6443 -j DNAT --to-destination 172.28.128.124:6443
iptables -t nat -A POSTROUTING -p tcp -d 172.28.128.125 --dport 6443 -j SNAT --to-source 172.28.128.124

sudo iptables-save | sudo tee /etc/iptables.up.ruless
