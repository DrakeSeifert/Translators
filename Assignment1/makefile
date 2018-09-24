all: scanner

scanner.cpp: scanner.l
	flex -o scanner.cpp scanner.l

scanner: scanner.cpp
	g++ scanner.cpp -o scanner
test:
	./scanner < testing_code/p1.py > output1;
	./scanner < testing_code/p2.py > output2;
	./scanner < testing_code/p3.py > output3;
	./scanner < testing_code/p4.py > output4;
	diff output1 example_output/p1.out;
	diff output2 example_output/p2.out;
	diff output3 example_output/p3.out;
	diff output4 example_output/p4.out;
clean:
	rm -f scanner scanner.cpp output1 output2 output3 output4

