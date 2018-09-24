#include <iostream>
#include <list>

using std::cout;
using std::endl;
using std::list;

class Foo {
public:
	int id;
	Foo(int setID) { this->id = setID; }
};

int main() {

	list<Foo*> fooList;

	Foo obj1(25);
	Foo obj2(50);
	Foo obj3(75);
	Foo obj4(100);

	fooList.push_back(&obj1);
	fooList.push_back(&obj2); 
	fooList.push_back(&obj3); 
	fooList.push_back(&obj4); 

	list<Foo*>::iterator it;
	for(it = fooList.begin(); it != fooList.end(); it++) {
		cout << (*it)->id << endl;
	}

	return 0;
}
