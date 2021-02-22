#!/bin/bash
#clear
echo I will install the dependancies  and the blackhole package
echo press Enter to continue
read z
echo installing dependancies
#Install pip (if needed)
test -f /usr/bin/pip
pip=$?
if [ "$pip" == "0" ]
	then
	echo Looks like we have pip
	else
		echo installing pip components
              rpm -ivh http://dl.fedoraproject.org/pub/epel/7/x86_64/epel-release-7-6.noarch.rpm
#echo press enter to continue
read reply
              yum install -y python-pip
fi
#Install gcc (if needed)
test -f /usr/bin/gcc
gcc=$?
if [ "$gcc" == "0" ]
        then
                echo Looks like we have gcc
        else
                echo installing gcc components
echo press enter to continue
read reply
		yum install -y gcc
fi
#Install Python (if needed)
test -f /usr/include/python2.6/abstract.h
python=$?
if [ "$python" == "0" ]
        then
                echo Looks like we have python
        else
                echo installing python components
echo press enter to continue
read reply
		yum install -y centos-release-SCL
echo press enter to continue
read reply
		yum install -y python27
		echo installing Python Dev Tools components
echo press enter to continue
read reply
		yum  install -y python-devel.x86_64 
fi
#Install Blackhole
test -f /usr/bin/blackhole
blackhole=$?
if [ "$blackhole" == "0" ]
        then
                echo Looks like we have blackhole
        else
                echo installing blackhole components
#		pip install blackhole
cd /tmp
wget ftp://tinygen:wscps4565@transfer.technovoid.net/blackhole/blackhole-1.8.1.tar.gz
tar -xzf blackhole-1.8.1.tar.gz
cd /tmp/blackhole-1.8.1
python setup.py install
fi
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
