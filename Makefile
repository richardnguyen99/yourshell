CC:=gcc
COMMON_FLAGS:=-Wall -std=c99 -D_POSIX_C_SOURCE=200809L
CFLAGS:=$(COMMON_FLAGS) -Werror -Wextra -pedantic -O3
DEBUG_FLAGS:=$(COMMON_FLAGS) -g -O0
LDFLAGS:=-lm -lpthread -lreadline -lcurses -lc 
TARGET:=yrsh

FILENAMES:=lex.yy y.tab yrsh main

SRCDIR:=src
OBJDIR:=obj
INCDIR:=include

# SOURCES:=$(wildcard $(SRCDIR)/*.c)
# OBJECTS:=$(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%.o, $(SOURCES))
# HEADERS:=$(wildcard $(INCDIR)/*.h)

SOURCES:=$(addprefix $(SRCDIR)/, $(addsuffix .c, $(FILENAMES)))
OBJECTS:=$(addprefix $(OBJDIR)/, $(addsuffix .o, $(FILENAMES)))
HEADERS:=$(wildcard $(INCDIR)/*.h) $(SRCDIR)/y.tab.h $(SRCDIR)/lex.yy.h


.PHONY: all clean debug

all: mkdirobj lex $(TARGET)

debug: lex-debug
	$(CC) $(DEBUG_FLAGS) -I$(SRCDIR) -I$(INCDIR) -o $(TARGET) $(SOURCES) $(LDFLAGS)

mkdirobj:
	mkdir -p $(OBJDIR)

grammar: $(SRCDIR)/yrsh.y
	yacc -d -o $(SRCDIR)/y.tab.c $(SRCDIR)/yrsh.y

grammar-debug: $(SRCDIR)/yrsh.y
	yacc -d -v -o $(SRCDIR)/y.tab.c $(SRCDIR)/yrsh.y

lex: grammar $(SRCDIR)/yrsh.l
	flex -o $(SRCDIR)/lex.yy.c --header-file=$(SRCDIR)/lex.yy.h $(SRCDIR)/yrsh.l

lex-debug: grammar-debug
	flex -o $(SRCDIR)/lex.yy.c $(SRCDIR)/yrsh.l

$(TARGET):  $(OBJECTS) $(HEADERS) 
	$(CC) $(CFLAGS) -I$(SRCDIR) -I$(INCDIR) 				\
		 -o $(TARGET) 										\
		 $(OBJECTS)											\
		 $(LDFLAGS)

$(OBJDIR)/y.tab.o: $(SRCDIR)/y.tab.c $(HEADERS)
	$(CC) -I$(SRCDIR) -I$(INCDIR) -O3 -c $< -o $@

$(OBJDIR)/lex.yy.o: $(SRCDIR)/lex.yy.c $(HEADERS)
	$(CC) -I$(SRCDIR) -I$(INCDIR) -O3 -c $< -o $@

$(OBJDIR)/%.o: $(SRCDIR)/%.c $(HEADERS)
	$(CC) $(CFLAGS) -I$(SRCDIR) -I$(INCDIR) -c $< -o $@

clean:
	rm -rf $(OBJDIR) $(TARGET) $(SRCDIR)/lex.yy.c $(SRCDIR)/y.tab.c $(SRCDIR)/lex.yy.h $(SRCDIR)/y.tab.h $(SRCDIR)/y.output
