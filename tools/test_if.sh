#!/bin/bash
clear
file=$1
proxys=$2
option=$3
if [ "$4" != "" ]
	then
		url=$4
	else
		url=www.forcepoint.com
fi
test -f $file
if [  "$?" != "0" ]
	then
		tput setaf 1
		tput bold
		tput smso
		echo input file \"$file\" was not found. EXITING
		tput sgr0
		exit 2
fi
function failed {
if [ "$option" == "" ]
  then
	if [ "$failed" == "1" ]
		then
			echo One or more tests have failed
			echo would you like to continue?
			echo enter y/n
			read reply
			if [ "$reply" == "n" ]
				then
					exit 0
			fi
	fi
fi
}
#Test Localhost
function localhost {
		echo TESTING LOCALHOST TO EACH INTERFACE 
		for ips in `cat $file | grep .......*| awk -F "/" '{ print $1}'`
do
		echo testing ping to IP $ips
		ping -c 1 $ips > /dev/null
		success=$?
        	#sleep 1
		if [ "$success" == "0" ]
			then
			tput setaf 2
                        echo SUCCESS
                        tput sgr0
                else
                        tput setaf 1
                        echo FAILED
			failed=1
                        tput sgr0
        fi
done
failed
echo
}

#test from each interface to gateway
#get Gateway
function lan {
		gateway=$(/sbin/ip route | grep default | awk '/default/ { print $3 }')
		echo TESTING FROM EACH INTERFACE TO GATEWAY $gateway
                for ips in `cat $file | grep .......*| awk -F "/" '{ print $1}'`
do
                echo testing from IP $ips to $gateway
                ping -c 1 -I $ips $gateway> /dev/null
                success=$?
                #sleep 1
                if [ "$success" == "0" ]
                        then
                        tput setaf 2
                        echo SUCCESS
                        tput sgr0
                else
                        tput setaf 1
                        echo FAILED
			failed=1
                        tput sgr0
        fi
done
failed
echo
}

function proxy {
echo TESTING FROM EACH INTERFACE TO EACH PROXY 
for ips in `cat $file | sort`
do
        for proxies in `cat $proxys | awk -F":" '{print $1}' | grep -v nopxy | grep -v dnsdummy`
do
        echo pinging from $ips to $proxies
        ping -c 1 -I $ips $proxies > /dev/null
        if [ "$?" == "0" ]
		then
                        tput setaf 2
                        echo SUCCESS
                        tput sgr0
                else
                        tput setaf 1
                        echo FAILED
                        failed=1
                        tput sgr0

        fi
done
done
failed
echo
}

#Test WAN
function wan {
                echo TESTING WAN TO $url
                #echo TESTING WAN TO $url
		> /tmp/test_if_wan
                for ips in `cat $file | grep .......*| awk -F "/" '{ print $1}'`
do
                echo testing wget from IP $ips to $url
                #echo testing wget from IP $ips to www.forcepoint.com
                #ping -c 1 -I $ips websense.com> /dev/null
		echo $ips >> /tmp/test_if_wan
		wget -O/dev/null --tries=1 --timeout=5 --bind-address $ips $url >> /tmp/test_if_wan 2>>/tmp/test_if_wan
		#wget -O/dev/null --tries=1 --timeout=5 --bind-address $ips com >> /tmp/test_if_wan 2>>/tmp/test_if_wan
                success=$?
                #sleep 1
                if [ "$success" == "0" ]
                        then
                        tput setaf 2
                        echo SUCCESS
                        tput sgr0
                else
                        tput setaf 1
                        echo FAILED
			failed=1
                        tput sgr0
        fi
done
}
if [ "$file" != "" ] 
then
case $option in
localhost )
	localhost
	;;
lan )
	lan
	;;
wan )
	wan
	;;
proxy)
	proxy
	;;
*)
	localhost
	lan
	proxy
	wan
	;;
esac
        else
                echo USAGE: test_if.sh \<path/file\> \<Option\>
		echo '<path>/file is required.'
		echo
		echo 'the file should be a list of IP Addresses to verify'
		echo 'the format of IP Addresses should be as follows'
		echo '192.168.88.100    OR    192.168.88.100/24'
		echo '192.168.88.101    OR    192.168.88.101/24'
		echo
		echo Options:
		echo '	localhost (ping localhost to interface)'
		echo '	lan (ping interface to gateway)'
		echo '	wan (ping interface to websense.com)'
		echo ' no options will run all three options in the order above'
		echo
                echo I.E. test_if.sh ../interfaces.txt wan
                echo I.E. test_if.sh ../interfaces.txt
		echo

fi

