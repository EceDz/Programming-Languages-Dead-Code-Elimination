%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_STATEMENTS 1000
#define MAX_LIVE_VARS 5
#define MAX_VAR_NAME 100

extern int yylex();
extern int yyparse();
extern FILE *yyin;
void yyerror(const char *s);

typedef struct {
    char dest[MAX_VAR_NAME];
    char op1[MAX_VAR_NAME];
    char op2[MAX_VAR_NAME];
    char operator;
    int is_const1;
    int is_const2;
    int has_op2;
} Statement;

Statement statements[MAX_STATEMENTS];
int stmt_count = 0;

char live_vars[MAX_LIVE_VARS][MAX_VAR_NAME];
int live_var_count = 0;

typedef struct {
    char vars[MAX_STATEMENTS][MAX_VAR_NAME];
    int count;
} LiveSet;

LiveSet current_live_set;

Statement output_statements[MAX_STATEMENTS];
int output_count = 0;

void add_statement(char *dest, char *op1, char *op2, char op, int is_c1, int is_c2, int has_op);
void add_live_var(char *var);
int is_live(char *var);
void remove_from_live_set(char *var);
void add_to_live_set(char *var);
void process_dead_code_elimination();
void print_output();

%}

%union
{
    int num;
    char *str;
}

%token ASSIGN PLUS MINUS MULT DIV XOR SEMICOLON LBRACE RBRACE COMMA
%token<str> IDENTIFIER
%token<num> NUMBER

%%

program:
    statements live_list
    {
        process_dead_code_elimination();
        print_output();
    }
    ;

statements:
    statements statement
    |
    ;

statement:
    IDENTIFIER ASSIGN IDENTIFIER SEMICOLON
    {
        add_statement($1, $3, NULL, 0, 0, 0, 0);
    }
    |
    IDENTIFIER ASSIGN NUMBER SEMICOLON
    {
        char num_str[20];
        sprintf(num_str, "%d", $3);
        add_statement($1, num_str, NULL, 0, 1, 0, 0);
    }
    |
    IDENTIFIER ASSIGN IDENTIFIER PLUS IDENTIFIER SEMICOLON
    {
        add_statement($1, $3, $5, '+', 0, 0, 1);
    }
    |
    IDENTIFIER ASSIGN IDENTIFIER PLUS NUMBER SEMICOLON
    {
        char num_str[20];
        sprintf(num_str, "%d", $5);
        add_statement($1, $3, num_str, '+', 0, 1, 1);
    }
    |
    IDENTIFIER ASSIGN NUMBER PLUS IDENTIFIER SEMICOLON
    {
        char num_str[20];
        sprintf(num_str, "%d", $3);
        add_statement($1, num_str, $5, '+', 1, 0, 1);
    }
    |
    IDENTIFIER ASSIGN NUMBER PLUS NUMBER SEMICOLON
    {
        char num_str1[20], num_str2[20];
        sprintf(num_str1, "%d", $3);
        sprintf(num_str2, "%d", $5);
        add_statement($1, num_str1, num_str2, '+', 1, 1, 1);
    }
    |
    IDENTIFIER ASSIGN IDENTIFIER MINUS IDENTIFIER SEMICOLON
    {
        add_statement($1, $3, $5, '-', 0, 0, 1);
    }
    |
    IDENTIFIER ASSIGN IDENTIFIER MINUS NUMBER SEMICOLON
    {
        char num_str[20];
        sprintf(num_str, "%d", $5);
        add_statement($1, $3, num_str, '-', 0, 1, 1);
    }
    |
    IDENTIFIER ASSIGN NUMBER MINUS IDENTIFIER SEMICOLON
    {
        char num_str[20];
        sprintf(num_str, "%d", $3);
        add_statement($1, num_str, $5, '-', 1, 0, 1);
    }
    |
    IDENTIFIER ASSIGN NUMBER MINUS NUMBER SEMICOLON
    {
        char num_str1[20], num_str2[20];
        sprintf(num_str1, "%d", $3);
        sprintf(num_str2, "%d", $5);
        add_statement($1, num_str1, num_str2, '-', 1, 1, 1);
    }
    |
    IDENTIFIER ASSIGN IDENTIFIER MULT IDENTIFIER SEMICOLON
    {
        add_statement($1, $3, $5, '*', 0, 0, 1);
    }
    |
    IDENTIFIER ASSIGN IDENTIFIER MULT NUMBER SEMICOLON
    {
        char num_str[20];
        sprintf(num_str, "%d", $5);
        add_statement($1, $3, num_str, '*', 0, 1, 1);
    }
    |
    IDENTIFIER ASSIGN NUMBER MULT IDENTIFIER SEMICOLON
    {
        char num_str[20];
        sprintf(num_str, "%d", $3);
        add_statement($1, num_str, $5, '*', 1, 0, 1);
    }
    |
    IDENTIFIER ASSIGN NUMBER MULT NUMBER SEMICOLON
    {
        char num_str1[20], num_str2[20];
        sprintf(num_str1, "%d", $3);
        sprintf(num_str2, "%d", $5);
        add_statement($1, num_str1, num_str2, '*', 1, 1, 1);
    }
    |
    IDENTIFIER ASSIGN IDENTIFIER DIV IDENTIFIER SEMICOLON
    {
        add_statement($1, $3, $5, '/', 0, 0, 1);
    }
    |
    IDENTIFIER ASSIGN IDENTIFIER DIV NUMBER SEMICOLON
    {
        char num_str[20];
        sprintf(num_str, "%d", $5);
        add_statement($1, $3, num_str, '/', 0, 1, 1);
    }
    |
    IDENTIFIER ASSIGN NUMBER DIV IDENTIFIER SEMICOLON
    {
        char num_str[20];
        sprintf(num_str, "%d", $3);
        add_statement($1, num_str, $5, '/', 1, 0, 1);
    }
    |
    IDENTIFIER ASSIGN NUMBER DIV NUMBER SEMICOLON
    {
        char num_str1[20], num_str2[20];
        sprintf(num_str1, "%d", $3);
        sprintf(num_str2, "%d", $5);
        add_statement($1, num_str1, num_str2, '/', 1, 1, 1);
    }
    |
    IDENTIFIER ASSIGN IDENTIFIER XOR IDENTIFIER SEMICOLON
    {
        add_statement($1, $3, $5, '^', 0, 0, 1);
    }
    |
    IDENTIFIER ASSIGN IDENTIFIER XOR NUMBER SEMICOLON
    {
        char num_str[20];
        sprintf(num_str, "%d", $5);
        add_statement($1, $3, num_str, '^', 0, 1, 1);
    }
    |
    IDENTIFIER ASSIGN NUMBER XOR IDENTIFIER SEMICOLON
    {
        char num_str[20];
        sprintf(num_str, "%d", $3);
        add_statement($1, num_str, $5, '^', 1, 0, 1);
    }
    |
    IDENTIFIER ASSIGN NUMBER XOR NUMBER SEMICOLON
    {
        char num_str1[20], num_str2[20];
        sprintf(num_str1, "%d", $3);
        sprintf(num_str2, "%d", $5);
        add_statement($1, num_str1, num_str2, '^', 1, 1, 1);
    }
    ;

live_list:
    LBRACE var_list RBRACE
    ;

var_list:
    IDENTIFIER
    {
        add_live_var($1);
    }
    |
    var_list COMMA IDENTIFIER
    {
        add_live_var($3);
    }
    ;

%%

void add_statement(char *dest, char *op1, char *op2, char op, int is_c1, int is_c2, int has_op) {
    strcpy(statements[stmt_count].dest, dest);
    strcpy(statements[stmt_count].op1, op1);
    if (op2 != NULL)
        strcpy(statements[stmt_count].op2, op2);
    else
        statements[stmt_count].op2[0] = '\0';
    statements[stmt_count].operator = op;
    statements[stmt_count].is_const1 = is_c1;
    statements[stmt_count].is_const2 = is_c2;
    statements[stmt_count].has_op2 = has_op;
    stmt_count++;
}

void add_live_var(char *var) {
    if (live_var_count < MAX_LIVE_VARS) {
        strcpy(live_vars[live_var_count], var);
        live_var_count++;
    }
}

int is_live(char *var) {
    for (int i = 0; i < current_live_set.count; i++) {
        if (strcmp(current_live_set.vars[i], var) == 0)
            return 1;
    }
    return 0;
}

void remove_from_live_set(char *var) {
    for (int i = 0; i < current_live_set.count; i++) {
        if (strcmp(current_live_set.vars[i], var) == 0) {
            for (int j = i; j < current_live_set.count - 1; j++) {
                strcpy(current_live_set.vars[j], current_live_set.vars[j + 1]);
            }
            current_live_set.count--;
            return;
        }
    }
}

void add_to_live_set(char *var) {
    if (!is_live(var)) {
        strcpy(current_live_set.vars[current_live_set.count], var);
        current_live_set.count++;
    }
}

void process_dead_code_elimination() {
    current_live_set.count = 0;
    for (int i = 0; i < live_var_count; i++) {
        add_to_live_set(live_vars[i]);
    }

    for (int i = stmt_count - 1; i >= 0; i--) {
        if (is_live(statements[i].dest)) {
            output_statements[output_count] = statements[i];
            output_count++;

            if (!statements[i].is_const1) {
                add_to_live_set(statements[i].op1);
            }
            if (statements[i].has_op2 && !statements[i].is_const2) {
                add_to_live_set(statements[i].op2);
            }

            remove_from_live_set(statements[i].dest);
        }
    }
}

void print_output() {
    for (int i = output_count - 1; i >= 0; i--) {
        printf("%s=", output_statements[i].dest);
        printf("%s", output_statements[i].op1);
        
        if (output_statements[i].has_op2) {
            printf("%c", output_statements[i].operator);
            printf("%s", output_statements[i].op2);
        }
        printf(";\n");
    }
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        fprintf(stderr, "Error: Cannot open file %s\n", argv[1]);
        return 1;
    }

    yyparse();
    fclose(yyin);
    return 0;
}
