all: counter scanner

counter.cpp: counter.l
	flex -o counter.cpp counter.l

counter: counter.cpp
	g++ counter.cpp -o counter

scanner.cpp: scanner.l
	flex -o scanner.cpp scanner.l

scanner: scanner.cpp
	g++ scanner.cpp -o scanner

clean:
	rm -f counter scanner counter.cpp scanner.cpp
