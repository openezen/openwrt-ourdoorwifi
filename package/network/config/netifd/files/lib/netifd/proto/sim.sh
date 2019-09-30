#!/bin/sh
SIMSWITCH="ap147:sim"
SIM1_LED="ap147:green:sim1"
SIM2_LED="ap147:green:sim2"

setup_simcard()
{
	config=$1
	[ -e "/sys/class/leds/$SIMSWITCT" ] || return 
	[ -e "/dev/cdc-wdm0" ] || return

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

	sleep 2
	timeout -t 2 uqmi -d /dev/cdc-wdm0  --set-device-operating-mode reset 
	sleep 30
}
