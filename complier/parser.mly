
%{ open Ast %}

/* Arithmetic Operators */
%token PLUS MINUS TIMES DIVIDE MOD

/* Separator */
%token SEMICOLUMN SEQUENCE ASSIGN COLUMN DOT

/* Relational Operators */
%token GREATER GREATEREQUAL SMALLER SMALLEREQUAL EQUAL NOTEQUAL

/* Logical Operators & Keywords*/
%token AND OR NOT IF ELSE FOR BREAK CONTINUE IN

/* Graph operator */
%token LINK RIGHTLINK LEFTLINK

/* Primary Type */
%token INT FLOAT STRING BOOL NODE GRAPH LIST DICT NULL

/* Quote */
%token QUOTE

/* Boolean  */
%token TRUE FALSE

/* Bracket */
%token LEFTBRACKET RIGHTBRACKET LEFTCURLYBRACKET RIGHTCURLYBRACKET LEFTROUNDBRACKET RIGHTROUNDBRACKET
/* EOF */
%token EOF

/* Identifiers */
%token <string> ID

/* Literals */
%token <int> INT_LITERAL
%token <string> STRING_LITERAL
%token <float> FLOAT_LITERAL

/* Order */
%right ASSIGN
%left AND OR
%left EQUAL NOTEQUAL
%left GREATER SMALLER GREATEREQUAL SMALLEREQUAL
%left PLUS MINUS
%left TIMES DIVIDE MOD
%right NOT
%right LEFTROUNDBRACKET
%left  RIGHTROUNDBRACKET
%right DOT

%%

expr:
  literals {$1}
| expr PLUS         expr 					{ Binop($1, Add,   $3) }
| expr MINUS        expr 					{ Binop($1, Sub,   $3) }
| expr TIMES        expr 					{ Binop($1, Mult,  $3) }
| expr DIVIDE       expr 					{ Binop($1, Div,   $3) }
| expr EQUAL        expr 					{ Binop($1, Equal, $3) }
| expr NOTEQUAL     expr 					{ Binop($1, Neq,   $3) }
| expr SMALLER      expr 					{ Binop($1, Less,  $3) }
| expr SMALLEREQUAL expr 					{ Binop($1, Leq,   $3) }
|	expr GREATER      expr 					{ Binop($1, Greater,  $3) }
| expr GREATEREQUAL expr 					{ Binop($1, Geq,   $3) }
| expr AND          expr 					{ Binop($1, And,   $3) }
| expr MOD          expr 					{ Binop($1, Mod,   $3)}
| NOT  expr 							        { Unop (Not,   $2) }
| expr OR     expr 					      { Binop($1, Or,    $3) }
| expr ASSIGN expr 					      { Assign($1, $3) }
| MINUS expr 							        { Unop (Sub, $2) }

literals:
  INT_LITERAL {Int_Lit($1)}
| FLOAT_LITERAL {Float_Lit($1)}