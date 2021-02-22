#!/bin/bash
clear
interfaces=`ip addr show | grep "inet" | grep -v 127.0.0.1 | awk '{print $2}' | awk -F "/" '{print $1}'| grep 192`
show_interfaces() {
for nics in `echo $interfaces`
	do
		echo $nics
	done
}
num=`echo $interfaces | wc -w `
		echo I have found one or more interfaces with an IP Address
		echo I must admit\, my logic isn\'t that great and I would not 
		echo be surprised if it may look wrong to you
		echo that is why I give you a chance to enter manually as well
		echo
		echo Here are the IP Addresses I have found
		show_interfaces
if [ "$1" != "show" ]
	then
	  if [ "$1" == "y" ]
	    then
		show_interfaces> ../interfaces.txt
		exit 0
	    else

		echo would you like to use these interfaces to generate traffic
		echo answer \"n\" to manualy input interfaces to be used
		echo y/n
		read reply
		if [ "$reply" == "y" ]
			then
				show_interfaces> ../interfaces.txt
			else
				>../interfaces.txt
				echo enter ip adress\(es\) to bind requests to then
				echo enter a period \".\" on an empty ine to exit entry mode
			read reply
				while [ "$reply" != "." ]
					do
						echo $reply >> ../interfaces.txt
						read reply
					done
		fi
	fi
fi
