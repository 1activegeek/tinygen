SUM=0
#clear

               if [ "$1" == "loop" ]
                        then
                                count=1
                                while true
                                        do
                                                stamp=`date | sed 's/:/./g'| sed 's/ /_/g'`
                                                clear
                                                echo looping
                                                echo this is loop number $count
						for MEM in `ps -aux | awk '{print $11, $4}' | grep -v '0.0' | grep -v awk | awk '{print $2}' | grep -v M`
							do
							        SUM=`echo $SUM+$MEM | bc`
							done
				echo $stamp > /usr/local/tinygen/tools/mem.$stamp
				echo Total Memory Usage $SUM >> /usr/local/tinygen/tools/mem.$stamp
                                                count=$(($count + 1))
						SUM=0
                                                sleep 1800
                                        done
			else
                                                stamp=`date | sed 's/:/./g'| sed 's/ /_/g'`
                                                for MEM in `ps -aux | awk '{print $11, $4}' | grep -v '0.0' | grep -v awk | awk '{print $2}' | grep -v M`
                                                        do
                                                                SUM=`echo $SUM+$MEM | bc`
                                                        done
                                echo Total Memory Usage $SUM >> /usr/local/tinygen/tools/mem.$stamp
				echo Results written to mem.$stamp




                fi


