#!/bin/bash
#get install directory
Install_Dir=`pwd`
# set install directory in AlexaWget script
grep "INSTALLED" $Install_Dir/AlexaWget.CentOS.sh
already=$?
if [ $already -eq 1 ]
	then
		sed "/^#INSTALL/a Install_Dir=$Install_Dir" $Install_Dir/AlexaWget.CentOS.sh >$Install_Dir/working.file
		echo '#INSTALLED' >> $Install_Dir/working.file
		cp $Install_Dir/working.file $Install_Dir/AlexaWget.CentOS.sh
		rm -f $Install_Dir/working.file
fi
#Setup AD Users
clear
test -f $Install_Dir/users.txt
users_exist=`echo $?`
if [ "$users_exist" -ne "0" ]
	then
		echo it looks like users.txt is not ready let\'s set it up
		echo enter AD users to be use for NTLM Authentication
		echo enter in the format user\:password
		echo enter a \".\" on an empty line to finish
		read reply
		while [ $reply != . ]
			do
				echo $reply >> users.txt
				read reply
			done
fi

#Setup proxies.txt
clear
test -f $Install_Dir/proxies.txt
proxies_exist=`echo $?`
if [ "$proxies_exist" -ne "0" ]
        then
                echo it looks like proxies.txt is not ready let\'s set it up
                echo enter proxy information
		echo you can enter more than one proxy
                echo enter in the format IP.ADDRESS:PORT
		echo I.E. 192.168.88.100:8080
                echo enter a \".\" on an empty line to finish
                read reply
                while [ $reply != . ]
                        do
                                echo $reply >> proxies.txt
                                read reply
                        done
fi

#Build the runit.sh command with the proper arguments to keep the program running in a loop
test -f $Install_Dir/runit.CentOS.sh
runit_exist=`echo $?`
if [ "$runit_exist" -ne "0" ]
	then
		echo it looks like runit.CentOS.sh is not ready let\'s set it up
		echo let\'s answer a few questions
		echo
		echo what is the domain name
		echo I.E. Domain1.com
		read domain
		clear
		echo how many URL\'s do you want to run in each session
		echo I.E. 1000
		read number
			# Ask if DLP incidents are wanted
			clear
			echo Would you like to generate incidents for DLP as well\?
			echo enter y\/n
			read dlp
#echo dlp is $dlp
			if [ "$dlp" == "y" ]
			        then
					dlp=dlp
					echo Would you like to create Email DLP Incidents\?
					echo y\/n
					read reply
					if [ "$reply" == "y" ]
						then
					                echo enter the IP Address of the DLP MTA to send emails to
							mail_dlp=y
					                read mta
					else
							mail_dlp=n
							mta="."
					fi
# Web DLP 
                                        echo Would you like to create Web DLP Incidents\?
                                        echo y\/n
                                        read reply
                                        if [ "$reply" == "y" ]
                                                then
							web_dlp=y
                                        else
                                                       web_dlp=n 
                                        fi
# Inbound Email
                                        echo Would you like to generate Inbound email for inspection\?
                                        echo y\/n
                                        read reply
                                        if [ "$reply" == "y" ]
                                                then
                                                        inbound=y
                                        else
                                                       	inbound=n
                                        fi


			fi

		clear
		echo building runit.CentOS.sh
		echo while true >> $Install_Dir/runit.CentOS.sh
		echo do >> $Install_Dir/runit.CentOS.sh
		echo "`pwd`/AlexaWget.CentOS.sh 0 $domain r $number $dlp $mta $mail_dlp $web_dlp $inbound" >> runit.CentOS.sh
		echo done >> $Install_Dir/runit.CentOS.sh
		chmod +x runit.CentOS.sh
fi
#a list is used by the program to calculate sleep times
#we will set the mode of fast/normal/slow
#by building the list 1-3=fast 1-5=normal 1-8=slow
test -f $Install_Dir/sleep_list
sleep_exist=`echo $?`
	if [ "$sleep_exist" -ne "0" ]
		then
			echo It looks like we need to set the speed
			echo do you want to be in Slow \/ Normal \/ Fast mode\?
			echo enter s\/n\/f
			read mode
				case $mode in
					s)
						counter=1
						while [ $counter != 9 ]
							do 
							echo $counter >> $Install_Dir/sleep_list
							counter=$(( $counter + 1 ))
						done
					;;
					n)
                                                counter=1
                                                while [ $counter != 6 ]
                                                        do
                                                        echo $counter >> $Install_Dir/sleep_list
                                                        counter=$(( $counter + 1 ))
                                                done
                                        ;;

					f)
                                                counter=1
                                                while [ $counter != 4 ]
                                                        do
                                                        echo $counter >> $Install_Dir/sleep_list
                                                        counter=$(( $counter + 1 ))
                                                done
                                        ;;

				esac
	fi
#Some versions of linux may not have the wget command.
#test for it and offer to yum if not found
test -f /usr/bin/wget
if_wget=`echo $?`
if [ "$if_wget" -ne "0" ]
        then
        echo wget not found, would you like me to get it for you?
        echo y\/n
        read reply
                if [ "$reply" != "y" ]
                        then
                                echo exiting then
                                exit 2
                        else
                                echo fetching, please wait
                                yum install wget -y
                fi
fi
#Some versions of linux may not have the perl libraries .
#test for it and offer to yum if not found
test -f /usr/share/perl5/base.pm
if_perl=`echo $?`
if [ "$if_perl" -ne "0" ]
        then
        echo perl not found, would you like me to get it for you?
        echo y\/n
        read reply
                if [ "$reply" != "y" ]
                        then
                                echo exiting then
                                exit 2
                        else
                                echo fetching, please wait
                                yum install perl -y
                fi
fi
#Some versions of linux may not have the unzip command.
#test for it and offer to yum if not found
test -f /usr/bin/unzip
if_unzip=`echo $?`
if [ "$if_unzip" -ne "0" ]
        then
        echo unzip not found, would you like me to get it for you?
        echo y\/n
        read reply
                if [ "$reply" != "y" ]
                        then
                                echo exiting then
                                exit 2
                        else
                                echo fetching, please wait
                                yum install zip unzip -y
                fi
fi

#Some versions of linux may not have the mailx command.
#test for it and offer to yum if not found
test -f /bin/mailx
if_mailx=`echo $?`
if [ "$if_mailx" -ne "0" ]
        then
        echo mailx not found, would you like me to get it for you?
        echo y\/n
        read reply
                if [ "$reply" != "y" ]
                        then
                                echo exiting then
                                exit 2
                        else
                                echo fetching, please wait
                                yum install mailx -y
                fi
fi


#Setup interfaces.txt
test -f $Install_Dir/interfaces.txt
interfaces_exist=`echo $?`
#echo interface flag is $interfaces_exist
if [ "$interfaces_exist" -ne "0" ]
        then
                echo it looks like interfaces.txt is not ready let\'s set it up
		echo Press Enter to do that
		read reply
                        cd tools;./get_interfaces.sh
fi

/usr/local/tinygen/tools/tz.sh
#looks like we are ready
clear
#lets offer to set up the rc.local file for auto start
#first find out if we are already there
grep "runit.CentOS" /etc/rc.d/rc.local > /dev/null
rclocal=$?
if [ "$rclocal" = "1" ]
then
	echo "I can set up your /etc/rc.d/rc.local file to autostart"
	echo "this tool at boot time if you want"
	echo "would you like to do that?"
	echo y\/n
	read reply
	if [ "$reply" = "y" ]
		then
			echo "$Install_Dir/runit.CentOS.sh > /tmp/runit.log &" >> /etc/rc.d/rc.local
		chmod 700 /etc/rc.d/rc.local
#		echo I need to reboot to set Tiny-Gen into action
#		echo would you like to do that now? y\/n
#		read reply
#		if [ "$reply" == "y" ]
#			then
#				echo OK Re-Booting
#				sleep 2
#				reboot
#		fi
		/etc/rc.d/rc.local
	fi
fi
echo All dependancies appear to have been met
echo do you want to try these settings\?
echo y\/n
read reply
if [ "$reply" != "n" ]
	then
		$Install_Dir/runit.CentOS.sh
		/usr/local/tinygen/tgcc
fi
