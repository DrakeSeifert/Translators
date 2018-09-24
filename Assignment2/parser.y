%{
#include <iostream>
//#include <map>
#include <string>
#include <list>

#include "parser.hpp"

using std::cout;
using std::endl;

//std::map<std::string, float> symbols;
std::list<std::string> symbols;
std::string prog = "";

void yyerror(YYLTYPE* loc, const char* err);
extern int yylex();
%}

%union {
	std::string* str;
	int token;
}

%locations

%define api.pure full
%define api.push-pull push

//%token <str> IDENTIFIER
//%token <number> INTEGER FLOAT
%token <str> IDENTIFIER
%token <str> INTEGER FLOAT
%token <str> BOOLEAN
%token <token> PLUS MINUS TIMES DIVIDEDBY
%token <token> COLON LPAREN RPAREN ASSIGN EQ NEQ GT GTE LT LTE
%token <token> IF ELIF ELSE WHILE BREAK NEWLINE
%token <token> AND OR NOT
%token <token> INDENT DEDENT

%type <str> cfg
%type <str> program
%type <str> assign_statement
%type <str> if_block
%type <str> elif_block
%type <str> else_block
%type <str> while_block
%type <str> body
%type <str> body_contents
%type <str> expr
%type <str> expr_num
%type <str> expr_bool
%type <str> assignment
%type <str> comparison
%type <str> equality

//%left PLUS MINUS
//%left TIMES DIVIDEDBY
%left OR
%left AND
%left PLUS MINUS
%left TIMES DIVIDEDBY
%left EQ NEQ GT GTE LT LTE
%right NOT

%start cfg

%%

cfg
	: program
		{ prog += *$1; }
	;

program
	: program assign_statement
		{ $$ = new std::string(*$1 + *$2); }
	| program if_block  
		{ $$ = new std::string(*$1 + *$2); }
	| program while_block
		{ $$ = new std::string(*$1 + *$2); }
	| assign_statement
		{ $$ = new std::string(*$1); }
	| if_block
		{ $$ = new std::string(*$1); }
	| while_block
		{ $$ = new std::string(*$1); }
	;

assign_statement
	: IDENTIFIER ASSIGN expr NEWLINE
		{ $$ = new std::string(*$1 + " = " + *$3 + ";\n");
		  symbols.push_back(*$1); }
	;

if_block
	: IF expr COLON NEWLINE body
		{ $$ = new std::string("if (" + *$2 + ") {\n" + *$5 + "}\n"); }
	| IF expr COLON NEWLINE body elif_block
		{ $$ = new std::string("if (" + *$2 + ") {\n" + *$5 + "} " + *$6); }
	| IF expr COLON NEWLINE body elif_block else_block
		{ $$ = new std::string("if (" + *$2 + ") {\n" + *$5 + "} " + *$6 + *$7); }
	| IF expr COLON NEWLINE body else_block
		{ $$ = new std::string("if (" + *$2 + ") {\n" + *$5 + "} " + *$6); }
	;

elif_block
	: ELIF expr COLON NEWLINE body
		{ $$ = new std::string("else if (" + *$2 + ") {\n" + *$5 + "}\n"); }
	| elif_block elif_block
		{ $$ = new std::string(*$1 + *$2); }
	;

else_block
	: ELSE COLON NEWLINE body
		{ $$ = new std::string("else {\n" + *$4 + "}\n"); }
	;

while_block
	: WHILE expr COLON NEWLINE body
		{ $$ = new std::string("while (" + *$2 + ") {\n" + *$5 + "}\n"); }
	;

body
	: INDENT body_contents DEDENT
		{ $$ = new std::string(*$2); }
	;

body_contents
	: body
		{ $$ = new std::string(*$1); }
	| program
		{ $$ = new std::string(*$1); }
	| program BREAK NEWLINE
		{ $$ = new std::string(*$1 + "break;\n"); }
	| BREAK NEWLINE
		{ $$ = new std::string("break;\n"); }
	; 

expr
	: expr_num
		{ $$ = new std::string(*$1); }
	| expr_bool
		{ $$ = new std::string(*$1); }
	| LPAREN expr RPAREN
		{ $$ = new std::string("(" + *$2 + ")"); }
	;

expr_num
	: LPAREN expr_num RPAREN
		{ $$ = new std::string("(" + *$2 + ")"); }
	| expr_num PLUS expr_num
		{ $$ = new std::string(*$1 + " + " + *$3); }
	| expr_num MINUS expr_num
		{ $$ = new std::string(*$1 + " - " + *$3); }
	| expr_num TIMES expr_num
		{ $$ = new std::string(*$1 + " * " + *$3); }
	| expr_num DIVIDEDBY expr_num
		{ $$ = new std::string(*$1 + " / " + *$3); }
	| INTEGER
		{ $$ = new std::string(*$1); }
	| FLOAT
		{ $$ = new std::string(*$1); }
	| IDENTIFIER
		{ $$ = new std::string(*$1);
		  symbols.push_back(*$1); }
	;

expr_bool
	: LPAREN expr_bool RPAREN
		{ $$ = new std::string("(" + *$2 + ")"); }
	| expr_bool comparison expr_bool
		{ $$ = new std::string(*$1 + *$2 + *$3); }
	| expr_bool AND expr_bool
		{ $$ = new std::string(*$1 + " && " + *$3); }
	| expr_bool OR expr_bool
		{ $$ = new std::string(*$1 + " || " + *$3); }
	| NOT expr_bool
		{ $$ = new std::string("!" + *$2); }
	| expr_num assignment expr_num
		{ $$ = new std::string(*$1 + *$2 + *$3); }
	| BOOLEAN
		{ $$ = new std::string(*$1); }
	| IDENTIFIER
		{ $$ = new std::string(*$1); }
	;

assignment
	: comparison
		{ $$ = new std::string(*$1); }
	| equality
		{ $$ = new std::string(*$1); }
	;

comparison
	: EQ
		{ $$ = new std::string(" == "); }
	| NEQ
		{ $$ = new std::string(" != "); }
	;

equality
	: GT
		{ $$ = new std::string(" > "); }
	| GTE
		{ $$ = new std::string(" >= "); }
	| LT
		{ $$ = new std::string(" < "); }
	| LTE
		{ $$ = new std::string(" <= "); }
	;

%%

void yyerror(YYLTYPE* loc, const char* err) {
	std::cerr << "ERROR: " << err << std::endl;
}
