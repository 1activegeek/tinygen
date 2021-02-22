function getit {
for files in `ls -rtl | grep swap | grep -v sh| awk '{print $9}'`
        do
                echo "**<< $files >>**"
                cat $files | more
                echo
        done
}
clear
stamp=`date | sed 's/:/./g'| sed 's/ /_/g'`
if [ "$1" == "report" ]
	then
		echo Swap Memory
		if [ "$2" == "detail" ]
			then
				getit
			else
				getit | grep -v Swap #overall 
		fi
	else
		if [ "$1" == "loop" ]
			then
				count=1
				while true
					do
						stamp=`date | sed 's/:/./g'| sed 's/ /_/g'`
						clear
						echo looping
						echo this is loop number $count
						./swap.sh | grep -v " 0 " > swap.$stamp

						sizes1=0
						for sizes in `cat swap.$stamp | awk '{ print $5 }'`
							do
							total=$(($sizes1 + $sizes))
							sizes1=$total
							echo $total
							done
						echo Total $total >> swap.$stamp
						count=$(($count + 1))
						sleep 1800
					done
			else
				./swap.sh | grep -v " 0 " > swap.$stamp

				sizes1=0
				for sizes in `cat swap.$stamp | awk '{ print $5 }'`
				 do #echo $sizes
				 total=$(($sizes1 + $sizes))
				 sizes1=$total
				 echo $total
				 done
				echo Total $total >> swap.$stamp
				tail -n 1 swap.*PDT*
		fi
fi
