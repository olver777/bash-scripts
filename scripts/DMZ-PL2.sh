#!/bin/bash

IF_EXT="enp6s0f1"
IF_LAN="enp6s0f0"
IF_DMZ="enp5s1"
DMZ_IFOBS="192.168.9.2"
IFOBS_BL="173.1.9.230"

## CLEAN ALL TABLES
iptables -t filter -F
iptables -t nat -F
iptables -t mangle -F

## CLEAN USERS SETINGS
iptables -t filter -X
iptables -t nat -X
iptables -t mangle -X

## DEFAULT SETINGS
iptables -t filter -P INPUT DROP
iptables -t filter -P OUTPUT DROP
iptables -t filter -P FORWARD DROP

## loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

## ENABLE SNAT
iptables -t nat -A POSTROUTING -o $IF_EXT -j MASQUERADE

## ENABLE  OUT IN INET
iptables -A FORWARD -i $IF_LAN -o $IF_EXT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $IF_EXT -o $IF_LAN -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

## ICMP-MESSAGE
iptables -I INPUT -p icmp -m icmp --icmp-type 3 -j ACCEPT
iptables -I INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
iptables -I INPUT -p icmp -m icmp --icmp-type 12 -j ACCEPT
iptables -I INPUT -p icmp --icmp-type echo-request -m limit --limit 180/minute -j ACCEPT
iptables -I INPUT -p icmp -m limit --limit 50/minute -j LOG

## DMZ
## ENABLE DNAT FOR iFOBS_PL IN DMZ
iptables -t nat -A PREROUTING -p tcp -i $IF_EXT --dport 7002 -j DNAT --to-destination $DMZ_IFOBS

## FROM DMZ TO INET 
iptables -A FORWARD -i $IF_DMZ -o $IF_EXT -j ACCEPT
iptables -A FORWARD -i $IF_EXT -o $IF_DMZ -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp -i $IF_EXT -o $IF_DMZ -d $DMZ_IFOBS --dport 7002 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

## INTRANET  ROUTING
iptables -A FORWARD -i $IF_LAN -o $IF_DMZ -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp -i $IF_LAN -o $IF_DMZ -d $DMZ_IFOBS --dport 7002 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp -i $IF_LAN -o $IF_DMZ -d $DMZ_IFOBS --dport 1098 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp -i $IF_LAN -o $IF_DMZ -d $DMZ_IFOBS --dport 1099 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp -i $IF_LAN -o $IF_DMZ -d $DMZ_IFOBS --dport 4444 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp -i $IF_LAN -o $IF_DMZ -d $DMZ_IFOBS --dport 4445 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp -i $IF_LAN -o $IF_DMZ -d $DMZ_IFOBS --dport 4446 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp -i $IF_LAN -o $IF_DMZ -d $DMZ_IFOBS --dport 4447 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp -i $IF_LAN -o $IF_DMZ -d $DMZ_IFOBS --dport 4448 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp -i $IF_LAN -o $IF_DMZ -d $DMZ_IFOBS --dport 16080 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $IF_DMZ -o $IF_LAN -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp -i $IF_DMZ -o $IF_LAN -d $IFOBS_BL --dport 16080 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp -i $IF_DMZ -o $IF_LAN -d $IFOBS_BL --dport 1098 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp -i $IF_DMZ -o $IF_LAN -d $IFOBS_BL --dport 1099 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp -i $IF_DMZ -o $IF_LAN -d $IFOBS_BL --dport 4444 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp -i $IF_DMZ -o $IF_LAN -d $IFOBS_BL --dport 4445 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp -i $IF_DMZ -o $IF_LAN -d $IFOBS_BL --dport 4446 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp -i $IF_DMZ -o $IF_LAN -d $IFOBS_BL --dport 4447 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp -i $IF_DMZ -o $IF_LAN -d $IFOBS_BL --dport 4448 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT


## FROM INET TO SERVER PORTS
iptables -A INPUT -i $IF_EXT -p udp --dport 1194 -j ACCEPT

## SSH 
iptables -A INPUT -i $IF_LAN -p tcp -s 173.1.9.22 --dport 22 -j ACCEPT
iptables -A INPUT -i $IF_LAN -p tcp -s 173.1.9.87 --dport 22 -j ACCEPT

## Post forwarding
iptables -t nat -A PREROUTING -d 46.164.134.26 -p tcp -m tcp --dport 25 --to-source 173.1.9.10