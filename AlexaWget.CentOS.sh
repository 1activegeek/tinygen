#!/bin/bash
export TERM=linux
export DEAD=/dev/null
#  AlexaWget_protector.sh
#  Jim Brown
#  08/28/15
#  get the latest Alexa top 1M sites and format to use for traffic 
#  generation via wget
#  this script pownloads the list and will parse the file based upon 
#  numeric input
#  allowing for wget retrieval to generate traffic>
#  Intended for use with monitoring and security solutions

#modified for use with CentOS 5.X systems 9/17/2015
#added function "shuf" to approximate the shuf command which is not is the
#5.x CoreUtils repo

#Usage: AlexaWget.sh <Proxy:port> <Domain> <Distribution> <Lines>
#Example ./AlexaWget.sh 192.168.88.142:8080 Dlpdude20 r 1000
#The above will use the proxy at 192.168.88.142 using port 8080
#The Domain in this case is Dlpdude20. The "r" is for Random mode
#Modes
# eE <Even distribution of URLs from top and bottom of list>
# rR <Random distribution of URLs from list>
# tT <All URLs grabbed from top of list>
# bB <All URLs grabbed from bottom of list>
#
#NOTE:
#This script is reliant on a file called "users.txt in the running 
#Directory
#This file is used to randomly grab users and passwords for proxy
#(Legacy NTLM) authentication
#the format of this file is expected to be:
#  User:Password
in_odds=4
web_odds=4
mail_odds=4

#OK, Let's GOOOOOOOOOOOOOO
#A little cleanup form earlier runs
rm -f /tmp/transpired.*
rm -f /tmp/top-1m.csv

#Lets set the Install_Directory in case we need explicit paths
#INSTALL

if [ "$Install_Dir" = "" ]
	then
		clear
		echo it looks like set up has not been ran
		echo Please run setup.CentOS.sh and try again
		exit 5
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
#
#shuf for Centos-5.9 systems
#since shuf does not exist in all systems including the Websense Protector
#I have used the following function to approximate the shuf command
#
shuf () {
cat $3 | perl -MList::Util=shuffle -e 'print shuffle(<STDIN>);'>/tmp/shuf.list;head -n $2 /tmp/shuf.list
}
#Function to get the day of the week and set a weighting valu to be used a 
#  sleep delay in conjunction with an hourly weighting factor

calendar () {
#get day of week in numerical format 1-7 (1=Monday)
day_numerical=`date +"%u"`
#case $6 in
case $day_numerical in
	1)
		day=Monday
		day_multiplier=1
	;;
	2)
		day=Tuesday
		day_multiplier=1
	;;
	3)
		day=Wednesday
		day_multiplier=1
	;;
	4)
		day=Thursday
		day_multiplier=1
	;;
	5)	
		day=Friday
		day_multiplier=1
	;;
	6)
		day=Saturday
		day_multiplier=3
	;;
	7)
		day=Sunday
		day_multiplier=4
	;;
esac

#Get hour of day
hour=`date +"%H"`

case $hour in
	0[0-8]|1[7-9]|2[0-4])
		time_of_day=afterhours
		hour_multiplier=3
	;;
	*)
		time_of_day=worktime
		hour_multiplier=0
	;;
esac

#  Calculate a sleep multiplier to throttle the rate depending on day of
#  week and hour of day
sleep_multiplier=$(($day_multiplier + $hour_multiplier))

#Report the math being used as well as T.o.D. and day
echo $day
echo day multiplier is $day_multiplier
echo $time_of_day
echo hour multiplier is $hour_multiplier
echo adjusted sleep multiplier is $sleep_multiplier
}

clear
#Read Command Line Variables


#proxy=$1
domain=$2
distribution=$3
lines=$4
dlp=$5
#mta=$6
mail=$8
web=$7
inbound=$9

#add support for domain extension
domain_name=`echo $domain | awk -F"." '{$NF=""; print $0}'| sed s'/ /./g'`
auth_domain_name=`echo $domain | awk -F"." '{print$1}'`
domain_extension=`echo $domain | awk -F"." '{print $NF}'| sed s'/ //g'`
credentials=`shuf -n 1 $Install_Dir/users.txt`
user=`echo $credentials|awk -F":" '{print $1}'`
pass=`echo $credentials|awk -F":" '{print $2}'`

# clear and create log files
>/tmp/Alexa_Sizes
>/tmp/email.out
echo Blocked URLs > /tmp/blockedlist
echo Allowed URLs > /tmp/allowedlist

urlsdottxt=`test -f /usr/local/tinygen/urls.txt; echo $?`
echo $urlsdottxt > /usr/local/tinygen/huh
if [ "$urlsdottxt" == "0" ]
then 
echo using urls.txt >>/tmp/runit.log
                num_lines=`wc -l /usr/local/tinygen/custom_urls.txt | awk '{print $1}'`
                num_runit=`grep AlexaWget /usr/local/tinygen/runit.CentOS.sh | awk '{print $5}'`
                echo num_lines is $num_lines
                echo num_runit is $num_runit
                if [ "$num_lines" -ge "$num_runit" ]
                        then
                                echo more lines in file than selected in runit#> /tmp/custom_results
                                shuf -n $num_runit /usr/local/tinygen/custom_urls.txt > /usr/local/tinygen/urls.txt
                        else
                                echo "number of lines is equal to or less than number of lines in runit" > /tmp/custom_results
                                cp /usr/local/tinygen/custom_urls.txt /usr/local/tinygen/urls.txt
                fi

else
echo Downloading the latest Alexa list from:
echo http://s3.amazonaws.com/alexa-static/top-1m.csv.zip
echo using user $user and password '********' #$pass

#Go Fetch the CSV file
#adddedline below for t-shooting 5/1/17
pid=$$
wget -q -O/tmp/alexa.$pid http://s3.amazonaws.com/alexa-static/top-1m.csv.zip

#Open, decompress, and format the CSV for use and create tmp/top-1m
echo Unzipping alexa.$pid
unzip /tmp/alexa.$pid -d /tmp
echo Formatting /tmp/top-1m.csv
cat /tmp/top-1m.csv | awk -F '[,]' '{print $2}' > top-1m.txt
#cp /usr/local/tinygen/urls.txt /tmp/top-1m.txt
fi

# get the number of lines and format seed file
#check for even input. if not even, increment by 1 to produce even division
if [ $(($lines % 2)) -eq 0 ]
	then
		corrected_lines=$lines
	else
		corrected_lines=`expr $lines + 1`
fi

#get the lines and build an input file

echo I will grab $corrected_lines URLs from Alexa List
sleep 3
case $distribution in
  [eE])
		#Split the number
		mode='Even Distribution'
		divided_lines=`expr $corrected_lines / 2`
		echo There will be $divided_lines URLs from the top and $divided_lines URLs from the bottom of the list
		sleep 3
		head -n $divided_lines top-1m.txt > $Install_Dir/myurls.txt
		tail -n $divided_lines top-1m.txt >> $Install_Dir/myurls.txt
		;;
  [rR])
		mode=Random
		echo There will be $corrected_lines URLs randomly pulled from the list
		sleep 3
		shuf -n $corrected_lines top-1m.txt > $Install_Dir/myurls.txt
        ;;
  [tT])
		mode=Top
		echo There will be $corrected_lines URLs from the top of the list 
		sleep 3
		head -n $corrected_lines top-1m.txt > $Install_Dir/myurls.txt
        ;;
  [bB])
		mode=Bottom
		echo There will $corrected_lines URLs from the bottom of the list
		sleep 3
		tail -n $corrected_lines top-1m.txt > $Install_Dir/myurls.txt
		;;

  *)
		echo invalid Distribution option $distribution
		echo Please enter E, R, T, or B 
		sleep 3
		exit 0
		;;
esac
#Clean up
rm /tmp/top-1m.csv
rm /tmp/alexa.$pid
#rm $Install_Dir/top-1m.txt


#initialize URL counter to 1
count=1
#initialze pxy_mode to nothing
pxy_mode="0"
#Initialize badreq to 0
badreq=0
#Initialize notacc to 0
notacc=0
#Initialize serverr to 0
serverr=0
#Initialize badgwy to 0
badgwy=0
#Initialize svcunv to 0
svcunv=0
#Initialize reqden to 0
reqden=0
#initialize noname to 0
noname=0
#initialize forbidden to 0
forbidden=0
#initialize 404 to 0
notfound=0
#initialize auth to 0
auth=0
#initialize unretrieved counter to 0
unretrieved=0
#initialize mail_count to 0
mail_count=0
if [ "$urlsdottxt" == "0" ]
then
input_file=$Install_Dir/urls.txt
url_total=`wc -l<$input_file`
echo urls.txt >> /usr/local/tinygen/huh
else
input_file=$Install_Dir/myurls.txt
url_total=`wc -l<$input_file`
echo myurls.txt >> /usr/local/tinygen/huh
fi

echo input file = $input_file
# read list of Alexa URLS
for urls in `cat $input_file`
	do
		clear
if [ "$1" != "nopxy" ]
	then
		echo Running in Proxy Mode Using Proxy $1
	else
		echo Running in No Proxy Mode Going Direct
fi
		calendar
		urls_left=`expr $url_total - $count`
		echo THIS IS URL NUMBER $count OF $url_total
		echo ONLY $urls_left URLS LEFT
		average=`grep -v "Allowed URLs" /tmp/allowedlist | awk '{ total += $3; count++ } END { print  total/count }' `
		#average=`awk '{ total += $3; count++ } END { print  total/count }' /tmp/allowedlist`
	if [ "$count" -ne "0" ]
		then
			samples=`wc -l /tmp/Alexa_Sizes | awk '{print $1}'`
			echo out of $samples samples the average Transaction size has been $average Bytes
	fi

#get filesize to report un-retrieved pages (0 filesize)
#Get filsize for details
size=`ls -l /tmp/page.txt | awk '{print $5}'`

if [ "$size" -eq "0" ]
        then
		zero=true
		unretrieved=$(($unretrieved+1))	
fi

#adding number blocked and number allowed
allowed=`grep \.\.allowed /tmp/allowedlist |wc -l`
blocked=`grep blocked /tmp/blockedlist | wc -l`
if [ "$unretrieved" -ne "0" ]
	then
		tput smso
		tput setaf 3
	else
		tput smso
		tput setaf 2
fi
echo there have been $unretrieved Unretrieved pages \(zero-size\)
tput sgr0
clientside=$(($badreq + $forbidden + $notfound + $notacc + $auth))
if [ "$clientside" -ne "0" ]
        then
                tput smso
                tput setaf 3
        else
                tput smso
                tput setaf 2
fi
echo $clientside Client Side errors were
echo $badreq - 400, $forbidden - 403, $notfound - 404, $notacc - 406, $auth - 407
tput sgr0
echo
serverside=$(($serverr + $badgwy + $svcunv + $noname + $reqden))
if [ "$serverside" -ne "0" ]
        then
                tput smso
                tput setaf 3
	else
		tput smso
		tput setaf 2
fi

echo $serverside Server Side errors were
echo $serverr - 500, $badgwy - 502, $svcunv - 503, $noname - 504, $reqden - 999
tput sgr0
#echo there were $noname Name Resolution, $forbidden Forbidden, $auth Authentication, and $notfound 404 errors
unknown=$(($unretrieved - ($badreq + $forbidden + $notfound + $notacc + $auth + $serverr + $badgwy + $svcunv + $noname + $reqden)))
echo
if [ "$unknown" -ne "0" ]
        then
                tput smso
                tput setaf 3
	else
		tput smso
		tput setaf 2
fi

echo there were $unknown Unknown errors
tput sgr0
echo
echo there have been $allowed pages Retrieved
echo there have been $blocked pages Blocked
tput smso
tput setaf 2
echo getting $urls
tput sgr0


#seed and calculate sleep time
sleep_time=`shuf -n 1 $Install_Dir/sleep_list`
adjusted_sleep=$(($sleep_multiplier * $sleep_time))
count=`expr $count + 1`

#Get user and password form users.txt
credentials=`shuf -n 1 $Install_Dir/users.txt`
user=`echo $credentials|awk -F":" '{print $1}'`
pass=`echo $credentials|awk -F":" '{print $2}'`
#echo using user $auth_domain_name\\$user and password '*******' #$pass #DEBUG Remove the comment prior to $pass to display password being used

#Set Proxy and user variables for use by Wget

for proxies in `cat $Install_Dir/proxies.txt`
  do
	if [ "$1" != "nopxy" ]
		then
			export alt_domain=`echo $proxies | awk -F "," '{print $2}'`
			#echo alt domain is $alt_domain
			if [ "$alt_domain" != "" ]
			then
			export proxy=`echo $proxies | awk -F "," '{print $1}'`
			#echo $proxy
			#echo alt_domain is $alt_domain
			export http_proxy=http://$user%40$alt_domain:$pass@$proxy
			export https_proxy=https://$user%40$alt_domain:$pass@$proxy
			pxy_mode=Proxy
			echo Using Proxy $proxy and alternate domain user $user\@$alt_domain
			else
			export proxy=`echo $proxies | awk -F "," '{print $1}'`
                        export http_proxy=http://$auth_domain_name\\$user:$pass@$proxy
                        export https_proxy=https://$auth_domain_name\\$user:$pass@$proxy
                        pxy_mode=Proxy
                        echo Using Proxy $proxy and NO alternate domain 
			fi

			pxy_mode=NoProxy
fi

#Time to fetch the page
interface=`shuf -n 1 $Install_Dir/interfaces.txt`
echo using interface with IP Address $interface
start=`date +%s`
if [ "$proxy" == nopxy ] || [ "$proxy" == "dnsdummy" ]
	then 
		export http_proxy=""
		export https_proxy=""
		wget -t 1 --timeout=10 -O/tmp/pagenopxy.txt $urls --no-check-certificate --bind-address $interface 2>/tmp/wget_stderror
		cp /tmp/pagenopxy.txt /tmp/page.txt
		#wget -t 1 --timeout=10 -O/tmp/page.txt $urls --no-check-certificate --bind-address $interface 2>/tmp/wget_stderror
	else
		wget -t 1 --timeout=10 -O/tmp/page.txt $urls --no-check-certificate --bind-address $interface 2>/tmp/wget_stderror
fi
finish=`date +%s`
transpired=`echo $(($finish - $start))`
echo it took $transpired seconds for this retrieval
echo $transpired >> /tmp/transpired.$proxy

sleep 1
grep -i mailcontrol /tmp/page.txt | awk -F ">" '{print $2}' | awk -F "<" '{print $1}'

sleep 1
  done


######### IF EMAIL OPTION SPECIFIED, SEND EMAIL \(I HOPE\)

if [ "$dlp" == "dlp" ]
	then
		dlp_speed=`tail -n 1 $Install_Dir/dlp_speed.txt`
			echo "Mail Count before if $mail_count" > /tmp/mailcount
		if [ "$mail_count" -ge "$dlp_speed" ]
			then
			echo "Mail Count after if $mail_count" >> /tmp/mailcount
			ls $Install_Dir/emailfiles/attachments > $Install_Dir/files.txt
			email_file=`shuf -n 1 $Install_Dir/files.txt`
			to_domain=`shuf -n 1 $Install_Dir/emailfiles/header/domains.txt`
			to_user=`shuf -n 1 $Install_Dir/emailfiles/header/recipients.txt`
			subject=`shuf -n 1 $Install_Dir/emailfiles/header/subject.txt`
			email_body=`shuf -n 1 $Install_Dir/bodies.txt`
			ls -a $Install_Dir/emailfiles/bodies | grep "..."> $Install_Dir/bodies.txt
		#fix to reset mail_count 03_24_17
		mail_count=0

		if [ "$mail" == "y" ]
			then
			mail_odds=`shuf -n 1 $Install_Dir/mail_odds.txt`
			echo The MAIL Die rolled a $mail_odds
			echo mail count and dlp count say to roll the die  >> /tmp/mailcount
			echo mail die rolled a $mail_odds >> /tmp/mailcount
			   if [ "$mail_odds" == "1" ]
			     then
				for mta in `cat /usr/local/tinygen/mta.txt`
				do
				echo mail from $user
				echo emailing to $to_user\@$to_domain using subject $subject and MTA $mta
				echo Mailing $email_file
                		echo Using Body $email_body
                		tput sgr0
				tput sgr0
				echo mailx start
				date | awk '{print $1, $2, $3, $4}'
				mailx -S smtp=$mta -a "$Install_Dir/emailfiles/attachments/$email_file" -r $user@$domain_name$domain_extension -s "$subject $email_file" -v $to_user@$to_domain  < $Install_Dir/emailfiles/bodies/$email_body > /tmp/mailedit_OUT.txt 2>&1 
				echo mailx stop
				date | awk '{print $1, $2, $3, $4}'
				done
				
				mail_count=0
			echo "Mail Count after reset $mail_count" >> /tmp/mailcount
#Change to have email write to /tmp/email.out for use in email function 
#Real TIme Monitoring (rtm)
				tail -n 8 /tmp/runit.log >> /tmp/email.out
			   fi
		fi
		if [ "$web" == "y" ]
			then
                        web_odds=`shuf -n 1 $Install_Dir/web_odds.txt`
                        echo The WEB Die rolled a $web_odds
			echo mail count and dlp count say to roll the die  >> /tmp/mailcount
			echo web die rolled a $web_odds >> /tmp/mailcount
                           if [ "$web_odds" == "1" ]
                             then
				#HTTPS POST
				#Get Post data for HTTP(S) post
				ls $Install_Dir/emailfiles/postdata > $Install_Dir/post_files.txt
				export Post_File=`shuf -n 1 $Install_Dir/post_files.txt`
				export Post_Data=`cat /$Install_Dir/emailfiles/postdata/$Post_File`
for post_proxy in `cat /usr/local/tinygen/proxies.txt`
do
                        export https_proxy=https://$auth_domain_name\\$user:$pass@$post_proxy
				#site=`shuf -n 1 /usr/local/tinygen/emailfiles/postdata/risky_domains.txt`
				 site=dlpdude.com
				echo Posting From $Post_File #$Post_Data
				echo Posting to $site
				echo using proxy $post_proxy 
#				wget -q -O/dev/null --no-check-certificate --post-data="$Post_Data" https://$site >/dev/null
				wget -q -O/dev/null --no-check-certificate --post-data="$Post_Data" https://dlpdude.com/display-datap.asp>/dev/null
done
			   fi
		fi
			else
				mail_count=$[mail_count + 1]

	fi
fi
# Get exit status and try to make sense of it
wget_exit_status=`grep "ERROR" /tmp/wget_stderror | awk -F "ERROR" '{print $2}' | awk -F ":" '{print $1}'`
case $wget_exit_status in
#get errors
#Client Side Errors
	" 400")
		badreq=$(($badreq + 1))
	;;
	" 403")
		forbidden=$(($forbidden+1))
	;;
        " 404")
                notfound=$(($notfound + 1))
        ;;
	" 406")
		notacc=$(($notacc + 1))
	;;
	" 407")
		auth=$(($auth +1))
		echo $wget_exit_status $urls $user $pass >> /tmp/auth_error
		#echo $user >> /tmp/407 ## Remove the leading "#" 
		#to redirect errors for debug
	;;
#Server Side Errors
	" 500")
		serverr=$(($serverr + 1))
	;;
	" 502")
		badgwy=$(($badgwy + 1))
	;;
	" 503")
		svcunv=$(($svcunv + 1))
	;;
	" 504")
		noname=$(($noname + 1))
	;;
	" 999")
		reqden=$(($reqden + 1))
	;;
	"")
	;;
        *)
                echo $wget_exit_status $urls >> /tmp/odd_exit
        ;;
esac

#echo wget exit status=$wget_exit_status

#For Security, change mode of download file to read only (root)
chmod 400 /tmp/page.txt

size=`ls -l /tmp/page.txt | awk '{print $5}'`

#the following line is a static URL and is used to force a block page 
#for the Sex category. remove the comment and comment out the line below to use
#wget -q -t 1 --timeout=10 -O/tmp/page.txt http://www.porn.com --no-check-certificate #DEBUG

#find out if I was blocked by websense and then the category
if  grep -q logo_block_page /tmp/page.txt
	then
		Block_Reason_Url=`grep "block_message" /tmp/page.txt | awk -F"\"" '{print $2}'`
		wget -q -t 1 --timeout=10 -O/tmp/block_reason $Block_Reason_Url --no-check-certificate
		reason=`cat /tmp/block_reason | grep -i reason| grep first-option | awk -F">" '{print $2}' | awk -F"<" '{print $1}'`

		tput smso
		tput setaf 1
			echo $reason 
		tput sgr0
		echo "For the URL below, User=$user" >> /tmp/blockedlist
		echo -e  $urls '\t'$reason >> /tmp/blockedlist
# Find out if file was not retireved (zero size) and report
	else
		if [ "$size" -eq "0" ]
			then
				tput smso
				tput setaf 1
				echo Page Not Retrieved
				echo $wget_exit_status
				tput sgr0
			else
				tput smso
				tput setaf 2
				echo Page Retrieved
				echo "..allowed $urls $size" >> /tmp/allowedlist
				size=`ls -l /tmp/page.txt | awk '{print $5}'`
				echo filesize=$size
				echo $size >> /tmp/Alexa_Sizes
				tput sgr0
		fi	
		#
		#cp /tmp/page.txt /tmp/allowed/$urls   #DEBUG uncomment these lines to save source of files retrieved. INTENDED WHEN ZERO ALLOWS ARE EXPECTED
		#echo filesize=$size>>/tmp/allowedlist #DEBUG uncomment these lines to save source of files retrieved. INTENDED WHEN ZERO ALLOWS ARE EXPECTED
		#
fi
#
#Generate inbound email if selected

if [ "$inbound" == "y" ]
	then
		in_odds=`shuf -n 1 $Install_Dir/inbound_odds.txt`
		echo The INBOUND Die rolled a $in_odds
		if [ "$in_odds" == "1" ]
			then
				to_domain=`shuf -n 1 $Install_Dir/emailfiles/header/domains.txt`
				ls $Install_Dir/emailfiles/attachments > $Install_Dir/files.txt
				email_file=`shuf -n 1 $Install_Dir/files.txt`
                        	to_user=`shuf -n 1 $Install_Dir/emailfiles/header/recipients.txt`
                        	subject=`shuf -n 1 $Install_Dir/emailfiles/header/subject.txt`
                        	ls -a $Install_Dir/emailfiles/spam | grep "..."> $Install_Dir/spam.txt
                        	email_body=`shuf -n 1 $Install_Dir/spam.txt`

#attempt2 at multiple MTAs
for mta in `cat /usr/local/tinygen/mta.txt`
do
                                echo emailing to $user\@$domain_name$domain_extension using subject $subject and MTA $mta
                                echo Mailing $email_file
                                echo Using Body $email_body
                                tput sgr0
                                tput sgr0
                                echo mailx start
                                mailx -S smtp=$mta -a "$Install_Dir/emailfiles/attachments/$email_file" -r $to_user@$to_domain -s "$subject $email_file" -v $user@$domain_name$domain_extension  < $Install_Dir/emailfiles/spam/$email_body > /tmp/mailedit_inbound.txt 2>&1
echo sender is $to_user
echo sender domain is $to_domain
                                echo mailx stop
done
#Change to have email write to /tmp/email.out for use in email function
#Real TIme Monitoring (rtm)
                                tail -n 8 /tmp/runit.log >> /tmp/email.out

                           fi
                fi

currywurst=$(($in_odds + $web_odds + $mail_odds))
if [ "$currywurst" == "3" ]
	then
		/bin/cu >> /tmp/runit.log
fi
echo sleeping $adjusted_sleep
web_odds=4
in_odds=4
mail_odds=4
sleep $adjusted_sleep

#clear log file for space reduction
>/tmp/runit.log
done
#rm $Install_Dir/input_file
clear
echo Finished fetching $corrected_lines URLs in $mode mode
cp /tmp/blockedlist /tmp/blockedlist.lastrun

