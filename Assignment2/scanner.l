%{
#include <iostream>
#include <stack>
#include <cstdlib>
#include "parser.hpp"

std::stack<int> _indent_stack;

YYSTYPE yylval;
YYLTYPE yylloc;

yypstate* pstate = yypstate_new();

#define PUSH_TOKEN(token) do {					\
	int s = yypush_parse(pstate, token, &yylval, &yylloc); 	\
	if (s != YYPUSH_MORE) {					\
		yypstate_delete(pstate);			\
		return s;					\
	}							\
} while(0)
%}

%option noyywrap
%option yylineno

%%

%{
   if (_indent_stack.empty()) {
   _indent_stack.push(0);
  }
%}

^[ \t]*\r?\n   { /* Skip blank lines */ }

^[ \t]*#.*\r?\n    { /* Skip whole-line comments. */ }

#.*$        { /* Skip comments on the same line as a statement. */ }

^[ \t]+     {
		if (_indent_stack.top() < yyleng) {
                	_indent_stack.push(yyleng);
			PUSH_TOKEN((yylval.token = INDENT));
		} else {
                	while (!_indent_stack.empty() && _indent_stack.top() != yyleng) {
                		_indent_stack.pop();
				PUSH_TOKEN((yylval.token = DEDENT));
                	}
			if (_indent_stack.empty()) {
                		std::cerr << "Error: Incorrect indentation on line "
                		<< yylineno << ": " << yytext << std::endl;
				yyterminate();
                	}
		}
            }

^[^ \t\n]+  {
		while(_indent_stack.top() != 0) {
                	_indent_stack.pop();
			PUSH_TOKEN((yylval.token = DEDENT));
		}
                REJECT;
            }

\r?\n       {
		PUSH_TOKEN((yylval.token = NEWLINE));
            }

<<EOF>>     {
                while(_indent_stack.top() != 0) {
                	_indent_stack.pop();
			PUSH_TOKEN((yylval.token = DEDENT));
                }
		int s = yypush_parse(pstate, 0, NULL, NULL);
		yypstate_delete(pstate);
		return s;
            }

[ \t]       { /* Ignore spaces that haven't been handled above. */ }

"and"       {   //std::cout << "AND\t\t" << yytext << std::endl;
		PUSH_TOKEN((yylval.token = AND));
	    }
"break"     { //std::cout << "BREAK\t\t" << yytext << std::endl; 
		PUSH_TOKEN((yylval.token = BREAK));
	    }

"elif"      { //std::cout << "ELIF\t\t" << yytext << std::endl;
		PUSH_TOKEN((yylval.token = ELIF));
	    }

"else"      { //std::cout << "ELSE\t\t" << yytext << std::endl; 
		PUSH_TOKEN((yylval.token = ELSE));
	    }

"if"        { //std::cout << "IF\t\t" << yytext << std::endl; 
		PUSH_TOKEN((yylval.token = IF));
	    }

"not"       { //std::cout << "NOT\t\t" << yytext << std::endl; 
		PUSH_TOKEN((yylval.token = NOT));
	    }

"or"        { //std::cout << "OR\t\t" << yytext << std::endl; 
		PUSH_TOKEN((yylval.token = OR));
	    }

"while"     { //std::cout << "WHILE\t\t" << yytext << std::endl; 
		PUSH_TOKEN((yylval.token = WHILE));
	    }

"True"      { //std::cout << "BOOLEAN\t\t" << true << std::endl; 
		yylval.str = new std::string("true", yyleng);
		PUSH_TOKEN(BOOLEAN);
	    }

"False"     { //std::cout << "BOOLEAN\t\t" << false << std::endl; 
		yylval.str = new std::string("false", yyleng);
		PUSH_TOKEN(BOOLEAN);
	    }

[a-zA-Z_][a-zA-Z0-9_]*  {
				yylval.str = new std::string(yytext, yyleng);
				PUSH_TOKEN(IDENTIFIER);
                        }

-?[0-9]*"."[0-9]+       {
				yylval.str = new std::string(yytext, yyleng);
				PUSH_TOKEN(FLOAT);
                        }

-?[0-9]+    {
		yylval.str = new std::string(yytext, yyleng);
		PUSH_TOKEN(INTEGER);
            }

"="         { //std::cout << "ASSIGN\t\t" << yytext << std::endl; 
		PUSH_TOKEN((yylval.token = ASSIGN));
	    }

"+"         { //std::cout << "PLUS\t\t" << yytext << std::endl;
		PUSH_TOKEN((yylval.token = PLUS));
	    }

"-"         { //std::cout << "MINUS\t\t" << yytext << std::endl; 
		PUSH_TOKEN((yylval.token = MINUS));
	    }

"*"         { //std::cout << "TIMES\t\t" << yytext << std::endl; 
		PUSH_TOKEN((yylval.token = TIMES));
	    }

"/"         { //std::cout << "DIVIDEDBY\t" << yytext << std::endl; 
		PUSH_TOKEN((yylval.token = DIVIDEDBY));
	    }

"=="        { //std::cout << "EQ\t\t" << yytext << std::endl; 
		PUSH_TOKEN((yylval.token = EQ));
	    }

"!="        { //std::cout << "NEQ\t\t" << yytext << std::endl; 
		PUSH_TOKEN((yylval.token = NEQ));
	    }

">"         { //std::cout << "GT\t\t" << yytext << std::endl; 
		PUSH_TOKEN((yylval.token = GT));
	    }

">="        { //std::cout << "GTE\t\t" << yytext << std::endl; 
		PUSH_TOKEN((yylval.token = GTE));
	    }

"<"         { //std::cout << "LT\t\t" << yytext << std::endl; 
		PUSH_TOKEN((yylval.token = LT));
	    }

"<="        { //std::cout << "LTE\t\t" << yytext << std::endl; 
		PUSH_TOKEN((yylval.token = LTE));
	    }

"("         { //std::cout << "LPAREN\t\t" << yytext << std::endl; 
		PUSH_TOKEN((yylval.token = LPAREN));
	    }

")"         { //std::cout << "RPAREN\t\t" << yytext << std::endl; 
		PUSH_TOKEN((yylval.token = RPAREN));
	    }

":"         { //std::cout << "COLON\t\t" << yytext << std::endl; 
		PUSH_TOKEN((yylval.token = COLON));
	    }

.           {
                std::cerr << "Unrecognized token on line " << yylineno << ": "
                << yytext << std::endl;
		PUSH_TOKEN(yytext[0]);
            }

%%
