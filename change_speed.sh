#!/bin/bash
#
# A script to change the DLP Incident Generation attenpt rate for tiny-gen
#
usage() {
echo "Usage: change_speed.sh <mode> <integer>
       change_speed.sh <show>
       change_speed.sh <reset>

modes are (m)ail  (p)ost  (d)lp  (w)eb  (i)nbound   (show)  (reset)
(m)ail will generate a list of die numbers to be used when throwing the email die
(p)ost will generate a list of die numbers to be used when throwing the web die
(d)lp will change the number of urls that the incident generation will wait
(W)eb will generate a list of numbers used to calculate randomish sleep times between url retrieval for AP-Web Traffic
(i)nbound will generate a list of die numbers to be used when throwing the inbound email die
(show) will show the current speed configurations
(reset) will set factory defaults for normal speed

examples
./change_speed.sh m 3 (generate a list of possible die numbers for email 1-3   1=Always)

./change_speed.sh p 3 (generate a list of possible die numbers for web 1-3   1=Always)

./change_speed.sh d 1 (generate dlp attempts every other url retrieved by tiny-gen   0=Always)

./change_speed.sh w 5 (generate sleep list used to throttle url retrieval by tiny-gen   0=No Multiplier)

./change_speed.sh show (show the current speed configurations)

./change_speed.sh reset (reset to factory configurations)
"
show noclear
}
#
show(){
        if [ "$1" == "" ]
		then
			clear
	fi
	echo Current Configuration:
        echo HTTPS post odds are now 1 in `tail -n 1 ./web_odds.txt` \(web_odds.txt\)
        echo outbound email odds are now 1 in `tail -n 1 ./mail_odds.txt` \(mail_odds.txt\)
        echo inbound email odds are now 1 in `tail -n 1 ./inbound_odds.txt` \(inbound_odds.txt\)
        echo "dlp speed is now every `cat ./dlp_speed.txt` URLs" \(dlp_speed.txt\)
        echo Web Traffic sleep pool is now `head -n 1 ./sleep_list` thru `tail -n 1 ./sleep_list` \(sleep_list\)
}
# first lets see if we only want to see the current configuration and quit if so
#
if [ "$1" == "show" ]
then
	show
	exit 0
fi
if [ "$1" == "reset" ]
then
	clear
	echo 1 > mail_odds.txt
        echo 2 >> mail_odds.txt
        echo 3 >> mail_odds.txt
	echo 1 > inbound_odds.txt
        echo 2 >> inbound_odds.txt
        echo 3 >> inbound_odds.txt
        echo 1 > web_odds.txt
        echo 2 >> web_odds.txt
        echo 3 >> web_odds.txt
	echo 99 > dlp_speed.txt
	echo 1 > sleep_list
	echo 2 >> sleep_list
	echo 3 >> sleep_list
	echo 4 >> sleep_list
	echo 5 >> sleep_list
	show

	exit 0
fi
#hidden switch for full generation and no delay
if [ "$1" == "allsystemsgo" ]
then
        clear
        echo 1 > mail_odds.txt
        echo 1 > inbound_odds.txt
        echo 1 > web_odds.txt
        echo 0 > dlp_speed.txt
        echo 0 > sleep_list
        show

        exit 0
fi


#
#if we did not want to show the config then we must want to change something
#making sure we have the arguments starting at the end and moving in to $0
#
case $2 in
"") usage | more
exit 2;;
esac

#
#looks like we evalutated OK with the $2 argument
#lets see what to change and what to change it too
#
case $1 in 
w)
if [ "$2" != "0" ]
	then
		export web=1
		> ./sleep_list
        	while [ "$web" -le "$2" ]
        		do
                		echo $web >> sleep_list
                		web=$(($web + 1))
        		done
	else
		echo 0 > sleep_list
fi
echo Web Traffic speed pool is now `head -n 1 ./sleep_list` thru `tail -n 1 ./sleep_list`
;;
	
p) 
export web=1
> ./web_odds.txt
	while [ "$web" -le "$2" ] 
	do
		echo $web >> web_odds.txt
		web=$(($web + 1))
	done
echo post odds are now 1 in `tail -n 1 ./web_odds.txt`
;;
m) 
export mail=1
> ./mail_odds.txt
        while [ "$mail" -le "$2" ]
        do
                echo $mail >> mail_odds.txt
                mail=$(($mail + 1))
        done
echo mail odds are now 1 in `tail -n 1 ./mail_odds.txt`

;;
i)
export inbound=1
> ./inbound_odds.txt
        while [ "$inbound" -le "$2" ]
        do
                echo $inbound >> inbound_odds.txt
                inbound=$(($inbound + 1))
        done
echo inbound odds are now 1 in `tail -n 1 ./inbound_odds.txt`

;;

d) echo $2 > dlp_speed.txt
echo "dlp speed is now every `cat ./dlp_speed.txt` URLs";;
*) usage | more;;
esac
