EXEC=gpio 
SRC=gpio_pins.c

all: $(EXEC)
gpio: $(SRC)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(SRC) $(LDLIBS)

clean:
	-rm -f $(EXEC) *.elf *.gdb *.o

