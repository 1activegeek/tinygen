tail=`ps -e | grep tail`
echo killing $tail
pid=`echo $tail | awk '{print $1}'`
kill -9 $pid
