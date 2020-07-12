all: qmi qmiinfo qmisignal mmcli mminfo
	    
%_tmp: %.lua
	$(LUAC) -o $@ $^

%: %_tmp
	echo "$(BIN_LUA)" > $@
	cat $^ >> $@
	rm -f $^
