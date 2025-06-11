#!/bin/bash
sleep 10
sudo ip addr add 192.168.0.169/24 dev wlan0
sudo ip route add default via 192.168.0.1 dev wlan0