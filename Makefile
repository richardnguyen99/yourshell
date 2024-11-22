CC:=gcc
COMMON_FLAGS:=-std=c99 -D_POSIX_C_SOURCE=200809L
CFLAGS:=$(COMMON_FLAGS) -Wall -Werror -Wextra -pedantic -O3
DEBUG_FLAGS:=$(COMMON_FLAGS) -DDEBUG -g -O0
LDFLAGS:=-lm -lpthread -lreadline -lcurses -lc 
TARGET:=yrsh

FILENAMES:=lex.yy y.tab command job yrsh main

SRCDIR:=src
OBJDIR:=obj
LEXDIR:=lex
INCDIR:=include

SOURCES:=$(wildcard $(SRCDIR)/*.c)
OBJECTS:=$(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%.o, $(SOURCES))
OBJDEBS:=$(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%-debug.o, $(SOURCES))
HEADERS:=$(wildcard $(INCDIR)/*.h)



.PHONY: all clean debug lexshell

all: mkdirobj lexshell $(TARGET)

debug: mkdirobj lex-debug yrsh-debug


mkdirobj:
	mkdir -p $(OBJDIR)

lexer: $(LEXDIR)/yrsh.l $(LEXDIR)/yrsh.y

lexshell: 
	yacc -d -v 	--header=include/y.tab.h  		-o $(LEXDIR)/y.tab.c 	$(LEXDIR)/yrsh.y
	flex   		--header-file=include/lex.yy.h 	-o $(LEXDIR)/lex.yy.c	$(LEXDIR)/yrsh.l
	$(CC) $(COMMON_FLAGS) -c -I. -I$(INCDIR) -o $(OBJDIR)/y.tab.o  $(LEXDIR)/y.tab.c
	$(CC) $(COMMON_FLAGS) -c -I. -I$(INCDIR) -o $(OBJDIR)/lex.yy.o $(LEXDIR)/lex.yy.c

lex-debug: 
	yacc -d -v -t 	--header=include/y.tab.h  		-o $(LEXDIR)/y.tab.c 	$(LEXDIR)/yrsh.y
	flex -d -v 		--header-file=include/lex.yy.h 	-o $(LEXDIR)/lex.yy.c	$(LEXDIR)/yrsh.l
	$(CC) $(DEBUG_FLAGS) -c -I. -I$(INCDIR) -o $(OBJDIR)/y.tab.o  $(LEXDIR)/y.tab.c
	$(CC) $(DEBUG_FLAGS) -c -I. -I$(INCDIR) -o $(OBJDIR)/lex.yy.o $(LEXDIR)/lex.yy.c

yrsh-debug: $(OBJDEBS) $(HEADERS)
	$(CC) $(DEBUG_FLAGS) -I$(SRCDIR) -I$(INCDIR) 			\
		 -o yrsh-debug										\
		 $(OBJDEBS) $(OBJDIR)/y.tab.o $(OBJDIR)/lex.yy.o	\
		 $(LDFLAGS)

$(TARGET):  $(OBJECTS) $(HEADERS) 
	$(CC) $(CFLAGS) -I$(SRCDIR) -I$(INCDIR) 				\
		 -o $(TARGET) 										\
		 $(OBJECTS) $(OBJDIR)/y.tab.o $(OBJDIR)/lex.yy.o	\
		 $(LDFLAGS)

$(OBJDIR)/%-debug.o: $(SRCDIR)/%.c $(HEADERS)
	$(CC) $(DEBUG_FLAGS) -I$(SRCDIR) -I$(INCDIR) -c $< -o $@

$(OBJDIR)/%.o: $(SRCDIR)/%.c $(HEADERS)
	$(CC) $(CFLAGS) -I$(SRCDIR) -I$(INCDIR) -c $< -o $@

clean:
	rm -rf $(OBJDIR) $(TARGET) $(LEXDIR)/lex.yy.c $(LEXDIR)/y.tab.c $(INCDIR)/lex.yy.h $(INCDIR)/y.tab.h $(LEXDIR)/y.output
