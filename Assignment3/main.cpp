#include <iostream>
#include <set>
#include "AST.hpp"
#include "parser.hpp"

extern int yylex();
extern AST root;

int main() {
  if (!yylex()) {
    root.printTreeFile();
  }
}
