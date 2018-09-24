#include <iostream>
#include <list>

using std::cout;
using std::endl;
using std::list;

void func(list<int> foo)
{
	cout << ":)" << endl;
	list<int>::iterator it;
	for(it = foo.begin(); it != foo.end(); it++) {
		cout << *it << endl;
	}
}

int main() {

	list<int> *ptr = new list<int>();

	ptr->push_back(1);
	ptr->push_back(2);
	ptr->push_back(3);

	list<int>::iterator it;
	for(it = ptr->begin(); it != ptr->end(); it++) {
		cout << *it << endl;
	}

	func(*ptr);

	delete ptr;

	return 0;
}
