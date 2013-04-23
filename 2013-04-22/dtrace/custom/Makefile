all: custom.so

custom.so: custom.o
	ld -dylib custom.o -o custom.so -lc -macosx_version_min 10.7

custom.o: custom.c custom.h custom_probes.h
	gcc -c custom.c -o custom.o

custom_probes.h: custom_probes.d
	dtrace -h -s custom_probes.d
