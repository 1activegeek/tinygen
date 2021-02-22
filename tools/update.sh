#!/bin/bash
#A script to update tiny-gen from google docs
#This script will download a manifest from google drive
#static folder and file https://googledrive.com/host/0B9zYPoaKXwTZSW1qaW42MnkwMEk
#which is publicly shared. This manifest will have a version numbe (Integer)
#the version number is compared against a version number in tiny-gen's Install_Dir
#in a hidden file called .current_version. If Current Version is less than Latest
#Version an opportunity to upgrade is offered. The upgrade will find its filename
#in the second field of the mainfest

#get current version from update on Google Drive
clear
echo I will check for updates now
wget -q --no-check-certificate -O./.latest_version https://googledrive.com/host/0B9zYPoaKXwTZcEdQUFFqMEQ2bGM

#open file and get version number and update file hash

version=`tail -n 1 ./.latest_version | awk '{print $1}'`
update_file=`tail -n 1 ./.latest_version | awk '{print $2}'`
test -f ./.current_version
valid=$?
if [ "$valid" != "0" ]
	then
		echo It looks like this is an early version
		echo While the upgrade can run
		echo I am not sure how things will turn out
		echo Do you want to continue
		current_version=1
		echo y\/n
		read reply
		if [ "$reply" != "y" ]
			then
				exit 3
			else
				echo latest version is $version
						echo would you like to upgrade?
						echo y\/n
						read reply
							if [ "$reply" == "y" ]
								then
									echo getting "update.sh from https://googledrive.com/host/$update_file"
									wget -q --no-check-certificate -O./.update.sh https://googledrive.com/host/$update_file
									chmod 700 ./.update.sh
									./.update.sh
									echo $version >> ./.current_version
								else
									echo ok then I quit
									exit 2
							fi
		fi
	else
		 current_version=`tail -n 1 ./.current_version | awk '{print $1}'`
		 echo latest version is $version
                 echo you are on version $current_version
                 if [ "$current_version" -lt "$version" ]
                	 then
                            echo would you like to upgrade?
                            echo y\/n
                            read reply
                            if [ "$reply" == "y" ]
                               then
                                    echo getting "update.sh from https://googledrive.com/host/$update_file"
                                    wget -q --no-check-certificate -O./.update.sh https://googledrive.com/host/$update_file
                                    chmod 700 ./.update.sh
                                    ./.update.sh
                                    echo $version >> ./.current_version
                                else
                                    echo ok then I quit
                                    exit 2
                                fi
                                        else
                                                echo you are already on the latest version
		 fi
fi
