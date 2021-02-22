if [ "$1" == "report" ]
	then
		if [ "$2" == "detail" ]
			then
				clear
				echo Physical Memory
				cat ./mem.*PDT*
				echo press enter to contiune
				read x
				echo
				./swap_timed.sh report detail
			else
				clear
                                echo Physical Memory
                                cat ./mem.*PDT*
				echo press enter to continue
				read x
                                ./swap_timed.sh report 
		fi
	else
		./mem.sh
		echo '%MEM   COMMAND'
		ps -aux | awk '{print $4, $11}' | grep -v '0.0' | grep -v MEM | sort -rn
		
		echo
		echo
		echo Swap Memory
		./swap.sh
fi
