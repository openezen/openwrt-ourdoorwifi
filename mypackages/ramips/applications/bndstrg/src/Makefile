BNDSTRG_EXEC = bndstrg

CFLAGS += -I./ -Wall -g -lrt -ffunction-sections -fdata-sections -DBND_STRG_DBG -DBND_STRG_QA
#-DSYSLOG
LDFLAGS += -lpthread -Wl,--gc-sections

BNDSTRG_OBJS = bndstrg.o driver_wext.o eloop.o os_internal.o main.o netlink.o

all: $(BNDSTRG_EXEC)

$(BNDSTRG_EXEC): $(BNDSTRG_OBJS)
	$(CC) $(CFLAGS) $(EXTRA_CFLAGS) $(LDFLAGS) -o $(BNDSTRG_EXEC) $(BNDSTRG_OBJS)

install:
	echo ok

romfs:
	$(ROMFSINST) /bin/$(BNDSTRG_EXEC)
	$(ROMFSINST) -S ../init.d/W66bndstr /etc/rc.d/W66bndstr
	$(ROMFSINST) -s /etc/rc.d/W66bndstr /etc/init.d/bndstr

clean:
	rm -f *.o $(BNDSTRG_EXEC)
