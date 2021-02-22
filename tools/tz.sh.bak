echo please enter timezone \(enter \"l\" to see a list\)
read reply
if [ "$reply" == "l" ]
	then
		more /usr/local/tinygen/timezones.txt
		echo enter timezone
		read tz
#		grep $tz /usr/local/tinygen/timezones.txt
#		echo $?
		timedatectl set-timezone $tz
	else
#                grep $reply /usr/local/tinygen/timezones.txt
#                echo $?
		timedatectl set-timezone $reply
fi


