clear
echo making sure we are in tools
test -f ./setIP.sh
if [ "$?" != "1" ]
	then
		clear
		echo Installing TGCC
		echo Getting Package
		wget ftp://tinygen:wscps4565@transfer.technovoid.net/patch/tgcc.tar.gz
		tar -xzvf tgcc.tar.gz
		echo Moving Files
		mv *.tpl ..
		mv .sasan.sh ..
		mv tgcc ..
		echo done
		echo do you want to start Tiny-Gen Control Center? y\/n
		read reply
		if [ "$reply" == "y" ]
			then
				cd ..
				./tgcc
			else
				echo OK, To start Tiny-Gen Control Center make suer you are
				echo in the tinygen install directory and enter ./tgcc
		fi
#cleanup
rm -f tgcc.tar.gz
	else
                tput setaf 3
                echo you need to be in \<Install Directory\>\/tools
                echo You are in `tput setaf 1;pwd;tput setaf 3`
                echo FAILURE
                tput sgr0
                exit 0
fi

