#!/bin/sh


switch_simcard(){
	local cur=$(uci get network.MOBILE.sim)
	local sim

	if [ "$cur" == 1 ]; then
		sim=0
	else
		sim=1
	fi
	uci set network.MOBILE.sim=$sim
	uci commit network

	. /lib/netifd/proto/sim.sh
	setup_simcard $sim
}


ret=$(uci -q get network.MOBILE)	
device=$(uci -q get network.MOBILE.device)	
mwan=$(uci -q get mwan3.global.enabled)
[ "$ret" != "interface" ] && exit 0
[ "$mwan" == 1 ] && exit 0
[ -n "$device" ] || exit 0

ips=$(uci -q get mwan3.MOBILE.track_ip)
[ -n "$ips" ] || ips="8.8.8.8"

for ip in $ips; do
	tries=0
	while [[ $tries -lt 10 ]]
	do
		if `ping -c 1 -w 2 $ip > /dev/null` ; then
			exit 0
		fi
		tries=$((tries+1))
	done
	break
done
					 
					   
ifdown MOBILE
sleep 2
sim=$(uci get network.MOBILE.sim)
auto=$(uci get network.MOBILE.simauto)
modem=$(leval luci.sys.mmcli_get_modem)
date >> /root/reboot.log
echo "sim=$sim auto=$auto" >> /root/reboot.log

if [ "$auto" == 1 ]; then
	switch_simcard
else
	[ -n "$modem" ] && { 
		mmcli -m $modem -r  
		sleep 30
	}
fi
ifup MOBILE
