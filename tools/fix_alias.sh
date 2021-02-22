#!/bin/bash
#script to set allias IP Addresses

#echo which interface do you want to set alliases for \?
#echo I.E. ens32
#read interface

#echo enter IP Addresses and Mask. When you are done enter a period \".\" 
#echo on an empty line
#echo I.E. 192.168.88.1/24
#read ip
#while [ "$ip" != "." ]
for ip in `cat /usr/local/tinygen/tools/ALIASES`
	do
	#	ip_addr=`echo $ip | awk -F"/" '{print $1}'`
	#	mask=`echo $ip | awk -F"/" '{print $2}'`
		ip addr add $ip/$24 dev ens32
	#	read ip
	done
