%{
    #include <string>
    #include <iostream>
    #include "AST_tree.h"
    #include "C_syntax.hpp"
    #define TOKEN(t)    (yylval.token = t)
    extern int lineNumber;
%}

%option noyywrap
%x comment
%x comment_oneline

%%

"/*"                    BEGIN(comment);

<comment>[^*\n]*        /* eat anything that's not a '*' */
<comment>"*"+[^*/\n]*   /* eat up '*'s not followed by '/'s */
<comment>\n             ++lineNumber;
<comment>"*"+"/"        BEGIN(INITIAL);

"//"                    BEGIN(comment_oneline);
<comment_oneline>\n     BEGIN(INITIAL);

"extern"                        return TOKEN(EXTERN);
"return"                        return TOKEN(RETURN);

"int"                           { yylval.string = new string(yytext, yyleng); return INT; }
"double"                        { yylval.string = new string(yytext, yyleng); return DOUBLE; }
"char"                          { yylval.string = new string(yytext, yyleng); return CHAR; }
"void"                          { yylval.string = new string(yytext, yyleng); return VOID; }

"const"                         { yylval.string = new string(yytext, yyleng); return CONST; }

"if"                            return TOKEN(IF);
"else"                          return TOKEN(ELSE);
"for"                           return TOKEN(FOR);
"while"                         return TOKEN(WHILE);
"break"                         return TOKEN(BREAK);
"continue"                      return TOKEN(CONTINUE);

["].*["]                        {
                                    yylval.string = new string(yytext, yyleng);
                                    yylval.string->erase(yylval.string->begin());
                                    yylval.string->erase(yylval.string->end() - 1);
                                    return CSTR;
                                }
[_A-Za-z][_0-9A-Za-z]*          { yylval.string = new string(yytext, yyleng); return VAR; }
[0-9]+                          { yylval.string = new string(yytext, yyleng); return CINT; }
[0-9]+\.[0-9]*                  { yylval.string = new string(yytext, yyleng); return CDOUBLE; }
['].[']                         {
                                    yylval.string = new string(yytext, yyleng);
                                    yylval.string->erase(yylval.string->begin());
                                    yylval.string->erase(yylval.string->end() - 1);
                                    return CCHAR;
                                }

"("                             return TOKEN(LPAREN);
")"                             return TOKEN(RPAREN);
"["                             return TOKEN(LBRACK);
"]"                             return TOKEN(RBRACK);
"{"                             return TOKEN(LBRACE);
"}"                             return TOKEN(RBRACE);

"="                             return TOKEN(EQUAL);

"=="                            return TOKEN(EQ);
"!="                            return TOKEN(NE);
">"                             return TOKEN(GR);
">="                            return TOKEN(GE);
"<"                             return TOKEN(LW);
"<="                            return TOKEN(LE);

"&&"                            return TOKEN(AND);
"||"                            return TOKEN(OR);

"+"                             return TOKEN(ADD);
"-"                             return TOKEN(SUB);
"*"                             return TOKEN(MUL);
"/"                             return TOKEN(DIV);
"%"                             return TOKEN(MODULO);

"&"                             return TOKEN(BIT_AND);
"|"                             return TOKEN(BIT_OR);
"^"                             return TOKEN(BIT_XOR);

">>"                            return TOKEN(BIT_SHIFT_RIGHT);
"<<"                            return TOKEN(BIT_SHIFT_LEFT);


"++"                            return TOKEN(INCREMENT_OP);
"--"                            return TOKEN(DECREMENT_OP);

"+="                            return TOKEN(SADD);
"-="                            return TOKEN(SSUB);
"*="                            return TOKEN(SMUL);
"/="                            return TOKEN(SDIV);

"."                             return TOKEN(DOT);
","                             return TOKEN(COMMA);
":"                             return TOKEN(COLON);
";"                             return TOKEN(SEMICOLON);

[ \t\r]*                        ;

"\n"                            lineNumber += 1;

^"#include ".+                  ;

.                               cout << "Unknown token! " << yytext << endl; yyterminate();

%%
