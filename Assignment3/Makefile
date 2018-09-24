all: parse

parser.cpp parser.hpp: parser.y
	bison -d -o parser.cpp parser.y

scanner.cpp: scanner.l
	flex -o scanner.cpp scanner.l

parse: main.cpp parser.cpp scanner.cpp AST.hpp
	g++ main.cpp parser.cpp scanner.cpp -o parse

test:
	rm -f output1.gv output1.png output2.gv output2.png output3.gv output3.png
	./parse < testing_code/p1.py > output1.gv
	./parse < testing_code/p2.py > output2.gv
	./parse < testing_code/p3.py > output3.gv
	dot -Tpng -o output1.png output1.gv
	dot -Tpng -o output2.png output2.gv
	dot -Tpng -o output3.png output3.gv

clean:
	rm -f parse scanner.cpp parser.cpp parser.hpp output1.* output2.* output3.*
