#include <iostream>
#include <list>

using std::cout;
using std::endl;
using std::list;

int main() {

	list<int> foo;
	list<int> bar;

	for(int i = 1; i < 6; i++) {
		foo.push_back(i); // 1 2 3 4 5
	}

	for(int i = 1; i < 6; i++) {
		bar.push_back(i * 10); // 10 20 30 40 50
	}

	list<int>::iterator it1, it2;
	it1 = foo.begin();
	std::advance(it1, 2);   //it1 now points at "3"
	foo.splice(it1, bar);   //puts contents of bar before 3 (1 2 10 10 30 40 50 3 4 5)
				//bar is now empty
				//it1 still points at 3
	it1 = foo.erase(it1);   //erase 3 (1 2 10 20 30 40 50 4 5)

	list<int>::iterator it;
	for(it = foo.begin(); it != foo.end(); it++) {
		cout << "foo: " << *it << endl;
	}

	return 0;
}
