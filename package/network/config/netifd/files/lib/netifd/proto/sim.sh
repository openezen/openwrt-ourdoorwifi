#!/bin/sh
SIMSWITCH=1

setup_simcard()
{
	config=$1
#	[ -e "/sys/class/leds/$SIMSWITCT" ] || return 
#	[ -e "/dev/cdc-wdm0" ] || return
	
#	status=$(cat /sys/class/leds/$SIMSWITCH/brightness)
#	echo "status=$status, config=$config" >> /tmp/sim.log
#	[ -n "$status" ] || return
#	[ "$status" == "$config" ] && return
#	echo "config=$config" >> /tmp/sim.log
#	echo "$config" >> /sys/class/leds/$SIMSWITCH/brightness

	[ -e "/sys/class/gpio/gpio1" ] || {
		echo 1 > /sys/class/gpio/export
		echo "out" > /sys/class/gpio/gpio1/direction
	}
	status=$(cat /sys/class/gpio/gpio1/value)
	[ -n "$status" ] || return
	[ "$status" == "$config" ] && return
	echo "$config" > /sys/class/gpio/gpio1/value
	sleep 2
	timeout -t 2 uqmi -d /dev/cdc-wdm0  --set-device-operating-mode reset 
	sleep 60
}
