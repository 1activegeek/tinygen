#!/bin/bash
clear
echo Welcome to the endpoint application generator setup
test -f ../runit_ep.sh
if [ "$?" != "0" ]
then
#echo I need the username to retrieve the patch
#echo Please enter the username for `tput setaf 2`tinygen`tput sgr0` patches
#read user
#echo I need the password to retrieve the patch
#echo Please enter password \(entry will not be displayed\)
#read -s passwd
if [ ! -d "./patch" ]
	then
		echo making directories for update files
		mkdir ./patch
fi
cd ./patch
#wget ftp://$user:$passwd@transfer.technovoid.net/endpoint/endpoint.tar.gz
tar -xzvf /usr/local/tinygen/tools/patch/endpoint.tar.gz
if [ ! -d "../../emailfiles/endpoint" ]
	then
		echo creating endpoint file directory in ../../emailfiles
		mkdir ../../emailfiles/endpoint
		echo copying default files to ../../emailfiles/endpoint
		cp ./emailfiles/endpoint/* ../../emailfiles/endpoint
fi
echo Copying new files
cp ./rtm ../../
cp ./endpoint.sh ../../
cp ./doit ../../
cp ./ep_sleep_list ../../
echo now to clean up
echo removing files
rm ./rtm
rm ./doit
rm ./endpoint.sh
rm ./endpoint.tar.gz
rm ./shares.txt
rm ./ep_sleep_list
rm -r ./emailfiles
fi
echo OK now we have to set up your EndPoints and Shares
echo Please tell me the IP and Shares you want
echo Format: \<IP Address\>,Share Please note the \",\" seperator
echo I.E. 192.168.88.100,box
echo enter a \".\" on an empty line to exit entry mode
read reply
>../shares.txt
while [ "$reply" != "." ]
	do
		echo $reply >> ../shares.txt
		read reply
	done
#get user information
echo I need an Authentcation Domain
echo Enter a Domain name I.E. Domain1
read domain
echo I need a Domain user allowed to acces the shares
echo Enter a User Name
read user
echo I will need a password for this user
echo Enter Password
read passwd
#echo $user $passwd
echo setting user and password in ../runit_ep.sh
line=`grep \.\/endpoint.sh ../runit_ep.sh`
sed -i "s|$line|\/usr\/local\/tinygen\/endpoint.sh $domain $user $passwd|g" ../runit_ep.sh
echo Do you want to set the Endpoint Generator to auto-start? y\/n
read reply
if [ "$reply" == "y" ]
	then
		echo "/usr/local/tinygen/runit_ep.sh > \/dev/null 2>1 &" >> /etc/rc.d/rc.local
		echo OK I have set rc.local to auto-start Endpoint generator
		echo I recommend a reboot at this time
		echo Do you want to reboot? y\/n
		read reply
		if [ "$reply" == "y" ]
			then
				reboot
		fi 
	else
		echo OK, you can rune the endpoint_setup.sh script from tools dir
		echo OR add  "/usr/local/tinygen/runit_ep.sh > /dev/null 2>1 & "
		echo to the bottom of \/etc\/rc.d\/rc.local
fi
