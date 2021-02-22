#!/bin/bash
clear
echo OK
echo time to configure the startup script blackhole.sh
echo press Enter to continue
read z
#interfaces=`ifconfig | grep "inet addr" | grep -v 127\.0\.0\.1 | awk -F ":" '{print $2}' | awk '{print $1}'`
interfaces=`ip addr show ens32 | grep inet | grep brd | awk -F "/" '{print $1}' | awk '{ print $2 }'`
for nics in `echo $interfaces`
        do
                echo $nics
        done
echo which IP Address do you want blackhole to bind to\?
read IP
echo what port do you want to run blackhole on\?
read port
echo using IP $IP and Port $port
echo \#!/bin/bash > blackhole.sh
echo "blackhole -ssl=False -host=$IP --group=root -user=root -mode=accept -port=$port --message_size_limit=2000000 \$1" >> blackhole.sh
chmod +x blackhole.sh

#check to see if /etc/sysconfig/iptables is ACCEPTing on this port
#grep "\-\-dport $port" /etc/sysconfig/iptables>/dev/null
already=0
if [ "$already" == "1" ]
	then
		#offer to set port to allow in /etc/sysconfig/iptables
		echo would you like me to set /etc/sysconfig/iptable to allow connections on port $port?
		echo y\/n
		read reply
		if [ $reply == "y" ]
		        then
				cp /etc/sysconfig/iptables /etc/sysconfig/iptables.bak 
		                sed "/^-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT/a -A INPUT -m state --state NEW -m tcp -p tcp --dport $port -j ACCEPT" /etc/sysconfig/iptables > working.file
		                cp working.file /etc/sysconfig/iptables
				echo restarting iptables
				service iptables restart
		                rm -f working.file
		fi
fi
#check to see if set in startup
grep blackhole.sh /etc/rc.d/rc.local
rcd=$?
if [ "$rcd" == "1" ]
	then
		# offer to set in startup
		echo would you like to set \/etc\/rc.d\/rc.local to start blackhole on startup\?
		echo y\/n
		read reply
		if [ "$reply" == "y" ]
		   then
			Install_Dir=`pwd`
			cp /etc/rc.d/rc.local /etc/rc.d/rc.local.bak
			echo $Install_Dir/blackhole.sh start >> /etc/rc.d/rc.local
		fi
fi
echo Starting Blackhole on IP $IP and Port $port
./blackhole.sh start
