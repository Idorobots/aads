RM = rm -f
DC = gdc
LDLIBS =
DFLAGS = -Wall -Wextra -Isrc
GDB = -fdebug -funittest -ggdb3
#GDB = -O3 -frelease -ffast-math -fno-bounds-check

VPATH = src

OBJS = main.o huffman.o utils.o

TARGET = huffman

$(TARGET) : $(OBJS)
	$(DC) $^ $(LDLIBS) -o $@

%.o : %.d
	$(DC) $(DFLAGS) $(GDB) $^ -c

.PHONY: clean

clean:
	$(RM) $(OBJS)
	$(RM) $(TARGET)

