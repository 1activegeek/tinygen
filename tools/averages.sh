#!/bin/bash
if [ "$1" == "" ]
then
echo usage: averages.sh \<nnn\> where nnn \= URL number to stop on
exit 1
fi

#find out if we exceed the number of urls retrieved by Alexa script
Alexa_count=`grep Alex ../runit.CentOS.sh | awk '{print $5}'`
if [ "$1" -gt "$Alexa_count" ]
then
echo count is higher than the number of urls in the Alexa run which is $Alexa_count
exit 2
else
while [ "$count" != "$1" ]
do
clear
for proxies in `cat ../proxies.txt| awk -F "," '{print $1}'`
do
average=`cat /tmp/transpired.$proxies | awk '{ total += $1; count++ } END { print  total/count }'`
count=`cat /tmp/transpired.$proxies | wc -l`
echo "average retrieval time for $count URL's using `echo $proxies` 
$average seconds"
done
sleep 5
done

#write final results to file specified as second command line argument?
if [ "$2" != "" ]
then
>$2
for proxies in `cat ../proxies.txt`
do
average=`cat /tmp/transpired.$proxies | awk '{ total += $1; count++ } END { print  total/count }'`
count=`cat /tmp/transpired.$proxies | wc -l`
echo "average retrieval time for $count URL's using `echo $proxies`
$average seconds" >> $2
done
clear
echo fin
echo I have saved the last result to $2
fi
fi
