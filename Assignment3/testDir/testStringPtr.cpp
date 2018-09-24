#include <iostream>
#include <string>

using std::cout;
using std::endl;
using std::string;

void func(string str)
{
	cout << str << endl;
}

int main() {
	
	string *strPtr;
	string str = "Hello world";

	strPtr = &str;
	func(*strPtr);

	return 0;
}
