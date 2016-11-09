#!/bin/bash

################################################################################
# Задаємо змінні
################################################################################

# Вказуємо зовнішній IP сервера OpenVPN та назву мережевого інтерфейсу
INET_IP=46.164.134.26
INET_IFACE=enp6s0f1

# Вказуємо внутрішній IP сервера OpenVPN та назву мережевого інтерфейсу та мережа
LAN_IP=173.1.9.9
LAN_IFACE=enp6s0f0
LAN_RANGE=173.1.9.0/24

# Вказуємо назву мережевого пристрою OpenVPN та його мережу
VPN_IFACE=tun0
VPN_RANGE=10.15.0.0/24

# Вказуємо IP та назву мережевого інтерфейсу петлі 
LO_IP=127.0.0.1
LO_IFACE=lo

###################################################################################
# Задаємо правила фаєрволу для OpenVPN
###################################################################################

# Дозволяємо трафік між локальною мережею та VPN
# це потрібно для можливості доступу до серверу по внутрішньому IP з клієнта
iptables -D FORWARD -p all -i $LAN_IFACE -o $VPN_IFACE -j ACCEPT
iptables -D FORWARD -p all -o $LAN_IFACE -i $VPN_IFACE -j ACCEPT

# Дозволяємо вхідний та вихідний трафік для vpn-інтерфейсу
# потрібно для можливості встановлення vpn з'єднання
iptables -D INPUT -p all -i $VPN_IFACE -j ACCEPT
iptables -D OUTPUT -p all -o $VPN_IFACE -j ACCEPT

# Дозволяємо icmp пакети через vpn
# це потрібно для проходження ping
iptables -D INPUT -p icmp -m icmp -i $VPN_IFACE --icmp-type echo-request -j ACCEPT
iptables -D OUTPUT -p icmp -m icmp -o $VPN_IFACE --icmp-type echo-request -j ACCEPT

iptables -D FORWARD -p icmp -m icmp -i $VPN_IFACE -o $LAN_IFACE --icmp-type echo-request -j ACCEPT
iptables -D FORWARD -p icmp -m icmp -o $VPN_IFACE -i $LAN_IFACE --icmp-type echo-request -j ACCEPT

iptables -D INPUT -p icmp -m icmp -i $VPN_IFACE --icmp-type echo-reply -j ACCEPT
iptables -D OUTPUT -p icmp -m icmp -o $VPN_IFACE --icmp-type echo-reply -j ACCEPT

iptables -D FORWARD -p icmp -m icmp -i $VPN_IFACE -o $LAN_IFACE --icmp-type echo-reply -j ACCEPT
iptables -D FORWARD -p icmp -m icmp -o $VPN_IFACE -i $LAN_IFACE --icmp-type echo-reply -j ACCEPT