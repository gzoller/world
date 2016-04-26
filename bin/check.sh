#!/bin/sh

checkProc() {
	running="1"
	while [ $running -ne "0" ]
	do
		pgrep $1 > /dev/null
		running=$?
		if [ $running -ne "0" ]
		then
			sleep 1
		fi
	done
}

checkProc portster
#checkProc nginx

echo "OK" > /var/www/html/status
