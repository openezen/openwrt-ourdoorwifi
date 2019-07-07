#!/bin/sh
	  
tries=0
while [[ $tries -lt 10 ]]
do
	if `ping -c 1 -w 2 8.8.8.8 > /dev/null` ; then
		exit 0
	fi
	tries=$((tries+1))
done
					 
date >> /root/reboot.log
					   
ifdown MOBILE
sleep 2
usbreset 001/003
sleep 10
ifup MOBILE
