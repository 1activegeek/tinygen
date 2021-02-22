#!/bin/bash
clear
test -f /etc/profile.d/startup.sh
appliance=$?
if [ "$appliance" != "0" ]
	then
		echo This tool is actually intended to be used on the
		echo Tiny-Gen Virtual Appliance
		echo It looks like you may be on a Software Only Installation
		echo While I can change the IP Address Information
		echo I can\'t Guarantee that I wont stomp on changes you
		echo may have made to the networking files
		echo Continue\?
		echo y\/n
		read reply
		if [ "$reply" = "n" ]
			then
				exit
		fi
fi
echo OK Let\'s set the IP Addressing information
echo do you want \(s\)tatic or \(d\)hcp\?
echo enter s\/d
read mode

# OK let's the set the default back 
cat /etc/sysconfig/network-scripts/ifcfg-ens32 | grep -v IPADDR| grep -v BOOTPROTO | grep -v DNS | grep -v NETMASK > ifcfg-ens32
grep -v GATEWAY /etc/sysconfig/network > network

#Time to do some editing
if [ "$mode" = "d" ]
	then
		echo BOOTPROTO=dhcp>> ifcfg-ens32
	else
		echo Enter the IP Address you want to use
		read IP
		echo Enter the NetMask you want to use
		read NetMask
		echo enter the DNS Server to use
		read DNS
		echo Enter the Default Gateway
		read GWY
		echo BOOTPROTO=static >> ifcfg-ens32
		echo IPADDR\=$IP >> ifcfg-ens32
		echo NETMASK\=$NetMask >> ifcfg-ens32
		echo DNS1\=$DNS >> ifcfg-ens32
		echo GATEWAY\=$GWY >> network
		
fi
clear
echo Building /etc/sysconfig/network-scripts/ifcfg-ens32
cp ./ifcfg-ens32 /etc/sysconfig/network-scripts/ifcfg-ens32
echo Building /etc/sysconfig/network
cp ./network /etc/sysconfig/network
echo would you like to restart the network now\?
echo enter y\/n
read restart
if [ "$restart" = "y" ]
	then
		echo OK restarting network
		service network restart
fi
if [ "$1" != "log" ]
	then
		rm ./network
		rm ./ifcfg-ens32
fi
echo OK then we are done
