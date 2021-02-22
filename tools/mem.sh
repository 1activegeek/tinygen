SUM=0
for MEM in `ps -aux | awk '{print $11, $4}' | grep -v '0.0' | grep -v awk | awk '{print $2}' | grep -v M`
do
	#let SUM=$SUM+$MEM
	SUM=`echo $SUM+$MEM | bc`
#	echo $MEM
done
clear
echo Physical Memory
echo Total Memory Usage $SUM

