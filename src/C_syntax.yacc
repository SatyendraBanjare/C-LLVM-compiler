%{
    #include <cstdio>
    #include <cstdlib>
    #include <iostream>

    void yyerror(char *) {};
    int yylex(void);

    int lineNumber = 1;
    void noSemicolonError();
%}

%token <string> INT FLOAT CHAR VOID                                                    /* Type Names */
%token <string> CSTRING CINT CDOUBLE CCHAR                                             /* Constants */
%token <string> VAR                                                                    /* Variables */
%token <token> IF ELSE FOR                                                             /* Control Flows */
%token <token> LEFT_PAREN RIGHT_PAREN LEFT_BRACK RIGHT_BRACK LEFT_BRACE RIGHT_BRACE    /* Enclosures */
%token <token> EQUAL NEQUAL GREATER_THAN GREATER_THAN_EQUAL LESS_THAN LESS_THAN_EQUAL AND OR ASSIGNMENT ADD SUB MUL DIV MODULO                                                                                 /* Binary Operators */
%token <token> BIT_AND BIT_OR BIT_SHIFT_RIGHT BIT_SHIFT_LEFT BIT_COMP BIT_XOR          /* Bitwise Operators */
%token <token> ADD_ASS SUB_ASS MUL_ASS DIV_ASS INCREMENT_OP DECREMENT_OP               /* Self Operators */
%token <token> DOT COMMA COLON SEMICOLON                                               /* Ending Symbols */
%token <token> RETURN                                                                  /* Others */

%left ASSIGNMENT
%left EQUAL NEQUAL GREATER_THAN GREATER_THAN_EQUAL LESS_THAN LESS_THAN_EQUAL
%left AND OR
%left ADD SUB ADD_ASS SUB_ASS MUL DIV MUL_ASS DIV_ASS
%left BIT_AND BIT_OR BIT_SHIFT_RIGHT BIT_SHIFT_LEFT BIT_COMP BIT_XOR

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
