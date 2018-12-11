%{
    #include <string>
    #include <iostream>
    
    #define TOKEN(t)    (yylval.token = t)
    
    extern int LineNumber;
%}

%option noyywrap
%x comment
%x comment_oneline

%%

[ \t\r]*                        ;

"\n"                            LineNumber += 1;

^"#include ".+                  ;


"/*"                            BEGIN(comment);
<comment>[^*\n]*                /* eat anything that's not a '*' */
<comment>"*"+[^*/\n]*           /* eat up '*'s not followed by '/'s */
<comment>\n                     ++LineNumber;
<comment>"*"+"/"                BEGIN(INITIAL);


"//"                            BEGIN(comment_oneline);
<comment_oneline>\n             BEGIN(INITIAL);


"int"                           { yylval.string = new string(yytext, yyleng); return INT; }
"float"                         { yylval.string = new string(yytext, yyleng); return FLOAT; }
"char"                          { yylval.string = new string(yytext, yyleng); return CHAR; }
"void"                          { yylval.string = new string(yytext, yyleng); return VOID; }


["].*["]                        {
                                    yylval.string = new string(yytext, yyleng);
                                    yylval.string->erase(yylval.string->begin());
                                    yylval.string->erase(yylval.string->end() - 1);
                                    return CSTRING;
                                }
[_A-Za-z][_0-9A-Za-z]*          { yylval.string = new string(yytext, yyleng); return VAR; }
[0-9]+                          { yylval.string = new string(yytext, yyleng); return CINT; }
[0-9]+\.[0-9]*                  { yylval.string = new string(yytext, yyleng); return CDOUBLE; }
[0-9]+\.[0-9]*                  { yylval.string = new string(yytext, yyleng); return CFLOAT; }
['].[']                         {
                                    yylval.string = new string(yytext, yyleng);
                                    yylval.string->erase(yylval.string->begin());
                                    yylval.string->erase(yylval.string->end() - 1);
                                    return CCHAR;
                                }

"if"                            return TOKEN(IF);
"else"                          return TOKEN(ELSE);
"for"                           return TOKEN(FOR);

"("                             return TOKEN(LEFT_PAREN);
")"                             return TOKEN(RIGHT_PAREN);
"["                             return TOKEN(LEFT_BRACK);
"]"                             return TOKEN(RIGHT_BRACK);
"{"                             return TOKEN(LEFT_BRACE);
"}"                             return TOKEN(RIGHT_BRACE);

"="                             return TOKEN(ASSIGNMENT);

"=="                            return TOKEN(EQUAL);
"!="                            return TOKEN(NEQUAL);
">"                             return TOKEN(GREATER_THAN);
">="                            return TOKEN(GREATER_THAN_EQUAL);
"<"                             return TOKEN(LESS_THAN);
"<="                            return TOKEN(LESS_THAN_EQUAL);

"&&"                            return TOKEN(AND);
"||"                            return TOKEN(OR);

"+"                             return TOKEN(ADD);
"-"                             return TOKEN(SUB);
"*"                             return TOKEN(MUL);
"/"                             return TOKEN(DIV);
"%"                             return TOKEN(MODULO);

"&"                             return TOKEN(BIT_AND);
"|"                             return TOKEN(BIT_OR);
">>"                            return TOKEN(BIT_SHIFT_RIGHT);
"<<"                            return TOKEN(BIT_SHIFT_LEFT);
"~"                             return TOKEN(BIT_COMP);
"^"                             return TOKEN(BIT_XOR);

"+="                            return TOKEN(ADD_ASS);
"-="                            return TOKEN(SUB_ASS);
"*="                            return TOKEN(MUL_ASS);
"/="                            return TOKEN(DIV_ASS);

"++"                            return TOKEN(INCREMENT_OP);
"--"                            return TOKEN(DECREMENT_OP);

"."                             return TOKEN(DOT);
","                             return TOKEN(COMMA);
":"                             return TOKEN(COLON);
";"                             return TOKEN(SEMICOLON);

.                               cout << "Unknown token! " << yytext << endl; yyterminate();

"return"                        return TOKEN(RETURN);

%%
