#!/bin/bash
echo "[*] EasyTether Auto Connector"

IFACE=$(ip link show | grep tun-easytether | awk -F: '{print $2}' | tr -d ' ')
if [ -z "$IFACE" ]; then
    echo "[!] EasyTether interface not found. Make sure your phone is connected via EasyTether and try again."
    exit 1
fi

echo "[*] Found interface: $IFACE"
sudo ip addr add 192.168.117.2/24 dev $IFACE 2>/dev/null
sudo ip link set $IFACE up
sudo ip route add default dev $IFACE 2>/dev/null
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null

ping -c 3 8.8.8.8 && echo "[+] Connection successful." || echo "[!] Connection failed. Check tethering and try again."
