RM = rm -f
DC = gdc
LDLIBS =
DFLAGS = -Wall -Wextra -Isrc -Isrc/graph -Isrc/algorithms -J.
#GDB = -fdebug -funittest -ggdb3
GDB = -O3 -frelease -ffast-math -fno-bounds-check

VPATH = src:src/graph:src/algorithms
OBJS = main.o graph.o algorithms.o

TARGET = graph

$(TARGET) : $(OBJS)
	$(DC) $^ $(LDLIBS) -o $@

%.o : %.d
	$(DC) $(DFLAGS) $(GDB) $^ -c

.PHONY: clean

clean:
	$(RM) $(OBJS)
	$(RM) $(TARGET)

