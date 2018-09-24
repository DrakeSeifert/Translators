%{
#include <iostream>
#include <stdio.h>
#include <vector>
#include <set>
#include <stack>

#define DEBUG 0

struct _word {
  std::string lexeme;
  std::string category;
};

std::vector<struct _word> _words;
std::set<std::string> _ids;
bool _error = false;

void _save_word(const std::string& lexeme, const std::string& category) {
  struct _word _word = {
    .lexeme = lexeme,
    .category = category
  };
  _words.push_back(_word);
}

std::stack<int> _ind_token; //init stack with zero

%}

%option noyywrap
%option yylineno

%%

%{
                    /* No code to put at the top of yylex(). */
                    /* [ \t\n]* */
                    /* [0-9]+("."[0-9]+)? */
%}

^#.*\n              {} /* Ignore comment lines */

^[ |\t]+            {
                      if(yyleng > _ind_token.top()) {
                        _ind_token.push(yyleng);
                        _save_word(yytext, "INDENT");
                      } else if (yyleng < _ind_token.top()) {
                        while (_ind_token.top() != yyleng) {
                          if (_ind_token.empty()) {
                            std::cerr << "Invalid Indentation on line " << yylineno
                            << ": " << yytext << std::endl;
                            _error = true;
                          }
                          _ind_token.pop();
                          _save_word(yytext, "DEDENT");
                        }
                      }

                      if (_ind_token.empty()) {
                        std::cerr << "Invalid Indentation on line " << yylineno
                        << ": " << yytext << std::endl;
                        _error = true;
                      }
                      
                    }

^[^ \t\n]+          {
                      while(_ind_token.top() != 0) {
                        if (_ind_token.empty()) {
                            std::cerr << "Invalid Indentation on line " << yylineno
                            << ": " << yytext << std::endl;
                            _error = true;
                        }
                        _ind_token.pop();
                        _save_word(yytext, "DEDENT");
                      }
                      REJECT;
                    }

[ ]                 {} /* Ignore spaces */

-?[0-9]+\.[0-9]*    { _save_word(yytext, "FLOAT"); }
-?[0-9]+            { _save_word(yytext, "INTEGER"); }

True|False          { _save_word(yytext, "BOOLEAN"); }

and                 { _save_word(yytext, "AND"); }
break               { _save_word(yytext, "BREAK"); }
def                 { _save_word(yytext, "DEF"); }
elif                { _save_word(yytext, "ELIF"); }
else                { _save_word(yytext, "ELSE"); }
for                 { _save_word(yytext, "FOR"); }
if                  { _save_word(yytext, "IF"); }
not                 { _save_word(yytext, "NOT"); }
or                  { _save_word(yytext, "OR"); }
return              { _save_word(yytext, "RETURN"); }
while               { _save_word(yytext, "WHILE"); }

([a-z]|[A-Z]|_)+([a-z]|[A-Z]|_|[0-9])*   {
                      _save_word(yytext, "IDENTIFIER");
                      _ids.insert(yytext);
                    }

"="                 { _save_word(yytext, "ASSIGN"); }
"+"                 { _save_word(yytext, "PLUS"); }
"-"                 { _save_word(yytext, "MINUS"); }
"*"                 { _save_word(yytext, "TIMES"); }
"/"                 { _save_word(yytext, "DIVIDEDBY"); }
"=="                { _save_word(yytext, "EQ"); }
"!="                { _save_word(yytext, "NEQ"); }
">"                 { _save_word(yytext, "GT"); }
">="                { _save_word(yytext, "GTE"); }
"<"                 { _save_word(yytext, "LT"); }
"<="                { _save_word(yytext, "LTE"); }

"("                 { _save_word(yytext, "LPAREN"); }
")"                 { _save_word(yytext, "RPAREN"); }
","                 { _save_word(yytext, "COMMA"); }
":"                 { _save_word(yytext, "COLON"); }

^[ \t\n]            {} /* Ignore blank lines */
"\n"                { _save_word(yytext, "NEWLINE"); }

<<EOF>>             {
                      while(_ind_token.top() != 0) {
                        if (_ind_token.empty()) {
                            std::cerr << "Invalid Indentation on line " << yylineno
                            << ": " << yytext << std::endl;
                            _error = true;
                        }
                        _ind_token.pop();
                        _save_word(yytext, "DEDENT");
                      }
                      if (_error) {
                        return 1;
                      }
                      return 0;
                    }

.                   {
                      std::cerr << "Invalid symbol on line " << yylineno
                      << ": " << yytext << std::endl;
                      _error = true;
                    }

%%

int main() {

  _ind_token.push(0);

  if (!yylex()) {
    std::vector<struct _word>::iterator wit;
    for (wit = _words.begin(); wit != _words.end(); ++wit) {
      if ( wit->category == "NEWLINE"
        || wit->category == "INDENT"
        || wit->category == "DEDENT" )
        std:: cout << wit->category << std::endl;
      else if (wit->lexeme == "True")
        std::cout << wit->category << "\t\t" << 1 << std::endl;
      else if (wit->lexeme == "False")
        std::cout << wit->category << "\t\t" << 0 << std::endl;
      else if (wit->category == "IDENTIFIER" || wit->category == "DIVIDEDBY")
        std::cout << wit->category << "\t" << wit->lexeme << std::endl;
      else if (wit->category == "FLOAT")
        std::cout << wit->category << "\t\t" << ::atof(wit->lexeme.c_str()) << std::endl;
      else
        std::cout << wit->category << "\t\t" << wit->lexeme << std::endl;
    }


    if (DEBUG) {
      std::cout << std::endl << "Identifiers:" << std::endl;
      std::set<std::string>::iterator iit;
      for (iit = _ids.begin(); iit != _ids.end(); ++iit) {
        std::cout << *iit << std::endl;
      }

      std::cout << std::endl << "Indent Stack:" << std::endl;
      while(!_ind_token.empty()) {
        std::cout << _ind_token.top() << std::endl;
        _ind_token.pop();
      }
    }
  }
}
