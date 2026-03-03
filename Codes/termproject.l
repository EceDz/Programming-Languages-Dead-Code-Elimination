%{
#include <stdio.h>
#include <string.h>
#include "termproject.tab.h"
%}

%%
"="             { return ASSIGN; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MULT; }
"/"             { return DIV; }
"^"             { return XOR; }
";"             { return SEMICOLON; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }
","             { return COMMA; }

[a-zA-Z][a-zA-Z0-9_]*  { yylval.str = strdup(yytext); return IDENTIFIER; }
[0-9]+        { yylval.num = atoi(yytext); return NUMBER; }

[ \t\n]+        { /* ignore whitespace */ }
.               { /* ignore other characters */ }

%%

int yywrap() { return 1; }
