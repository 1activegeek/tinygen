while [ "$reply" != "q" ]
do
#get user guess
clear
echo Welcome to Tiny-Roller
echo `tput setaf 2` IT ONLY MAKES SENSE THAT IT WOULD BE A `tput setaf 1` DICE `tput setaf 2` GAME `tput sgr0`
echo what do you think it will be \(1-6\)
read human
if [[ "$human" =~ ^[0-9]+$ ]] && [ "$human" -ge 1 -a "$human" -le 6 ] 
then
#pick computer number and make sure computer will not pick same number as human
computer=$human
while [ "$computer" == "$human" ]
do
computer=`seq 6 | shuf -n 1`
done

echo computer guesses $computer
#tumbles=`seq 50 | shuf -n 1` 
seq 30 > /tmp/tumbles
tumbles=`tail -n 20 /tmp/tumbles | shuf -n 1`
sleep 1
turns=0
while [ "$turns" != "$tumbles" ]
do
	sleep .09
	turns=`expr $turns + 1`
clear
count=0
tput civis
while [ "$count" != "1" ]
	do
		tput cup 4 0
		count=`expr $count + 1`
		die=`seq 6 | shuf -n 1`
		if [[ "$reply" =~ ^[0-9]+$ ]] && [ "$reply" -ge 1 -a "$reply" -le 6 ]
			then
				if [[ "$turns" -ge $(($tumbles-1)) ]]
					then
						die=$reply
				fi
		fi

	done
clear
case $die in
	1) tput setaf 1
echo "   
 O 
   "
;;
	2) tput setaf 2
echo "O  
   
  O"
;;
	3) tput setaf 3
echo "O  
 O 
  O"
;;
	4) tput setaf 4
echo "O O
   
O O"
;;
	5) tput setaf 5
echo "O O
 O 
O O"
;;
	6) tput setaf 6
echo "O O
O O
O O"
;;
*)
echo something else
;;
esac
done
echo
echo LOOKS LIKE A $die TO ME
echo you guessed $human
if [ "$die" == "$human" ]
	then
		tput setaf 2
		echo YOU ARE PSYCHO
		tput sgr0
		echo
	else
		echo
fi
echo computer guessed $computer
if [ "$die" == "$computer" ]
        then
		tput setaf 2
                echo I was right and NO I DID NOT CHEAT
		tput sgr0
		echo
	else
		echo
fi

else
	echo "Enter a number 1-6"
fi
echo press enter to play again or enter q to quit
tput setaf 0
read reply
tput setaf 7
tput cnorm
done
