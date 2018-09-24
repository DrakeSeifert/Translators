%{
#include <iostream>
#include <set>
#include <list>

#include "AST.hpp"
#include "parser.hpp"

extern int yylex();
void yyerror(YYLTYPE* loc, const char* err);
std::string* translate_boolean_str(std::string* boolean_str);

using std::list;
AST root;
int id_gen = 1;
%}

%code requires{
	#include "AST.hpp"
}

%union {
	std::string *str;
	int token;
	list<AST*> *AST_list;
}

/* Enable location tracking. */
%locations

/*
 * Because the lexer can generate more than one token at a time (i.e. DEDENT
 * tokens), we'll use a push parser.
 */
%define api.pure full
%define api.push-pull push

/*
 * These are all of the terminals in our grammar, i.e. the syntactic
 * categories that can be recognized by the lexer.
 */
%token <str> IDENTIFIER
%token <str> FLOAT INTEGER BOOLEAN
%token <str> INDENT DEDENT NEWLINE
%token <token> AND BREAK DEF ELIF ELSE FOR IF NOT OR RETURN WHILE
%token <token> ASSIGN PLUS MINUS TIMES DIVIDEDBY
%token <token> EQ NEQ GT GTE LT LTE
%token <token> LPAREN RPAREN COMMA COLON

%type <AST_list> program
%type <AST_list> statements
%type <AST_list> statement
%type <AST_list> primary_expression
%type <AST_list> negated_expression
%type <AST_list> expression
%type <AST_list> assign_statement
%type <AST_list> block
%type <AST_list> condition
%type <AST_list> if_statement
%type <AST_list> elif_blocks
%type <AST_list> else_block
%type <AST_list> while_statement
%type <AST_list> break_statement

/*
 * Here, we're defining the precedence of the operators.  The ones that appear
 * later have higher precedence.  All of the operators are left-associative
 * except the "not" operator, which is right-associative.
 */
%left OR
%left AND
%left PLUS MINUS
%left TIMES DIVIDEDBY
%left EQ NEQ GT GTE LT LTE
%right NOT

/* This is our goal/start symbol. */
%start program

%%

/*
 * Each of the CFG rules below recognizes a particular program construct in
 * Python and creates a new string containing the corresponding C/C++
 * translation.  Since we're allocating strings as we go, we also free them
 * as we no longer need them.  Specifically, each string is freed after it is
 * combined into a larger string.
 */
program
  : statements {
	root.addNodes(*$1);
	}
  ;

statements
  : statement { 
	$$ = $1;
	}
  | statements statement {
	list<AST*> *node_list = new list<AST*>();
	AST_Node *node1 = new AST_Node(id_gen++, *$1);
	AST_Node *node2 = new AST_Node(id_gen++, *$2);
	node_list->push_back(node1);
	node_list->push_back(node2);
	$$ = node_list;
	}
  ;

statement
  : assign_statement {
  	list<AST*> *node_list = new list<AST*>();
  	AST_Assignment *node = new AST_Assignment(id_gen++, *$1);
  	node_list->push_back(node);
  	$$ = node_list;
  	}
  | if_statement {
  	list<AST*> *node_list = new list<AST*>();
  	AST_If *node = new AST_If(id_gen++, *$1);
  	node_list->push_back(node);
  	$$ = node_list;
  	}
  | while_statement {
  	list<AST*> *node_list = new list<AST*>();
  	AST_While *node = new AST_While(id_gen++, *$1);
  	node_list->push_back(node);
  	$$ = node_list;
  	}
  | break_statement {
  	list<AST*> *node_list = new list<AST*>();
  	AST_Node *node = new AST_Node(id_gen++, *$1);
  	node_list->push_back(node);
  	$$ = node_list;
  	}
  ;

primary_expression
  : IDENTIFIER {
	list<AST*> *node_list = new list<AST*>();
	AST_Identifier *node = new AST_Identifier(id_gen++, new std::string(*$1));
	node_list->push_back(node);
	$$ = node_list;
	delete $1;
	}
  | FLOAT { 
	list<AST*> *node_list = new list<AST*>();
	AST_Float *node = new AST_Float(id_gen++, new std::string(*$1));
	node_list->push_back(node);
	$$ = node_list;
	delete $1;
	}
  | INTEGER {
	list<AST*> *node_list = new list<AST*>(); 
	AST_Int *node = new AST_Int(id_gen++, new std::string(*$1));
	node_list->push_back(node);
	$$ = node_list;
	delete $1;
	}
  | BOOLEAN {
	list<AST*> *node_list = new list<AST*>();
	AST_Boolean *node = new AST_Boolean(id_gen++, new std::string(*$1));
	node_list->push_back(node);
	$$ = node_list;
	}
  | LPAREN expression RPAREN {
	list<AST*> *node_list = new list<AST*>();
	AST_Oper *lparen = new AST_Oper(id_gen++, "LPAREN");
	AST_Node *expr = new AST_Node(id_gen++, *$2);
	AST_Oper *rparen = new AST_Oper(id_gen++, "RPAREN");
	node_list->push_back(lparen);
	node_list->push_back(expr);
	node_list->push_back(rparen);
	$$ = node_list;
	}
  ;

negated_expression
  : NOT primary_expression {
	list<AST*> *node_list = new list<AST*>();
	AST_Oper *node = new AST_Oper(id_gen++, "NOT");
	AST_Node *expr = new AST_Node(id_gen++, *$2);
	node_list->push_back(node);
	node_list->push_back(expr);
	$$ = node_list;
	}
  ;

expression
  : primary_expression {
	$$ = $1;
	}
  | negated_expression {
	$$ = $1;
	}
  | expression PLUS expression {
	list<AST*> *node_list = new list<AST*>();
	AST_Node *expr1 = new AST_Node(id_gen++, *$1);
	AST_Oper *node = new AST_Oper(id_gen++, "PLUS");
	AST_Node *expr2 = new AST_Node(id_gen++, *$3);
	node_list->push_back(expr1);
	node_list->push_back(expr2);

	node->addNodes(*node_list);
	list<AST*> *node_list2 = new list<AST*>();
	node_list2->push_back(node);
	$$ = node_list2;
	}
  | expression MINUS expression { 
	list<AST*> *node_list = new list<AST*>();
	AST_Node *expr1 = new AST_Node(id_gen++, *$1);
	AST_Oper *node = new AST_Oper(id_gen++, "MINUS");
	AST_Node *expr2 = new AST_Node(id_gen++, *$3);
	node_list->push_back(expr1);
	node_list->push_back(expr2);

	node->addNodes(*node_list);
	list<AST*> *node_list2 = new list<AST*>();
	node_list2->push_back(node);
	$$ = node_list2;
    }
  | expression TIMES expression { 
	list<AST*> *node_list = new list<AST*>();
	AST_Node *expr1 = new AST_Node(id_gen++, *$1);
	AST_Oper *node = new AST_Oper(id_gen++, "TIMES");
	AST_Node *expr2 = new AST_Node(id_gen++, *$3);
	node_list->push_back(expr1);
	node_list->push_back(expr2);

	node->addNodes(*node_list);
	list<AST*> *node_list2 = new list<AST*>();
	node_list2->push_back(node);
	$$ = node_list2;
    }
  | expression DIVIDEDBY expression { 
	list<AST*> *node_list = new list<AST*>();
	AST_Node *expr1 = new AST_Node(id_gen++, *$1);
	AST_Oper *node = new AST_Oper(id_gen++, "DIVIDEDBY");
	AST_Node *expr2 = new AST_Node(id_gen++, *$3);
	node_list->push_back(expr1);
	node_list->push_back(expr2);

	node->addNodes(*node_list);
	list<AST*> *node_list2 = new list<AST*>();
	node_list2->push_back(node);
	$$ = node_list2;
    }
  | expression EQ expression { 
	list<AST*> *node_list = new list<AST*>();
	AST_Node *expr1 = new AST_Node(id_gen++, *$1);
	AST_Oper *node = new AST_Oper(id_gen++, "EQ");
	AST_Node *expr2 = new AST_Node(id_gen++, *$3);
	node_list->push_back(expr1);
	node_list->push_back(expr2);

	node->addNodes(*node_list);
	list<AST*> *node_list2 = new list<AST*>();
	node_list2->push_back(node);
	$$ = node_list2;
    }
  | expression NEQ expression { 
	list<AST*> *node_list = new list<AST*>();
	AST_Node *expr1 = new AST_Node(id_gen++, *$1);
	AST_Oper *node = new AST_Oper(id_gen++, "NEQ");
	AST_Node *expr2 = new AST_Node(id_gen++, *$3);
	node_list->push_back(expr1);
	node_list->push_back(expr2);

	node->addNodes(*node_list);
	list<AST*> *node_list2 = new list<AST*>();
	node_list2->push_back(node);
	$$ = node_list2;
    }
  | expression GT expression { 
	list<AST*> *node_list = new list<AST*>();
	AST_Node *expr1 = new AST_Node(id_gen++, *$1);
	AST_Oper *node = new AST_Oper(id_gen++, "GT");
	AST_Node *expr2 = new AST_Node(id_gen++, *$3);
	node_list->push_back(expr1);
	node_list->push_back(expr2);

	node->addNodes(*node_list);
	list<AST*> *node_list2 = new list<AST*>();
	node_list2->push_back(node);
	$$ = node_list2;
    }
  | expression GTE expression { 
	list<AST*> *node_list = new list<AST*>();
	AST_Node *expr1 = new AST_Node(id_gen++, *$1);
	AST_Oper *node = new AST_Oper(id_gen++, "GTE");
	AST_Node *expr2 = new AST_Node(id_gen++, *$3);
	node_list->push_back(expr1);
	node_list->push_back(expr2);

	node->addNodes(*node_list);
	list<AST*> *node_list2 = new list<AST*>();
	node_list2->push_back(node);
	$$ = node_list2;
    }
  | expression LT expression { 
	list<AST*> *node_list = new list<AST*>();
	AST_Node *expr1 = new AST_Node(id_gen++, *$1);
	AST_Oper *node = new AST_Oper(id_gen++, "LT");
	AST_Node *expr2 = new AST_Node(id_gen++, *$3);
	node_list->push_back(expr1);
	node_list->push_back(expr2);

	node->addNodes(*node_list);
	list<AST*> *node_list2 = new list<AST*>();
	node_list2->push_back(node);
	$$ = node_list2;
    }
  | expression LTE expression {
	list<AST*> *node_list = new list<AST*>();
	AST_Node *expr1 = new AST_Node(id_gen++, *$1);
	AST_Oper *node = new AST_Oper(id_gen++, "LTE");
	AST_Node *expr2 = new AST_Node(id_gen++, *$3);
	node_list->push_back(expr1);
	node_list->push_back(expr2);

	node->addNodes(*node_list);
	list<AST*> *node_list2 = new list<AST*>();
	node_list2->push_back(node);
	$$ = node_list2;
    }
  ;

assign_statement
  : IDENTIFIER ASSIGN expression NEWLINE {
	list<AST*> *node_list = new list<AST*>();
	AST_Identifier *node1 = new AST_Identifier(id_gen++, new std::string(*$1));
	AST_Node *node2 = new AST_Node(id_gen++, *$3);
	node_list->push_back(node1);
	node_list->push_back(node2);
	$$ = node_list;
	delete $1;
	}
  ;

block
  : INDENT statements DEDENT {
	$$ = $2;
	}
  ;

condition
  : expression { $$ = $1; }
  | condition AND condition {
	list<AST*> *node_list = new list<AST*>();
	AST_Node *node1 = new AST_Node(id_gen++, *$1);
	AST_Oper *node2 = new AST_Oper(id_gen++, "And");
	AST_Node *node3 = new AST_Node(id_gen++, *$3);
	node_list->push_back(node1);
	node_list->push_back(node2);
	node_list->push_back(node3);
	$$ = node_list;
	}
  | condition OR condition {
	list<AST*> *node_list = new list<AST*>();
	AST_Node *node1 = new AST_Node(id_gen++, *$1);
	AST_Oper *node2 = new AST_Oper(id_gen++, "Or");
	AST_Node *node3 = new AST_Node(id_gen++, *$3);
	node_list->push_back(node1);
	node_list->push_back(node2);	
	node_list->push_back(node3);
	$$ = node_list;
	}
  ;

if_statement
  : IF condition COLON NEWLINE block elif_blocks else_block {
	list<AST*> *node_list = new list<AST*>();
	AST_Node *node1 = new AST_Node(id_gen++, *$2);
	AST_Block *node2 = new AST_Block(id_gen++, *$5);
	node_list->push_back(node1);
	node_list->push_back(node2);

	//Check if elif and else are present
	if($6 != NULL) {
		AST_Block *node3 = new AST_Block(id_gen++, *$6);
		node_list->push_back(node3);
	}
	if($7 != NULL) {
		AST_Block *node4 = new AST_Block(id_gen++, *$7);
		node_list->push_back(node4);
	}

	$$ = node_list;
	}
  ;

elif_blocks
  : %empty {
	$$ = NULL;
	}
  | elif_blocks ELIF condition COLON NEWLINE block {
	list<AST*> *node_list = new list<AST*>();
	AST_Node *node1 = new AST_Node(id_gen++, *$1);
	AST_Oper *node2 = new AST_Oper(id_gen++, "Elif");
	AST_Node *node3 = new AST_Node(id_gen++, *$3);
	AST_Block *node4 = new AST_Block(id_gen++, *$6);
	node_list->push_back(node1);
	//node_list->push_back(node2);
	node_list->push_back(node3);
	node_list->push_back(node4);

	node2->addNodes(*node_list);
	list<AST*> *node_list2 = new list<AST*>();
	node_list2->push_back(node2);

	$$ = node_list2;
	}
  ;

else_block
  : %empty {
	$$ = NULL;
	}
  | ELSE COLON NEWLINE block {
	list<AST*> *node_list = new list<AST*>();
	AST_Oper *node1 = new AST_Oper(id_gen++, "Else");
	AST_Block *node2 = new AST_Block(id_gen++, *$4);
	//node_list->push_back(node1);
	node_list->push_back(node2);
	
	node1->addNodes(*node_list);
	list<AST*> *node_list2 = new list<AST*>();
	node_list2->push_back(node1);

	$$ = node_list2;
	}

while_statement
  : WHILE condition COLON NEWLINE block {
	list<AST*> *node_list = new list<AST*>();
	AST_Node *node1 = new AST_Node(id_gen++, *$2);
	AST_Block *node2 = new AST_Block(id_gen++, *$5);
	node_list->push_back(node1);
	node_list->push_back(node2);
	$$ = node_list;
	}
  ;

break_statement
  : BREAK NEWLINE {
	list<AST*> *node_list = new list<AST*>();
	AST_Oper *node = new AST_Oper(id_gen++, "Break");
	node_list->push_back(node);
	$$ = node_list;
	}
  ;

%%

void yyerror(YYLTYPE* loc, const char* err) {
  std::cerr << "Error (line " << loc->first_line << "): " << err << std::endl;
}

