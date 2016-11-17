
%{ open Ast %}

/* Arithmetic Operators */
%token PLUS MINUS TIMES DIVIDE MOD

/* Separator */
%token SEMICOLUMN SEQUENCE ASSIGN COLUMN DOT

/* Relational Operators */
%token GREATER GREATEREQUAL SMALLER SMALLEREQUAL EQUAL NOTEQUAL

/* Logical Operators & Keywords*/
%token AND OR NOT IF ELSE FOR WHILE BREAK CONTINUE IN RETURN

/* Graph operator */
%token LINK RIGHTLINK LEFTLINK SIMILARITY AT AMPERSAND

/* Primary Type */
%token INT FLOAT STRING BOOL NODE GRAPH LIST DICT NULL

/* Quote */
%token QUOTE

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
%token <bool> BOOL_LITERAL

/* Order */
%right ASSIGN
%left AND OR
%left EQUAL NOTEQUAL
%left GREATER SMALLER GREATEREQUAL SMALLEREQUAL
%left PLUS MINUS
%left TIMES DIVIDE MOD
%right NOT
%right LINK RIGHTLINK LEFTLINK AMPERSAND
%left SIMILARITY AT
%right LEFTROUNDBRACKET
%left  RIGHTROUNDBRACKET
%right COLUMN
%right DOT

%start program
%type < Ast.program> program

%%

/* Program flow */
program:
| stmt_list EOF                         { List.rev $1 }

stmt_list:
| /* nothing */                         { [] }
| stmt_list stmt                        { $2 :: $1 }

stmt:
| expr SEMICOLUMN                       { Expr($1) }
| func_decl                             { Func($1) }
| RETURN expr SEMICOLUMN                { Return($2) }
| FOR LEFTROUNDBRACKET var_decl SEMICOLUMN for_expr SEMICOLUMN for_expr RIGHTROUNDBRACKET LEFTCURLYBRACKET stmt_list RIGHTCURLYBRACKET
  {For($3, $5, $7, List.rev $10)}
| IF LEFTROUNDBRACKET expr RIGHTROUNDBRACKET LEFTCURLYBRACKET stmt_list RIGHTCURLYBRACKET ELSE LEFTCURLYBRACKET stmt_list RIGHTCURLYBRACKET
  {If($3,List.rev $6,List.rev $10)}
| IF LEFTROUNDBRACKET expr RIGHTROUNDBRACKET LEFTCURLYBRACKET stmt_list RIGHTCURLYBRACKET
  {If($3,List.rev $6,[])}
| WHILE LEFTROUNDBRACKET expr RIGHTROUNDBRACKET LEFTCURLYBRACKET stmt_list RIGHTCURLYBRACKET
  {While($3, List.rev $6)}
| var_decl SEMICOLUMN                   { Var_dec($1)}

var_decl:
| var_type ID              { Local($1, $2, Noexpr) }
| var_type ID ASSIGN expr  { Local($1, $2, $4) }

var_type:
  INT 								  {Int_t}
| FLOAT 								{Float_t}
| STRING 								{String_t}
| BOOL {Bool_t}
| NODE {Node_t}
| GRAPH {Graph_t}
| LIST {List_t}
| DICT SMALLER INT GREATER {Dict_Int_t}
| DICT SMALLER FLOAT GREATER {Dict_Float_t}
| DICT SMALLER STRING GREATER {Dict_String_t}
| DICT SMALLER NODE GREATER {Dict_Node_t}
| DICT SMALLER GRAPH GREATER {Dict_Graph_t}

formal_list:
| /* nothing */               { [] }
| formal                      { [$1] }
| formal_list SEQUENCE formal { $3 :: $1 }


formal:
| var_type ID           { Formal($1, $2) }

func_decl:
| var_type ID LEFTROUNDBRACKET formal_list RIGHTROUNDBRACKET LEFTCURLYBRACKET stmt_list RIGHTCURLYBRACKET {
  {
    returnType = $1;
    name = $2;
    args = List.rev $4;
    body = List.rev $7;
  }
}


/* For loop decl*/
for_expr:
| /* nothing */                         { Noexpr }
| expr                                  { $1 }

expr:
  literals {$1}
| arith_ops                       { $1 }
| graph_ops                       { $1 }
| NODE LEFTROUNDBRACKET expr RIGHTROUNDBRACKET { Node($3) }
| ID 					                    { Id($1) }
| ID ASSIGN expr 					        { Assign($1, $3) }
| LEFTBRACKET list RIGHTBRACKET   			{ ListP(List.rev $2) }
| LEFTCURLYBRACKET dict RIGHTCURLYBRACKET 	{ DictP(List.rev $2) }
| LEFTROUNDBRACKET expr RIGHTROUNDBRACKET 	{ $2 }
| ID LEFTROUNDBRACKET list RIGHTROUNDBRACKET              { Call($1, $3) }

/* Lists */
list:
| /* nothing */                         { [] }
| expr                                  { [$1] }
| list SEQUENCE expr                    { $3 :: $1 }

list_graph:
| expr AMPERSAND expr         { { graphs = [$3]; edges = [$1] } }
| list_graph SEQUENCE expr AMPERSAND expr
    { { graphs = $5 :: ($1).graphs; edges = $3 :: ($1).edges } }

list_graph_literal:
| LEFTBRACKET list_graph RIGHTBRACKET   {
  { graphs = List.rev ($2).graphs; edges = List.rev ($2).edges }
}

dict_key_value:
| STRING_LITERAL COLUMN expr { (String_Lit($1), $3) }

/* dict */
dict:
| /* nothing */                     { [] }
| dict_key_value 								    { [$1] }
| dict SEQUENCE dict_key_value 			{$3 :: $1}

arith_ops:
| expr PLUS         expr 					{ Binop($1, Add,   $3) }
| expr MINUS        expr 					{ Binop($1, Sub,   $3) }
| expr TIMES        expr 					{ Binop($1, Mult,  $3) }
| expr DIVIDE       expr 					{ Binop($1, Div,   $3) }
| expr EQUAL        expr 					{ Binop($1, Equal, $3) }
| expr NOTEQUAL     expr 					{ Binop($1, Neq,   $3) }
| expr SMALLER      expr 					{ Binop($1, Less,  $3) }
| expr SMALLEREQUAL expr 					{ Binop($1, Leq,   $3) }
| expr GREATER      expr 					{ Binop($1, Greater,  $3) }
| expr GREATEREQUAL expr 					{ Binop($1, Geq,   $3) }
| expr AND          expr 					{ Binop($1, And,   $3) }
| expr MOD          expr 					{ Binop($1, Mod,   $3) }
| expr OR     expr                { Binop($1, Or,    $3) }
| NOT  expr 							        { Unop (Not,   $2) }
| MINUS expr 							        { Unop (Sub, $2) }
| expr SIMILARITY expr            { Binop($1, RootAs, $3) }
| expr AT AT expr                 { Binop($1, ListEdgesAt, $4) }
| expr AT expr                    { Binop($1, ListNodesAt, $3) }

graph_ops:
| expr LINK expr                      { Graph_Link($1, Double_Link, $3, Null) }
| expr LINK list_graph_literal        { Graph_Link($1, Double_Link, ListP(($3).graphs), ListP(($3).edges)) }
| expr LINK expr AMPERSAND expr       { Graph_Link($1, Double_Link, $5, $3) }
| expr RIGHTLINK expr                 { Graph_Link($1, Right_Link, $3, Null) }
| expr RIGHTLINK list_graph_literal   { Graph_Link($1, Right_Link, ListP(($3).graphs), ListP(($3).edges)) }
| expr RIGHTLINK expr AMPERSAND expr  { Graph_Link($1, Right_Link, $5, $3) }
| expr LEFTLINK expr                  { Graph_Link($1, Left_Link, $3, Null) }
| expr LEFTLINK list_graph_literal    { Graph_Link($1, Left_Link, ListP(($3).graphs), ListP(($3).edges)) }
| expr LEFTLINK expr AMPERSAND expr   { Graph_Link($1, Left_Link, $5, $3) }

literals:
  INT_LITERAL   	   {Num_Lit( Num_Int($1) )}
| FLOAT_LITERAL 	   {Num_Lit( Num_Float($1) )}
| STRING_LITERAL     {String_Lit($1) }
| BOOL_LITERAL       {Bool_lit($1) }