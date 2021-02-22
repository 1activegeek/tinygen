#!/bin/bash
#backup environment for user settings
clear
echo You can store to the following shares or locally
cat shares.txt
echo where would you like to store you backup\?
read location
endpoint=`echo $location | awk -F ',' '{print $1}'`
share=`echo $location | awk -F ',' '{print $2}'`

echo enter domain for share $location
read domain

echo enter user for $domain
read user

echo enter password for $user
read passwd

file=tg-backup.`date | awk '{print $1, $2, $3}' | sed 's/ /_/g'`.tar.gz
 tar -czvf $file ep_sleep_list dlp_speed.txt  endpoint.sh  inbound_odds.txt  interfaces.txt  mail_odds.txt  proxies.txt  runit.CentOS.sh runit_ep.sh shares.txt sleep_list users.txt web_odds.txt /etc/rc.d/rc.local
test -f tools

if [ -d "tools" ]
	then
		mv tg-backup* tools
	else
		echo saving to `pwd`/tg-backup.`date | awk '{print $1, $2, $3}' | sed 's/ /_/g'`.tar.gz
fi
#smbclient //$endpoint/$share -U $domain/$user%$passwd -c "put "$file"" 2>/dev/null
smbclient //$endpoint/$share -U $domain/$user%$passwd -c "put "$file"" 2>/dev/null 
smbclient //$endpoint/$share -U $domain/$user%$passwd -c "put "$file"" 2>/dev/null 
