#!/bin/sh

simnum=$(uci -q get productinfo.hardware.simcard_num)

[ -n "$INCLUDE_ONLY" ] || {
	NOT_INCLUDED=1
	INCLUDE_ONLY=1

	. ../netifd-proto.sh
	. ./ppp.sh
	[ -e "/lib/netifd/proto/sim.sh" ] && . /lib/netifd/proto/sim.sh
	init_proto "$@"
}

proto_3g_init_config() {
	no_device=1
	available=1
	ppp_generic_init_config
	proto_config_add_string "device:device"
	proto_config_add_string "apn"
	proto_config_add_string "service"
	proto_config_add_string "pincode"
	proto_config_add_string "dialnumber"
	proto_config_add_string "sim"
	[ "$simnum" -ge 2 ] && {
		proto_config_add_string "apn1"
		proto_config_add_string "service1"
		proto_config_add_string "pincode1"
		proto_config_add_string "dialnumber1"

		proto_config_add_string "apn2"
		proto_config_add_string "service2"
		proto_config_add_string "pincode2"
		proto_config_add_string "dialnumber2"
	}
}

fix_sim_config() {
	local section=$1
	local sim apn service pincode dialnumber apn1 service1 pincode1 dialnumber1  apn2 service2 pincode2 dialnumber2
	[ -n "$section" ] || return

	json_get_vars sim apn1 service1 pincode1 dialnumber1 apn2 service2 pincode2 dialnumber2
	[ "$sim" == "1" ] && {
		echo "copy sim2 to network" >> /tmp/fixsim.log
		uci set network.$section.apn=$apn2
		uci set network.$section.service=$service2
		uci set network.$section.dialnumber=$dialnumber2
		uci set network.$section.pincode=$pincode2
	} || {
		echo "copy sim1 to network" >> /tmp/fixsim.log
		uci set network.$section.apn=$apn1
		uci set network.$section.service=$service1
		uci set network.$section.dialnumber=$dialnumber1
		uci set network.$section.pincode=$pincode1
	}
	uci commit network
}

proto_3g_setup() {
	local interface="$1"
	local chat

	echo "fix_sim_config simnum=$simnum" > /tmp/fixsim.log
	[ "$simnum" -ge 2 ] && {
		fix_sim_config "$interface"
	}
	
	json_get_var device device
	json_get_var apn apn
	json_get_var service service
	json_get_var pincode pincode
	json_get_var dialnumber dialnumber
	json_get_var sim sim

	echo "3g.sh sim=$sim" >> /tmp/sim.log

	[ -n "$sim" ] && setup_simcard $sim
	[ -n "$dat_device" ] && device=$dat_device

	device="$(readlink -f $device)"
	[ -e "$device" ] || {
		proto_set_available "$interface" 0
		return 1
	}

	case "$service" in
		cdma|evdo)
			chat="/etc/chatscripts/evdo.chat"
		;;
		*)
			chat="/etc/chatscripts/3g.chat"
			cardinfo=$(gcom -d "$device" -s /etc/gcom/getcardinfo.gcom)
			if echo "$cardinfo" | grep -q Novatel; then
				case "$service" in
					umts_only) CODE=2;;
					gprs_only) CODE=1;;
					*) CODE=0;;
				esac
				export MODE="AT\$NWRAT=${CODE},2"
			elif echo "$cardinfo" | grep -q Option; then
				case "$service" in
					umts_only) CODE=1;;
					gprs_only) CODE=0;;
					*) CODE=3;;
				esac
				export MODE="AT_OPSYS=${CODE}"
			elif echo "$cardinfo" | grep -q "Sierra Wireless"; then
				SIERRA=1
			elif echo "$cardinfo" | grep -qi huawei; then
				case "$service" in
					umts_only) CODE="14,2";;
					gprs_only) CODE="13,1";;
					*) CODE="2,2";;
				esac
				export MODE="AT^SYSCFG=${CODE},3FFFFFFF,2,4"
			fi

			if [ -n "$pincode" ]; then
				PINCODE="$pincode" gcom -d "$device" -s /etc/gcom/setpin.gcom || {
					proto_notify_error "$interface" PIN_FAILED
					proto_block_restart "$interface"
					return 1
				}
			fi
			[ -n "$MODE" ] && gcom -d "$device" -s /etc/gcom/setmode.gcom

			# wait for carrier to avoid firmware stability bugs
			[ -n "$SIERRA" ] && {
				gcom -d "$device" -s /etc/gcom/getcarrier.gcom || return 1
			}

			if [ -z "$dialnumber" ]; then
				dialnumber="*99***1#"
			fi

		;;
	esac

	connect="${apn:+USE_APN=$apn }DIALNUMBER=$dialnumber /usr/sbin/chat -t5 -v -E -f $chat"
	ppp_generic_setup "$interface" \
		noaccomp \
		nopcomp \
		novj \
		nobsdcomp \
		noauth \
		set EXTENDPREFIX=1 \
		lock \
		crtscts \
		115200 "$device"
	return 0
}

proto_3g_teardown() {
	proto_kill_command "$interface"
}

[ -z "$NOT_INCLUDED" ] || add_protocol 3g
