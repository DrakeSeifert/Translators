#ifndef AST_HPP
#define AST_HPP

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
		label = "Block";
		id = 0;
	}

	AST(list<AST*> children) {
		label = "Block";
		id = 0;

		addNodes(children);
	}

	void addNodes(list<AST*> children) {
		list<AST*>::iterator it;
		for(it = children.begin(); it != children.end(); it++) {
			this->tree.push_back((*it));
		}
	}

	void addNode(AST *node) {
		this->tree.push_back(node);
	}

	void printTreeFile() {

		//Clean out temp nodes
		this->cleanTree();
		this->cleanTree();

		//Print file header
		cout << "digraph G {" << endl;
		cout << "\t" << this->id << " [label=\"" << this->label <<
			"\"];" << endl;

		//Recursively print tree
		this->printTree();

		cout << "}";
	}

	void printTree() {
		if(!tree.empty()) {
			list<AST*>::iterator it;
			for(it = tree.begin(); it != tree.end(); it++) {
				cout << "\t" << (*it)->id << " [label=\"" << (*it)->label <<
					"\"];" << endl;

				cout << "\t" << this->id << " -> " << (*it)->id << endl;

				(*it)->printTree();
			}
		}
	}

	void cleanTree() {
		//cout << "TEST: CURRENTLY IN: " << this->label << endl;
		bool nodeFound = false;
		if(!tree.empty()) {
			list<AST*>::iterator it;
			for(it = tree.begin(); it != tree.end(); it++) {
				//cout << "TEST: Iterating" << endl;
				if((*it)->label == "Node") {
					//cout << "TEST: Splicing" << endl;
					this->tree.splice(it, (*it)->tree);
						//Insert child list into current list
					//cout << "TEST: Erasing" << endl;
					it = this->tree.erase(it); //Delete node
					it = tree.begin(); //TODO fix this atrocity
				}
				//cout << "TEST: Recursing" << endl;
				(*it)->cleanTree();
			}
		}
		//cout << "TEST: Returning" << endl;
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
		label = name;
	}
};

class AST_Identifier : public AST {
public:
	AST_Identifier(int nodeID, string *name) {
		id = nodeID;		
		label = "Identifier: " + *name;
	}
};

class AST_Float : public AST {
public:
	AST_Float(int nodeID, string *name) {
		id = nodeID;
		label = "Float: " + *name;
	}
};

class AST_Int : public AST {
public:
	AST_Int(int nodeID, string *name) {
		id = nodeID;
		label = "Int: " + *name;
	}
};

class AST_Boolean : public AST {
public:
	AST_Boolean(int nodeID, string *name) {
		id = nodeID;
		label = "Boolean: " + *name;
	}
};

#endif
