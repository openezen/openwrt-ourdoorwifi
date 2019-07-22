#!/bin/sh
	  
tries=0
while [[ $tries -lt 10 ]]
do
	if `ping -c 1 -w 2 8.8.8.8 > /dev/null` ; then
		exit 0
	fi
	tries=$((tries+1))
done
					 
					   
ifdown MOBILE
sleep 2
sim=$(uci get network.MOBILE.sim)
date >> /root/reboot.log
timeout -t 2 uqmi -d /dev/cdc-wdm0  --set-device-operating-mode reset 
sleep 30
ifup MOBILE
