CC:=gcc
COMMON_FLAGS:=-Wall -Werror -std=c99
CFLAGS:=$(COMMON_FLAGS) -Wextra -pedantic -O3
DEBUG_FLAGS:=$(COMMON_FLAGS) -g -O0
LDFLAGS:=-lm -lpthread -lreadline -lcurses -lc 
TARGET:=yrsh

SRCDIR:=src
OBJDIR:=obj
INCDIR:=include

SOURCES:=$(wildcard $(SRCDIR)/*.c)
OBJECTS:=$(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%.o, $(SOURCES))
HEADERS:=$(wildcard $(INCDIR)/*.h)

.PHONY: all clean debug

all: mkdirobj $(TARGET)

mkdirobj:
	mkdir -p $(OBJDIR)

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

$(OBJDIR)/%.o: $(SRCDIR)/%.c $(HEADERS)
	$(CC) -I$(INCDIR) $(CFLAGS) -c -o $@ $<

debug: 
	$(CC) $(DEBUG_FLAGS) -I$(INCDIR) -o $(TARGET) $(SOURCES) $(LDFLAGS)

clean:
	rm -rf $(OBJDIR) $(TARGET)
