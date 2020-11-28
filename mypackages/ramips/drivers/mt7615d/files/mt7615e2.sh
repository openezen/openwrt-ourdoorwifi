#!/bin/sh
append DRIVERS "mt7615e2"

. /lib/wifi/ralink_common.sh

mt7615e2_get_mac() {
	factory_part=$(find_mtd_part $1)
	dd bs=1 skip=4 count=6 if=$factory_part 2>/dev/null | /usr/sbin/maccalc bin2mac
}

prepare_mt7615e2() {
	prepare_ralink_wifi mt7615e2
}

scan_mt7615e2() {
	scan_ralink_wifi mt7615e2 mt7615e2
}


disable_mt7615e2() {
	return
	disable_ralink_wifi mt7615e2
}

enable_mt7615e2() {
	return
	enable_ralink_wifi mt7615e2 mt7615e2
}

detect_mt7615e2() {
#	detect_ralink_wifi mt7615 mt7615
	local ssid
	cd /sys/module/
	[ -d $module ] || return
	
	[ -f /etc/Wireless/mt7615/mt7615e2.dat ] || {
		mkdir -p /etc/Wireless/mt7615/ 2>/dev/null
		touch /tmp/mt7615e2.dat
		ln -s /tmp/mt7615e2.dat /etc/Wireless/mt7615/mt7615e2.dat 2>/dev/null
	}


         cat <<EOF
config wifi-device      mt7615e2
        option type     mt7615e2
        option vendor   ralink
        option band     2.4G
        option channel  auto
		option autoch	0
		option wifimode '9'
		option ht '40'
		option bw '1'
		option country 'None'
		option region '5'
		option bgprotect '0'
		option beacon '100'
		option dtim '1'
		option fragthres '2346'
		option rtsthres '2347'
		option txpower '100'
		option txpreamble '1'
		option shortslot '1'
		option txburst '1'
		option pktaggre '1'
		option ieee80211h '0'
		option ht_extcha '1'
		option ht_opmode '0'
		option ht_gi '1'
		option ht_rdg '0'
		option ht_stbc '1'
		option ht_amsdu '0'
		option ht_autoba '1'
		option ht_badec '0'
		option ht_distkip '1'
		option ht_ldpc '0'
		option ht_txstream '2'
		option ht_rxstream '2'
		option g256qam '1'
		option dbdc '1'

config wifi-iface main
        option device   mt7615e2
        option ifname   ra0
        option network  lan
        option mode     ap
        option ssid 'Outdoor-wifi'
		option encryption none
		option wmm '1'
		option apsd '0'

config wifi-iface guest
        option device   mt7615e2
        option ifname   ra1
        option network  lan
        option mode     ap
        option ssid 'Outdoor-wifi'
        option encryption none
        option disabled 1
		option wmm '1'
		option apsd '0'


EOF


}




