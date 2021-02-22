#!/bin/bash
cd /usr/local/tinygen
while true
do
sleeper=`shuf -n 1 ep_sleep_list`
/usr/local/tinygen/endpoint.sh desktop-67umbuf student Forcepoint1
echo sleeping $sleeper seconds>>/tmp/endpoint.log

#I was feeling a little creative so put this in to calculate the next run time
# get the the time for today in seconds
now=`echo $(date '+%s')`

#get the epoch time until midnight this morning in seconds
midnight=`echo $(date -d 'today 00:00:00' '+%s')`

# time of day in seconds is equal to now seconds minus midnight this morning
midnight_seconds=`echo $(( now - midnight ))`

#now we add the seconds we will be sleeping to the seconds for todays time plus #5 seconds for the time endpoint.sh sleeps between put and delete of the file
total_seconds=`echo $(( $midnight_seconds+$sleeper ))`

#convert it to user readable 12 hour time format
next_run=`date -u -d @${total_seconds} +"%r"`

#append to /tmp/endpoint.log
echo Next run will be on or around $next_run >>/tmp/endpoint.log

sleep $sleeper
done
