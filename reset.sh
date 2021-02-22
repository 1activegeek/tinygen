#!/bin/bash
fix_rclocal () {
grep -i runit.centos.sh /etc/rc.d/rc.local> /dev/null
auto=`echo $?`
if [ "$auto" = "0" ]
	then
		clear
		echo "It appears that you have set runit to start at startup"
		echo "I will return /etc/rc.d/rc.local to its original state"
		echo "A reboot WILL BE REQUIRED I will offer to do this when I am finished"
		echo Press Enter to Continue
		read x
		grep -v -i runit.centos.sh /etc/rc.d/rc.local | grep -v runit_ep.sh > working.file
		mv ./working.file /etc/rc.d/rc.local
		chmod 700 /etc/rc.d/rc.local
		echo "I have fixed /etc/rc.d/rc.local"
		echo "would you like to reboot now?"
		echo "y\/n"
		read reply
		if [ "$reply" = "y" ]
			then
				reboot
		fi
fi

}

if [ "$1" != "rc.d" ]
	then
		grep -v 'Install_Dir=' AlexaWget.CentOS.sh | grep -v INSTALLED > working.file
		echo Setting AlexaWgetCentos.sh to factory state 
		echo and removing files
		cp ./working.file AlexaWget.CentOS.sh
		rm -f ./users.txt
		rm -f ./runit.CentOS.sh
		rm -f ./sleep_list
		rm -f ./myurls.txt
		rm -f ./working.file
		rm -f ./files.txt
		rm -f ./interfaces.txt
		rm -f ./bodies.txt
		rm -f ./shares.txt
		rm -f ./proxies.txt
		rm -f ./top-1m.txt
		> /tmp/runit.log
		> /tmp/endpoint.log
		echo re-setting speed values
		/usr/local/tinygen/change_speed.sh reset
		fix_rclocal
	else
		fix_rclocal
		
fi
echo .
echo .
echo .
echo DONE

