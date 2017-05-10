#!/bin/sh

IPTABLES=/sbin/iptables
EXTIF="eno1"
INTIF="eno2"
EXTIP="192.168.100.53"
#SSH10="192.168.168.10"
#SSH11="192.168.168.11"
#SSH12="192.168.168.12"
#SSH14="192.168.168.14"
RDPIP="192.168.20.28"
RDPPT=3389

echo " External Interface: $EXTIF"
echo " Internal Interface: $INTIF"

$IPTABLES -P INPUT ACCEPT
$IPTABLES -P FORWARD ACCEPT
$IPTABLES -P OUTPUT ACCEPT
$IPTABLES -t nat -P PREROUTING ACCEPT
$IPTABLES -t nat -P POSTROUTING ACCEPT
$IPTABLES -t nat -P OUTPUT ACCEPT
#
# reset the default policies in the mangle table.
#
$IPTABLES -t mangle -P PREROUTING ACCEPT
$IPTABLES -t mangle -P POSTROUTING ACCEPT
$IPTABLES -t mangle -P INPUT ACCEPT
$IPTABLES -t mangle -P OUTPUT ACCEPT
$IPTABLES -t mangle -P FORWARD ACCEPT
#
# flush all the rules in the filter and nat tables.
#
echo " Flush exiting rules and set new rules"
$IPTABLES -F
$IPTABLES -t nat -F
$IPTABLES -t mangle -F

$IPTABLES -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPTABLES -A INPUT -p icmp -j ACCEPT
$IPTABLES -A INPUT -i lo -j ACCEPT
$IPTABLES -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 22 -m state --state ESTABLISHED -j ACCEPT
$IPTABLES -A FORWARD -i $EXTIF -o $INTIF -m state --state RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -A FORWARD -i $INTIF -o $EXTIF -j ACCEPT

echo " Build RDP redirection"
$IPTABLES -t nat -A POSTROUTING -o $EXTIF -s 192.168.20.0/24 -j SNAT --to-source $EXTIP
$IPTABLES -t nat -A PREROUTING -d $EXTIP -i $EXTIF -p tcp --dport $RDPPT -j DNAT --to-destination $RDPIP:$RDPPT

echo " Build SSH redirection"
#$IPTABLES -t nat -A POSTROUTING -o $EXTIF -s 192.168.168.0/24 -j SNAT --to-source $EXTIP
#$IPTABLES -t nat -A PREROUTING -d $EXTIP -i $EXTIF -p tcp --dport 1022 -j DNAT --to-destination $SSH10:22
#$IPTABLES -t nat -A PREROUTING -d $EXTIP -i $EXTIF -p tcp --dport 1122 -j DNAT --to-destination $SSH11:22
#$IPTABLES -t nat -A PREROUTING -d $EXTIP -i $EXTIF -p tcp --dport 1222 -j DNAT --to-destination $SSH12:22
#$IPTABLES -t nat -A PREROUTING -d $EXTIP -i $EXTIF -p tcp --dport 2222 -j DNAT --to-destination $SSH14:22
echo " It's OK now."
