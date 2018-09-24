%{
#include <iostream>
#include <map>

std::map<std::string, float> symbols;

bool _error = false;

void yyerror(const char* err);
extern int yylex();
%}

%union {
  float value;
  std::string* str;
  int token;
}

/* %define api.value.type { std::string* } */
%locations

%define parse.error verbose

%token <str> IDENTIFIER
%token <value> NUMBER
%token <token> EQUALS PLUS MINUS TIMES DIVIDEDBY
%token <token> SEMICOLON LPAREN RPAREN

%type <value> expression

%left PLUS MINUS
%left TIMES DIVIDEDBY
/* %right */
/* %nonassoc */
/* %precedence */

%start program

%%

program
  : program statement
  | statement
  ;

statement
  : IDENTIFIER EQUALS expression SEMICOLON { symbols[*$1] = $3; delete $1; }
  | error SEMICOLON { std::cerr << "Error: bad statement on line " << @1.first_line << std::endl; _error = true; }
  ;

expression
  : LPAREN expression RPAREN { $$ = $2; }
  | expression PLUS expression { $$ = $1 + $3; }
  | expression MINUS expression { $$ = $1 - $3; }
  | expression TIMES expression { $$ = $1 * $3; }
  | expression DIVIDEDBY expression { $$ = $1 / $3; }
  | NUMBER { $$ = $1; }
  | IDENTIFIER {
    if (symbols.count(*$1)) {
      $$ = symbols[*$1];
    } else {
      std::cerr << "Error: unknown symbol " << *$1 << " at line " << @1.first_line << std::endl;
      _error = true;
      YYERROR;
    }
    delete $1;
  }
  ;

%%

void yyerror(const char* err) {
  std::cerr << "Error: " << err << std::endl;
}
