#include <iostream>
//#include <map>
#include <string>
#include <list>

using std::cout;
using std::endl;

extern int yylex();
//extern std::map<std::string, float> symbols;
extern std::list<std::string> symbols;
extern std::string prog;

int main() {
	if(!yylex()) {
		symbols.sort();
		symbols.unique();
		std::list<std::string>::iterator it;

		cout << "#include <iostream>" << endl;
		cout << "int main() {" << endl;

		for(it = symbols.begin(); it != symbols.end(); it++) {
			cout << "double " << *it << ";" << endl;
		}
		
		cout << endl << "/* Begin program */" << endl << endl;
		cout << prog; //print global variable from parser
		cout << endl << "/* End program */" << endl << endl;
		
		for(it = symbols.begin(); it != symbols.end(); it++) {
			cout << "std::cout << \"" << *it
			<< ": \" << " << *it << " << std::endl;" << endl;
		}
		cout << "}" << endl;
		return 0;
	} else {
		return 1;
	}
}
