CC = gcc
LEX = flex
YACC = bison

all: termproject

termproject: termproject.tab.c lex.yy.c
	@$(CC) -o termproject lex.yy.c termproject.tab.c

termproject.tab.c: termproject.y
	@$(YACC) -d termproject.y

lex.yy.c: termproject.l termproject.tab.h
	@$(LEX) termproject.l

termproject.tab.h: termproject.tab.c

clean:
	rm -f termproject lex.yy.c termproject.tab.c termproject.tab.h

test: termproject
	@echo "Running test 1..."
	./termproject input1.txt
	@echo "\nRunning test 2..."
	./termproject input2.txt
	@echo "\nRunning test 3..."
	./termproject input3.txt
