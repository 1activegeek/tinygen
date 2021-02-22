cd /usr/local/tinygen/emailfiles/endpoint
echo putting file
smbclient //192.168.88.55/dropit -U dlpdude20/administrator%Websense1 -c "put "aerojet.txt"" 2>/dev/null
sleep 5
echo deleting file
#smbclient //192.168.88.55/usb -U dlpdude20/administrator%Websense1 -c "del "aerojet.txt"" 2>/dev/null



