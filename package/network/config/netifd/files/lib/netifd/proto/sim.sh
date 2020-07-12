#!/bin/sh
SIMSWITCH="ap147:sim"
SIM1_LED="ap147:green:sim1"
SIM2_LED="ap147:green:sim2"

setup_simcard()
{
	config=$1
	[ -e "/sys/class/leds/$SIMSWITCT" ] || return 

	modem=$(leval luci.sys.mmcli_get_modem)
	[ -n "$modem" ] || {
		echo "modem not found" >> /tmp/sim.log 
		return
	}
	
	status=$(cat /sys/class/leds/$SIMSWITCH/brightness)
	echo "status=$status, config=$config" >> /tmp/sim.log
	
	[ -n "$status" ] || return
	[ "$status" == "$config" ] && return
	echo "$config" >> /sys/class/leds/$SIMSWITCH/brightness
	
	if [ "$config" == "1" ]; then
		echo 0 > /sys/class/leds/$SIM1_LED/brightness
		echo 1 > /sys/class/leds/$SIM2_LED/brightness
	else
		echo 1 > /sys/class/leds/$SIM1_LED/brightness
		echo 0 > /sys/class/leds/$SIM2_LED/brightness
	fi
	modem=$(leval luci.sys.mmcli_get_modem)
	[ -n "$modem" ] || modem=0

	sleep 2
	mmcli -m $modem -r  
	sleep 30
}
