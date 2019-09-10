all: qmi qmiinfo qmisignal
	    
%_tmp: %.lua
	$(LUAC) -o $@ $^

%: %_tmp
	echo "$(BIN_LUA)" > $@
	cat $^ >> $@
	rm -f $^
