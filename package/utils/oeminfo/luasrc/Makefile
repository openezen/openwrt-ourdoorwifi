
all: oeminfo

%_tmp: %.lua
	$(LUAC) -s -o $@ $^

oeminfo: oeminfo_tmp
	echo "$(BIN_LUA)" > $@
	cat $^ >> $@
	rm -f $^
	
