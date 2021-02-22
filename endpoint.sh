#!/bin/bash
domain=$1
user=$2	
passwd=$3
endpoint_share=`shuf -n 1 shares.txt`
endpoint=`echo $endpoint_share | awk -F "," '{print $1}'`
share=`echo $endpoint_share | awk -F "," '{print $2}'`
cd /usr/local/tinygen/emailfiles/endpoint
file=`ls | shuf -n 1`
clear > /tmp/endpoint.log
echo Last attempt was made>>/tmp/endpoint.log
date >> /tmp/endpoint.log
echo using endpoint `tput setaf 2`$endpoint`tput sgr0`>>/tmp/endpoint.log
echo using share `tput setaf 2`$share`tput sgr0`>>/tmp/endpoint.log
echo putting file `tput setaf 2`$file`tput sgr0`>>/tmp/endpoint.log
/opt/WCG/contrib/samba/bin/smbclient //$endpoint/$share -U $domain/$user%$passwd -c "put "$file"" 2>/tmp/endpoint.log.test
#smbclient //$endpoint/$share -U $domain/$user%$passwd -c "put "$file"" 2>/dev/null
sleep 5
/opt/WCG/contrib/samba/bin/smbclient //$endpoint/$share -U $domain/$user%$passwd -c "rm "$file"" 2>/dev/null
echo deleted file `tput setaf 2`$file`tput sgr0`>> /tmp/endpoint.log
