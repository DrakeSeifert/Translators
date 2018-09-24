#include <iostream>
#include <list>

using std::cout;
using std::endl;
using std::string;
using std::list;

class AST {
public:
	list<AST*> tree;
	string label;
	int id;

	AST() {
		label = "Root";
		id = 0;
	}

	AST(list<AST*> children) {
		label = "Root";
		id = 0;

		addNodes(children);
	}

	void addNodes(list<AST*> children) {
		list<AST*>::iterator it;
		for(it = children.begin(); it != children.end(); it++) {
			tree.push_back((*it));
		}
	}

	void addNode(AST *node) {
		tree.push_back(node);
	}

	void printTreeFile() {
		cout << "digraph G {" << endl;
		cout << "\t" << this->id << " [label=\"" << this->label <<
			"\"];" << endl;

		printTree();

		cout << "}";
	}

	void printTree() {
		list<AST*>::iterator it;
		for(it = tree.begin(); it != tree.end(); it++) {
			cout << "\t" << (*it)->id << " [label=\"" << (*it)->label <<
			"\"];" << endl;

			cout << "\t" << this->id << " -> " << (*it)->id << endl;

			(*it)->printTree();
		}
	}
};

class AST_Assignment : public AST {
public:
	AST_Assignment() {}

	AST_Assignment(int nodeID, list<AST*> children) {
		id = nodeID;
		label = "Assignment";

		addNodes(children);
	}
};

class AST_If : public AST {
public:
	AST_If() {}

	AST_If(int nodeID, list<AST*> children) {
		id = nodeID;
		label = "If";

		addNodes(children);
	}
};

class AST_While : public AST {
public:
	AST_While() {}

	AST_While(int nodeID, list<AST*> children) {
		id = nodeID;
		label = "While";

		addNodes(children);
	}
};

/*class AST_Break : public AST {
public:
	AST_Break() {}

	AST_Break(int nodeID, list<AST*> children) {
		id = nodeID;
		label = "Break";

		addNodes(children);
	}
};*/

class AST_Block : public AST {
public:
	AST_Block() {}

	AST_Block(int nodeID, list<AST*> children) {
		id = nodeID;
		label = "Block";
		addNodes(children);
	}
};

class AST_Node : public AST {
public:
	AST_Node() {}

	AST_Node(int nodeID, list<AST*> children) {
		id = nodeID;
		label = "Node";
		addNodes(children);
	}
};

class AST_Oper : public AST {
public:
	AST_Oper(int nodeID, string name) {
		id = nodeID;
		label = name
	}
};

class AST_Identifier : public AST {
public:
	AST_Identifier(int nodeID, string name) {
		id = nodeID;		
		label = "Identifier: " + name;
	}
};

class AST_Float : public AST {
public:
	AST_Float(int nodeID, string name) {
		id = nodeID;
		label = "Float: " + name;
	}
};

class AST_Int : public AST {
public:
	AST_Int(int nodeID, string name) {
		id = nodeID;
		label = "Int: " + name;
	}
};

class AST_Boolean : public AST {
public:
	AST_Boolean(int nodeID, string name) {
		id = nodeID;
		label = "Boolean: " + name;
	}
};

int main()
{
	list<AST*> nodes;

	AST_Identifier a(1, "pi");
	AST_Float b(2, "3.14159");
	//AST_Int c(3, "42");
	//AST_Boolean d(4, "0");

	nodes.push_back(&a);
	nodes.push_back(&b);

	AST_Assignment assign(nodes, 99);

	AST root;
	root.addNode(&assign);

	//root.addNode(&a);
	//root.addNode(&b);
	//root.addNode(&c);
	//root.addNode(&d);


	root.printTreeFile();	
	
	return 0;
}
