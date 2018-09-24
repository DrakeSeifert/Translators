all: parser

parser.cpp parser.hpp: parser.y
	bison -d -o parser.cpp parser.y

scanner.cpp: scanner.l
	flex -o scanner.cpp scanner.l

parser: main.cpp parser.cpp scanner.cpp
	g++ main.cpp parser.cpp scanner.cpp -o parser

test:
	./parser < testing_code/p1.py > output1.cpp
	./parser < testing_code/p2.py > output2.cpp
	./parser < testing_code/p3.py > output3.cpp
	diff output1.cpp example_output/p1.cpp
	diff output2.cpp example_output/p2.cpp
	diff output3.cpp example_output/p3.cpp
	g++ output1.cpp -o output1
	g++ output2.cpp -o output2
	g++ output3.cpp -o output3

clean:
	rm -f parser scanner.cpp parser.cpp parser.hpp output1.cpp output2.cpp output3.cpp output1 output2 output3
