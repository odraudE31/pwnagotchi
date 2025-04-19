#!/usr/bin/env bash
# Edited by Doctor X - @xNigredo -- t.me/pwnagotchiitalia
set -e

# pwnagotchi ip address for ssh connection
GOTCHI_ADDR=pi@10.0.0.2
# dns you want to use (es: 1.1.1.1)
YOUR_DNS=1.1.1.1

# name of the ethernet gadget interface on the host
USB_IFACE=${6:-enx62575ea8cd3d}
USB_IFACE_IP=10.0.0.1
USB_IFACE_NET=10.0.0.0/24
# host interface to use for upstream connection
UPSTREAM_IFACE=${3:-wlp3s0}

ip addr flush "$USB_IFACE"

ip addr add "$USB_IFACE_IP/24" dev "$USB_IFACE"
ip link set "$USB_IFACE" up

iptables -A FORWARD -o "$UPSTREAM_IFACE" -i "$USB_IFACE" -s "$USB_IFACE_NET" -m conntrack --ctstate NEW -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -t nat -F POSTROUTING
iptables -t nat -A POSTROUTING -o "$UPSTREAM_IFACE" -j MASQUERADE

echo 1 > /proc/sys/net/ipv4/ip_forward

ssh "$GOTCHI_ADDR" "echo nameserver $YOUR_DNS | sudo tee -a /etc/resolv.conf"