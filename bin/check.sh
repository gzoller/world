#!/bin/sh

checkProc() {
	running="1"
	echo "Checking $1"
	while [ $running -ne "0" ]
	do
		pgrep -f $1 > /dev/null
		running=$?
		if [ $running -ne "0" ]
		then
			sleep 1
		fi
	done
	echo "$1 Running"
}

checkProc nginx
checkProc postgres
checkProc redis-server
checkProc fakes3
checkProc zookeeper
checkProc eventstored

echo "OK" > /var/www/html/status
