
repair_wireless_uci() {
    echo "repair_wireless_uci" >>/tmp/wifi.log

    vifs=`uci show wireless | grep "=wifi-iface" | sed -n "s/=wifi-iface//gp"`
    echo $vifs >>/tmp/wifi.log

    ifn5g=0
    ifn2g=0
    for vif in $vifs; do
        local netif nettype device netif_new
        echo  "<<<<<<<<<<<<<<<<<" >>/tmp/wifi.log
        netif=`uci -q get ${vif}.ifname`
        nettype=`uci -q get ${vif}.network`
        device=`uci -q get ${vif}.device`
        if [ "$device" == "" ]; then
            echo "device cannot be empty!!" >>/tmp/wifi.log
            return
        fi
        echo "device name $device!!" >>/tmp/wifi.log
        echo "netif $netif" >>/tmp/wifi.log
        echo "nettype $nettype" >>/tmp/wifi.log
    
        case "$device" in
            mt7620 | mt7602e | mt7603e | mt7628 | mt7688 | mt7615e2 )
                netif_new="ra"${ifn2g}
                ifn2g=$(( $ifn2g + 1 ))
                ;;
            mt7610e | mt7612e)
                netif_new="rai"${ifn5g}
                ifn5g=$(( $ifn5g + 1 ))
                ;;
			mt7615e5 )
				netif_new="rai"${ifn5g}
				ifn5g=$(( $ifn5g + 1 ))
				;;
            * )
                echo "device $device not recognized!! " >>/tmp/wifi.log
                ;;
        esac                    
    
        echo "ifn5g = ${ifn5g}, ifn2g = ${ifn2g}" >>/tmp/wifi.log
        echo "netif_new = ${netif_new}" >>/tmp/wifi.log
            
        if [ "$netif" == "" ]; then
            echo "ifname empty, we'll fix it with ${netif_new}" >>/tmp/wifi.log
            uci -q set ${vif}.ifname=${netif_new}
        fi
        if [ "$nettype" == "" ]; then
            nettype="lan"
            echo "nettype empty, we'll fix it with ${nettype}" >>/tmp/wifi.log
            uci -q set ${vif}.network=${nettype}
        fi
		local enc=$(uci -q get  wireless.${device}.cliauthmode)

		if [ "$enc" == "SHARED" ]; then
			uci set wireless.${device}.clienc=WEP
		fi
		
        echo  ">>>>>>>>>>>>>>>>>" >>/tmp/wifi.log
    done
    uci changes >>/tmp/wifi.log
    uci commit
}


sync_uci_with_dat() {
    echo "sync_uci_with_dat($1,$2,$3,$4)" >>/tmp/wifi.log
    local device="$1"
    local datpath="$2"
    uci2dat -d $device -f $datpath > /tmp/uci2dat.log
}



chk8021x() {
        local x8021x="0" encryption device="$1" prefix
        #vifs=`uci show wireless | grep "=wifi-iface" | sed -n "s/=wifi-iface//gp"`
        echo "u8021x dev $device" > /tmp/802.$device.log
        config_get vifs "$device" vifs
        for vif in $vifs; do
                config_get ifname $vif ifname
                echo "ifname = $ifname" >> /tmp/802.$device.log
                config_get encryption $vif encryption
                echo "enc = $encryption" >> /tmp/802.$device.log
                case "$encryption" in
                        wpa+*)
                                [ "$x8021x" == "0" ] && x8021x=1
                                echo 111 >> /tmp/802.$device.log
                                ;;
                        wpa2+*)
                                [ "$x8021x" == "0" ] && x8021x=1
                                echo 1l2 >> /tmp/802.$device.log
                                ;;
                        wpa-mixed*)
                                [ "$x8021x" == "0" ] && x8021x=1
                                echo 1l3 >> /tmp/802.$device.log
                                ;;
                esac
                ifpre=$(echo $ifname | cut -c1-3)
                echo "prefix = $ifpre" >> /tmp/802.$device.log
                if [ "$ifpre" == "rai" ]; then
                    prefix="rai"
                else
                    prefix="ra"
                fi
                if [ "1" == "$x8021x" ]; then
                    break
                fi
        done
        echo "x8021x $x8021x, pre $prefix" >>/tmp/802.$device.log
        if [ "1" == $x8021x ]; then
            if [ "$prefix" == "ra" ]; then
                echo "killall 8021xd" >>/tmp/802.$device.log
                killall 8021xd
                echo "/bin/8021xd -d 9" >>/tmp/802.$device.log
                /bin/8021xd -d 9 >> /tmp/802.$device.log 2>&1
            else # $prefixa == rai
                echo "killall 8021xdi" >>/tmp/802.$device.log
                killall 8021xdi
                echo "/bin/8021xdi -d 9" >>/tmp/802.$device.log
                /bin/8021xdi -d 9 >> /tmp/802.$device.log 2>&1
            fi
        else
            if [ "$prefix" == "ra" ]; then
                echo "killall 8021xd" >>/tmp/802.$device.log
                killall 8021xd
            else # $prefixa == rai
                echo "killall 8021xdi" >>/tmp/802.$device.log
                killall 8021xdi
            fi
        fi
}


# $1=device, $2=module
reinit_wifi() {
    echo "reinit_wifi($1,$2,$3,$4)" >>/tmp/wifi.log
    local device="$1"
    local module="$2"
    config_get vifs "$device" vifs

    # shut down all vifs first
    for vif in $vifs; do
        config_get ifname $vif ifname
        ifconfig $ifname down
    done

    
	case "$device" in                                                           
		mt7620 | mt7602e | mt7603e | mt7628 | mt7688 | mt7615e2)
		ifprefix=ra                                                        
		ifconfig apcli0 down
		;;                                                                 
		mt7610e | mt7612e | mt7615e5)
		ifprefix=rai                                                       
		ifconfig apclii0 down
		;;                                                                 
	esac                                                                        
										                                                                                   
	if [ "$module" == "mt7615e5" -o "$module" == "mt7615e2" ]; then
		module="mt7615"
	fi
	if [ "$device" == "mt7615e5" ]; then
		for ifname in `ls -1 /sys/class/net/ | grep ra[0-9]`               
		do                                                                          
			ifconfig $ifname down                                                   
		done  
		ifconfig apcli0 down
	else
		for ifname in `ls -1 /sys/class/net/ | grep ${ifprefix}[0-9]`               
		do                                                                          
			ifconfig $ifname down                                                   
		done  
	fi

    # in some case we have to reload drivers. (mbssid eg)
    ref=`cat /sys/module/$module/refcnt`
    if [ $ref != "0" ]; then
        # but for single driver, we only need to reload once.
        echo "$module ref=$ref, skip reload module" >>/tmp/wifi.log
    else
        echo "rmmod $module" >>/tmp/wifi.log
        rmmod $module
        echo "insmod $module" >>/tmp/wifi.log
        insmod $module
    fi
    
    # in some case we have to reload drivers. (mbssid eg)
    # bring up vifs
#    for vif in $vifs; do
#        config_get ifname $vif ifname
#        config_get disabled $vif disabled
#        echo "ifconfig $ifname down" >>/tmp/wifi.log
#        if [ "$disabled" == "1" ]; then
#            echo "$ifname marked disabled, skip" >>/tmp/wifi.log
#            continue
#        else
#            echo "ifconfig $ifname up" >>/tmp/wifi.log
#            ifconfig $ifname up
#        fi
#    done

#    chk8021x $device
}

prepare_ralink_wifi() {
    echo "prepare_ralink_wifi($1,$2,$3,$4)" >>/tmp/wifi.log
    local device=$1
    config_get channel $device channel
    config_get ssid $2 ssid
    config_get mode $device wifimode
	config_get ht $device ht "20"
    config_get country $device country
    config_get regdom $device regdom

	local country="CN" region="1" aregion="0" autoch
	config_get chmode $device chmode "0"
	if [ "$chmode" = "1" ]; then
		country="US"
		region="0"
		aregion="7"
	elif [ "$chmode" = "2" ]; then
		country="JP"
		region="5"
		aregion="1"
	fi
   
    case "$device" in
		mt7612e|mt7610e|mt7615e5)
			uci set wireless.$device.region=$region
			uci set wireless.$device.aregion=$aregion
			;;
		mt7620 | mt7602e | mt7603e | mt7628 | mt7615e2 )
			uci set wireless.$device.region=$region
			;;
	esac
	
	if [ "$channel" == "auto" ]; then
		autoch=0
	else
		autoch=1
	fi
	uci set wireless.$device.autoch=$autoch

	uci set wireless.$device.country=$country

	# HT40 mode can be enabled only in bgn (mode = 9), gn (mode = 7)
    # or n (mode = 6).
	HT=1
	HT_CE=1
    [ "$mode" = 6 -o "$mode" = 7 -o "$mode" = 9 -o "$device" = "mt7612e" -o "$device" = "mt7610e" -o "$device" = "mt7615e5" ] && {
		case "$ht" in
			20)
				HT=0
				HT_CE=1
				VHT=0
				VHT_DN=0
				;;
			20+40)
				HT=1
				HT_CE=1
				VHT=0
				VHT_DN=0	  
				;;
			20+40+80)
				HT=2
				HT_CE=1
				VHT=2 
				VHT_DN=0
				;;
			40+80)
				HT=2
				HT_CE=0
				VHT=2
				 VHT_DN=1
				;;
			40)
				HT=1
				HT_CE=0
				VHT=0
				VHT_DN=0
				;;
			80)
				HT=2 
				HT_CE=1
				VHT=2
				VHT_DN=1
				;;
			*)
				echo "unknow ht mode!"
				;;	
		esac
		uci set wireless.$device.bw=$HT     #HT_BW
		uci set wireless.$device.ht_bsscoexist=$HT_CE	#HT_BSSCoexistence
		uci set wireless.$device.vbw=$VHT	#VHT_BW
		uci set wireless.$device.vht_disnonvht=$VHT_DN	#VHT_DisallowNonVHT
	}
    # In HT40 mode, a second channel is used. If EXTCHA=0, the extra
    # channel is $channel + 4. If EXTCHA=1, the extra channel is
    # $channel - 4. If the channel is fixed to 1-4, we'll have to
    # use + 4, otherwise we can just use - 4.
    EXTCHA=0
    [ "$channel" != auto ] && [ "$channel" -lt "5" ] && EXTCHA=1
	uci commit wireless
}

scan_ralink_wifi() {
    local device="$1"
    local module="$2"
    echo "scan_ralink_wifi($1,$2,$3,$4)" >>/tmp/wifi.log
    repair_wireless_uci
	prepare_ralink_wifi $1 $2
    sync_uci_with_dat $device /tmp/$device.dat
}

disable_ralink_wifi() {
    echo "disable_ralink_wifi($1,$2,$3,$4)" >>/tmp/wifi.log
    local device="$1"
    config_get vifs "$device" vifs
    for vif in $vifs; do
        config_get ifname $vif ifname
        ifconfig $ifname down
    done

	killall bndstrg
    # kill any running ap_clients
    killall ap_client || true
}

disable_wifi_qos(){
	iptables -D FORWARD -j wifirl
	iptables -S | grep "^-N wifirl" | sed "s/-N/iptables -w -F/g;p;s/-F/-X/g" | sh
}


enable_wifi_qos() {
	local ifname=$1
	local downlimit=$2
	local iplimit=$3
	echo "enable_wifi_qos($1,$2,$3)" >> /tmp/wifi.log
	
	if [ -z "$ifname" ]; then 
		return
	fi
	iptables -L wifirl > /dev/null  2>&1
	if [ $? != 0 ]; then
		iptables -N wifirl
		iptables -I FORWARD -j wifirl
	fi
	

	if [ "$downlimit" != "0" ]; then
		iptables -N wifirl_${ifname}_down
		iptables -A wifirl -j wifirl_${ifname}_down
		iptables -A wifirl_${ifname}_down -j MARK --set-xmark 0x2000/0x2000
		iptables -A wifirl_${ifname}_down -m mark --mark 0x2000/0x2000 -j grpobj_dstip_$ifname
		iptables -A wifirl_${ifname}_down -m mark --mark 0x2000/0x2000 -j HOSTRLIMIT --rate $downlimit  --hosttype dstip
	fi
	
	if [ "$uplimit" != "0" ]; then
		iptables -N wifirl_${ifname}_up
		iptables -A wifirl -j wifirl_${ifname}_up
		iptables -A wifirl_${ifname}_up -j MARK --set-xmark 0x2000/0x2000
		iptables -A wifirl_${ifname}_up -m mark --mark 0x2000/0x2000 -j grpobj_srcip_$ifname
		iptables -A wifirl_${ifname}_up -m mark --mark 0x2000/0x2000 -j HOSTRLIMIT --rate $uplimit  --hosttype srcip
	fi

}

update_qos() {
	local cfg="$1"
	local ifname qos_enable uplimit downlimit
	config_get ifname $cfg ifname
	config_get qos_enable $cfg qos_enable 0
	config_get uplimit $cfg uplimit 0
	config_get downlimit $cfg downlimit 0
	if [ "$qos_enable" == "1" ]; then     
		enable_wifi_qos $ifname $downlimit $uplimit             
	fi        
}

update_wifi_qos() {
	config_load wireless
	config_foreach update_qos wifi-iface
}

enable_ralink_wifi() {
    echo "enable_ralink_wifi($1,$2,$3,$4)" >>/tmp/wifi.log
    local device="$1"
	local disabled cliautoch clienable

	reinit_wifi $device $2

	if [ "$device" == "mt7615e5" ]; then
		ifconfig ra0 up
		config_get vifs "mt7615e2" vifs
		for vif in $vifs; do
			config_get ifname $vif ifname
			config_get disabled $vif disabled
			config_get radio $device radio
			config_get maxassoc $vif maxassoc
			config_get kickthres $vif kickthres
			config_get assocthres $vif assocthres
			config_get noforward $vif noforward 0
			config_get qos_enable $vif qos_enable 0
			config_get uplimit $vif uplimit 0
			config_get downlimit $vif downlimit 0
			ifconfig $ifname up
			echo "ifconfig $ifname up" >>/dev/null
		
		#Radio On/Off only support iwpriv command but dat file
			[ "$radio" == "0" ] && iwpriv $ifname set RadioOn=0
			[ -n "$maxassoc" ] && iwpriv $ifname set MaxStaNum=$maxassoc
			[ -n "$kickthres" ] && iwpriv $ifname set KickStaRssiLow=$kickthres
			[ -n "$assocthres" ] && iwpriv $ifname set AssocReqRssiThres=$assocthres
			[ -n "$noforward" ] && iwpriv $ifname set NoForwarding=$noforward
			
			
			if [ "$qos_enable" == "1" ]; then     
				enable_wifi_qos $ifname $downlimit $uplimit             
			fi        
			local net_cfg bridge
			net_cfg="$(find_net_config "$vif")"
			[ -z "$net_cfg" ] && net_cfg="lan"
			
			bridge="$(bridge_interface "$net_cfg")"
			config_set "$vif" bridge "$bridge"
			brctl addif $bridge $ifname
			start_net "$ifname" "$net_cfg"
				
			chk8021x $device
			set_wifi_up "$vif" "$ifname"
		done
	fi

    config_get vifs "$device" vifs
    # bring up vifs
    	

	for vif in $vifs; do
        config_get ifname $vif ifname
        config_get disabled $vif disabled
		config_get radio $device radio
        config_get maxassoc $vif maxassoc
        config_get kickthres $vif kickthres
        config_get assocthres $vif assocthres
        config_get noforward $vif noforward 0
		config_get qos_enable $vif qos_enable 0
		config_get uplimit $vif uplimit 0
		config_get downlimit $vif downlimit 0
        ifconfig $ifname up
        echo "ifconfig $ifname down" >>/dev/null
        if [ "$disabled" == "1" ]; then
			echo "$ifname marked disabled, ifconfig down" >>/dev/null
			ifconfig $ifname down
			continue
        else
            echo "$ifname enabled" >>/tmp/wifi.log
        fi
	#Radio On/Off only support iwpriv command but dat file
        [ "$radio" == "0" ] && iwpriv $ifname set RadioOn=0
        [ -n "$maxassoc" ] && iwpriv $ifname set MaxStaNum=$maxassoc
        [ -n "$kickthres" ] && iwpriv $ifname set KickStaRssiLow=$kickthres
        [ -n "$assocthres" ] && iwpriv $ifname set AssocReqRssiThres=$assocthres
        [ -n "$noforward" ] && iwpriv $ifname set NoForwarding=$noforward		
		
		if [ "$qos_enable" == "1" ]; then     
			enable_wifi_qos $ifname $downlimit $uplimit             
		fi        
        local net_cfg bridge
        net_cfg="$(find_net_config "$vif")"
        [ -z "$net_cfg" ] && net_cfg="lan"
		
		bridge="$(bridge_interface "$net_cfg")"
        config_set "$vif" bridge "$bridge"
		brctl addif $bridge $ifname
        start_net "$ifname" "$net_cfg"
			
		chk8021x $device
        set_wifi_up "$vif" "$ifname"
    done

	config_get disabled main disabled
	[ "$device" == "mt7615e5" ] && [ "$disabled" == "1" ] && {
		ifconfig ra0 down
	}


	if [ "$device" == "mt7615e5" ]; then
		config_get cliautoch "mt7615e2" cliautoch
		config_get clienable "mt7615e2" clienable
		if [ "y$cliautoch" == "y3" -a "y$clienable" == "y1" ]; then			
			iwpriv apcli0 set ApCliAutoConnect=3			
		fi
	fi

	config_get cliautoch $device cliautoch
	config_get clienable $device clienable
	config_get band $device band
	if [ "y$cliautoch" == "y3" -a "y$clienable" == "y1" ]; then
		if [ "$band" == "2.4G" ]; then
			iwpriv apcli0 set ApCliAutoConnect=3
		else
			iwpriv apclii0 set ApCliAutoConnect=3
		fi
	fi
}

detect_ralink_wifi() {
    echo "detect_ralink_wifi($1,$2,$3,$4)" >>/tmp/wifi.log
    local channel
    local device="$1"
    local module="$2"
    local band
    local ifname
    cd /sys/module/
    [ -d $module ] || return
    config_get channel $device channel
    [ -z "$channel" ] || return
    case "$device" in
        mt7620 | mt7602e | mt7603e | mt7628 | mt7615e2 )
            ifname="ra0"
            band="2.4G"
            ;;
        mt7610e | mt7612e )
            ifname="rai0"
            band="5G"
            ;;
		mt7615e5)
			ifname="rai0"
			band="5G"
			;;
        * )
            echo "device $device not recognized!! " >>/tmp/wifi.log
            ;;
    esac                    
    cat <<EOF
config wifi-device    $device
    option type     $device
    option vendor   ralink
    option band     $band
    option channel  0
    option autoch   2

config wifi-iface
    option device   $device
    option ifname    $ifname
    option network  lan
    option mode     ap
    option ssid OpenWrt-$device
    option encryption psk2
    option key      12345678

EOF
}



