#!/bin/sh
append DRIVERS "mt7615e5"

. /lib/wifi/ralink_common.sh

mt7615e5_get_mac() {
	factory_part=$(find_mtd_part $1)
	dd bs=1 skip=4 count=6 if=$factory_part 2>/dev/null | /usr/sbin/maccalc bin2mac
}

prepare_mt7615e5() {
	prepare_ralink_wifi mt7615e5
}

scan_mt7615e5() {
	scan_ralink_wifi mt7615e5 mt7615e5
}


disable_mt7615e5() {
	disable_ralink_wifi mt7615e5
}

enable_mt7615e5() {
	enable_ralink_wifi mt7615e5 mt7615e5
}

detect_mt7615e5() {
#	detect_ralink_wifi mt7615 mt7615
	cd /sys/module/
	[ -d $module ] || return
	
	[ -f /etc/Wireless/mt7615/mt7615e5.dat ] || {
		mkdir -p /etc/Wireless/mt7615/ 2>/dev/null
		touch /tmp/mt7615e5.dat
		ln -s /tmp/mt7615e5.dat /etc/Wireless/mt7615/mt7615e5.dat 2>/dev/null
	}


         cat <<EOF
config wifi-device      mt7615e5
        option type     mt7615e5
        option vendor   ralink
        option band     5G
        option channel  auto
		option autoch	0
		option wifimode 14
		option ht '20+40+80'
		option bw '2'
		option country 'None'
		option aregion '7'
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
		option g256qam '1'
		option dbdc '1'
		option ht_opmode '0'
		option ht_gi '1'
		option ht_rdg '0'
		option ht_stbc '1'
		option ht_amsdu '0'
		option ht_autoba '1'
		option ht_badec '0'
		option ht_distkip '1'
		option ht_ldpc '0'
		option vht_stbc '1'
		option vht_sgi '1'
		option vht_bw_sig '0'
		option vht_ldpc '0'
		option ht_txstream '2'
		option ht_rxstream '2'

config wifi-iface main_5g
        option device   mt7615e5
        option ifname   rai0
        option network  lan
        option mode     ap
        option ssid 'Outdoor-wifi-5G'
		option encryption none
		option wmm '1'
		option apsd '0'

config wifi-iface guest_5g
        option device   mt7615e5
        option ifname   rai1
        option network  lan
        option mode     ap
        option ssid 'Outdoor-wifi-5G'
        option encryption none
        option disabled 1
		option wmm '1'
		option apsd '0'

EOF


}




