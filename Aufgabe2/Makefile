LEX  = flex
YACC = bison
CC   = gcc
LD   = gcc

all: logic


input.c: input.l lex.tab.

input.tab.h: logic.y
	$(YACC) -d logic.y

logic.tab.c: logic.y
	$(YACC) -d logic.y

logic.tab.o: logic.tab.c

logic_check: input.o logic.tab.o
	$(LD) input.o logic.tab.o -o logic_check
