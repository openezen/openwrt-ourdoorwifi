all: datacenter leval
	$(MAKE) -C ajax
	    
%_tmp: %.lua
	$(LUAC) -o $@ $^

%: %_tmp
	echo "$(BIN_LUA)" > $@
	cat $^ >> $@
	rm -f $^
