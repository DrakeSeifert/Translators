#include <iostream>
#include <map>

extern int yyparse();

extern std::map<std::string, float> symbols;
extern bool _error;

int main(int argc, char const *argv[]) {
  yyparse();
  if (!_error) {
    std::map<std::string, float>::iterator it;
    for (it = symbols.begin(); it != symbols.end(); it++) {
      std::cout << it->first << ":\t" << it->second << std::endl;
    }
    return 0;
  } else {
    return 1;
  }
}
