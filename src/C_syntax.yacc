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
%token <token> ADD_SELF SUB_SELF MUL_SELF DIV_SELF INCREMENT_OP DECREMENT_OP               /* Self Operators */
%token <token> DOT COMMA COLON SEMICOLON                                               /* Ending Symbols */
%token <token> RETURN                                                                  /* Others */

%left ASSIGNMENT
%left EQUAL NEQUAL GREATER_THAN GREATER_THAN_EQUAL LESS_THAN LESS_THAN_EQUAL
%left AND OR
%left ADD SUB ADD_SELF SUB_SELF MUL DIV MUL_SELF DIV_SELF
%left BIT_AND BIT_OR BIT_SHIFT_RIGHT BIT_SHIFT_LEFT BIT_COMP BIT_XOR

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%type <var> variable type
%type <vars> function_args
%type <expr> expr const logic_expr
%type <exprs> invoke_args
%type <block> program block global_block local_block
%type <statement> global_statement local_statement
%type <statement> variable_declaration
%type <statement> array_declaration function_declaration extern_function_declaration
%type <statement> condition loop
%type <token> compare

%union {
    int token;
    string *string;
    VariableExprNode *var;
    ExprNode *expr;
    vector<VarDecStatementNode*> *vars;
    vector<ExprNode*> *exprs;
    BlockExprNode *block;
    StatementNode *statement;
    VarDecStatementNode *var_dec;
}

program: global_block { root = $1; };

global_block: global_statement              { $$ = new BlockExprNode(); $$->statements->push_back($<statement>1); }
            | global_block global_statement { $$->statements->push_back($<statement>2); }
            ;

global_statement: function_declaration                  { $$ = $1; }
                | extern_function_declaration SEMICOLON { $$ = $1; }
                | extern_function_declaration error     { noSemicolonError(); $$ = $1;}
                | expr SEMICOLON                        { $$ = new ExprStatementNode($1); }
                ;

function_declaration: type variable LPAREN function_args RPAREN block { $$ = new FuncDecStatementNode($1, $2, $4, $6); };

extern_function_declaration: EXTERN type variable LPAREN function_args RPAREN { $$ = new ExternFuncDecStatementNode($2, $3, $5); };

type: INT       { $$ = new VariableExprNode(*$1, E_INT); delete $1; }
    | DOUBLE    { $$ = new VariableExprNode(*$1, E_DOUBLE); delete $1; }
    | CHAR      { $$ = new VariableExprNode(*$1, E_CHAR); delete $1; }
    | VOID      { $$ = new VariableExprNode(*$1, E_VOID); delete $1; }
    | CONST type { $$ = new VariableExprNode(*$1, E_CONST); delete $1;}
    ;

variable: VAR   { $$ = new VariableExprNode(*$1); delete $1; };

function_args: /* NULL */                               { $$ = new vector<VarDecStatementNode*>(); }
             | variable_declaration                     { $$ = new vector<VarDecStatementNode*>(); $$->push_back($<var_dec>1); }
             | function_args COMMA variable_declaration { $1->push_back($<var_dec>3); $$ = $1; }
             ;

block: LBRACE local_block RBRACE { $$ = $2; }
     | local_statement           { $$ = new BlockExprNode(); $$->statements->push_back($<statement>1); }
     ;

variable_declaration: type variable             { $2->_type = $1->_type; $$ = new VarDecStatementNode($1, $2); addNewVar($2->name, $2->_type);}
                    | type variable EQUAL expr  { $2->_type = $1->_type; $$ = new VarDecStatementNode($1, $2, $4); addNewVar($2->name, $2->_type); checkExprType($2, $4); }
                    ;

local_block: local_statement             { $$ = new BlockExprNode(); $$->statements->push_back($<statement>1); }
           | local_block local_statement { $$->statements->push_back($<statement>2); }
           ;

local_statement: variable_declaration SEMICOLON { $$ = $1; }
               | array_declaration SEMICOLON    { $$ = $1; }
               | condition                      { $$ = $1; }
               | loop                           { $$ = $1; }
               | expr SEMICOLON                 { $$ = new ExprStatementNode($1); }
               | RETURN expr SEMICOLON          { $$ = new ReturnStatementNode($2); }
               | SEMICOLON                      { /* NULL */ }
               | variable_declaration error     { noSemicolonError(); $$ = $1; }
               | array_declaration error        { noSemicolonError(); $$ = $1; }
               | expr error                     { noSemicolonError(); $$ = new ExprStatementNode($1); }
               ;

expr: variable                                  { $<var>$ = $1; }
    | const                                     { $$ = $1; }
    | expr ADD expr                             { $$ = new OperatorExprNode($1, $2, $3); $$->_type = checkExprType($1, $3); }
    | expr SUB expr                             { $$ = new OperatorExprNode($1, $2, $3); $$->_type = checkExprType($1, $3); }
    | expr MUL expr                             { $$ = new OperatorExprNode($1, $2, $3); $$->_type = checkExprType($1, $3); }
    | expr DIV expr                             { $$ = new OperatorExprNode($1, $2, $3); $$->_type = checkExprType($1, $3); }
    | variable SADD expr                        { $$ = new OperatorExprNode($1, $2, $3); $$ = new AssignExprNode($1, $$); setVarType($1); $$->_type = checkExprType($1, $3);}
    | variable SSUB expr                        { $$ = new OperatorExprNode($1, $2, $3); $$ = new AssignExprNode($1, $$); setVarType($1); $$->_type = checkExprType($1, $3);}
    | variable SMUL expr                        { $$ = new OperatorExprNode($1, $2, $3); $$ = new AssignExprNode($1, $$); setVarType($1); $$->_type = checkExprType($1, $3);}
    | variable SDIV expr                        { $$ = new OperatorExprNode($1, $2, $3); $$ = new AssignExprNode($1, $$); setVarType($1); $$->_type = checkExprType($1, $3);}
    | expr compare expr                         { $$ = new OperatorExprNode($1, $2, $3); $$->_type = E_INT; }
    | variable EQUAL expr                       { $$ = new AssignExprNode($1, $3); setVarType($1); checkExprType($1, $3); $$->_type = $1->_type;}
    | variable LPAREN invoke_args RPAREN        { $$ = new FuncExprNode($1, $3); addNewVar($1->name, E_FUNC); setVarType($1); $$->_type = $1->_type;}
    | variable LBRACK expr RBRACK               { $$ = new IndexExprNode($1, $3); $$->_type = $1->_type; }
    | variable LBRACK expr RBRACK EQUAL expr    { $$ = new IndexExprNode($1, $3, $6); checkExprType($1, $6); $$->_type = $1->_type; }
    | variable LBRACK expr RBRACK SADD expr    { $$ = new IndexExprNode($1, $3); $$ = new OperatorExprNode($$, $5, $6); $$ = new IndexExprNode($1, $3, $$); checkExprType($1, $6); $$->_type = $1->_type; }
    | variable LBRACK expr RBRACK SSUB expr    { $$ = new IndexExprNode($1, $3); $$ = new OperatorExprNode($$, $5, $6); $$ = new IndexExprNode($1, $3, $$); checkExprType($1, $6); $$->_type = $1->_type; }
    | variable LBRACK expr RBRACK SMUL expr    { $$ = new IndexExprNode($1, $3); $$ = new OperatorExprNode($$, $5, $6); $$ = new IndexExprNode($1, $3, $$); checkExprType($1, $6); $$->_type = $1->_type; }
    | variable LBRACK expr RBRACK SDIV expr    { $$ = new IndexExprNode($1, $3); $$ = new OperatorExprNode($$, $5, $6); $$ = new IndexExprNode($1, $3, $$); checkExprType($1, $6); $$->_type = $1->_type; }
    | LPAREN expr RPAREN                        { $$ = $2; }
    | LPAREN type RPAREN expr                   { $$ = new CastExprNode($2, $4); $$->_type = $2->_type;}
    ;

array_declaration: type variable LBRACK CINT RBRACK                             { $$ = new ArrayDecStatementNode($1, $2, atol($4->c_str())); }
                 | type variable LBRACK RBRACK EQUAL CSTR                       { $2->_type = $1->_type; $$ = new ArrayDecStatementNode($1, $2, *$6); }
                 | type variable LBRACK RBRACK EQUAL LBRACE invoke_args RBRACE  { $2->_type = $1->_type; $$ = new ArrayDecStatementNode($1, $2, $7); }
                 ;

condition: IF LPAREN logic_expr RPAREN block %prec LOWER_THAN_ELSE   { $$ = new IfStatementNode($3, $5); }
         | IF LPAREN logic_expr RPAREN block ELSE block { $$ = new IfStatementNode($3, $5, $7); }
         ;

loop: FOR LPAREN expr SEMICOLON logic_expr SEMICOLON expr RPAREN block  { $$ = new ForStatementNode($3, $5, $7, $9); } ;

const: CINT         { $$ = new IntExprNode(atoi($1->c_str())); delete $1; }
     | CFLOAT       { $$ = new DoubleExprNode(atoi($1->c_str())); delete $1; }
     | CCHAR        { $$ = new CharExprNode($1->front()); delete $1; }
     | SUB CINT     { $$ = new IntExprNode(-atol($2->c_str())); delete $2; }
     | SUB CFLOAT   { $$ = new IntExprNode(-atof($2->c_str())); delete $2; }
     ;

compare: EQUAL                     { $$ = $1; }
       | NEQUAL                    { $$ = $1; }
       | GREATER_THAN              { $$ = $1; }
       | GREATER_THAN_EQUAL        { $$ = $1; }
       | LESS_THAN                 { $$ = $1; }
       | LESS_THAN_EQUAL           { $$ = $1; }
       ;

invoke_args: /* NULL */             { $$ = new vector<ExprNode*>(); }
           | expr                   { $$ = new vector<ExprNode*>(); $$->push_back($1); }
           | invoke_args COMMA expr { $1->push_back($3); $$ = $1; }
           ;

logic_expr: logic_expr OR logic_expr    { $$ = new OperatorExprNode($1, $2, $3); }
          | logic_expr AND logic_expr   { $$ = new OperatorExprNode($1, $2, $3); }
          | expr            { $$ = $1; }
          ;

%%

void addNewVar(string name, Valid_Type type) {
  map<string, Valid_Type>::iterator it;
  it = varTable.find(name);
  if (it == varTable.end()) {
    varTable[name] = type;
  } else if (type == V_FUNC) {
    varTable[name] = type;
  } else {
    cout << "line " << lineNumber << ": redefinition of variable " << name << " from (" << typeStr((*it).second) << ") to (" << typeStr(type) << ")." << endl;
    varTable[name] = type;
  }
}
string typeStr(Valid_Type type) {
    switch (type) {
    case V_VOID:
        return "void";
    case V_CONST:
        return "const";
    case V_INT:
        return "int";
    case V_CHAR:
        return "char";
    case V_DOUBLE:
        return "double";
    case V_PTR:
        return "pointer";
    case V_FUNC:
        return "function part";
    default:
        return "unknown";
    }
}

Valid_Type checkExprType(ExprNode *lhs, ExprNode *rhs) {
  if (lhs->_type == V_UNKNOWN) {
    cout << "line " << lineNumber << ": unknown expression type on lhs" << endl;
    return E_UNKNOWN;
  }
  if (rhs->_type == V_UNKNOWN) {
    cout << "line " << lineNumber << ": unknown expression type on rhs" << endl;
    return E_UNKNOWN;
  }
  Valid_Type i, j;
  i = lhs->_type > rhs->_type ? rhs->_type : lhs->_type;   // smaller one
  j = lhs->_type < rhs->_type ? rhs->_type : lhs->_type;   // bigger one

  if (j == V_FUNC) {
    return i;
  }
  if (i != j) {
    cout << "line " << lineNumber << ": implicitly convert type " << typeStr(i) << " to " << typeStr(j) << "." << endl;
  }
  return j;
}

void noSemicolonError() {
  cout << "line " << lineNumber << ": missed Semicolon." << endl;
}

void setVarType(VariableExprNode *var){
  map<string, Valid_Type>::iterator it;
  it = varTable.find(var->name);
  if (it == varTable.end()) {
    var->_type = V_UNKNOWN;
  } else {
    var->_type = (*it).second;
  }
}

void printVarTable() {
  std::map<std::string, Valid_Type>::iterator it;
  for (it = varTable.begin(); it != varTable.end(); it++) {
    cout << (*it).first << " : " << typeStr((*it).second) << std::endl;
  }
}
