#!/bin/bash
#Post stuff to dlpdude.com
Post_Data=$1
domain=`grep 'tinygen/en' /usr/local/tinygen/runit_ep.sh | awk '{print $2}'`
user=`grep 'tinygen/en' /usr/local/tinygen/runit_ep.sh | awk '{print $3}'`
passwd=`grep 'tinygen/en' /usr/local/tinygen/runit_ep.sh | awk '{print $4}'`
proxy=`tail -n 1 /usr/local/tinygen/proxies.txt`
export https_proxy=https://$domain_name\\$user:$pass@$proxy
#echo $https_proxy
wget -q -O/dev/null --no-check-certificate --post-data="$Post_Data" https://dlpdude.com/display-datap.asp>/dev/null
