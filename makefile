e8:
	nasm -felf64 gabinete_e8.asm
	ld gabinete_e8.o
	./a.out

test:
	nasm -felf64 gabinete_e8.asm
	ld gabinete_e8.o
	gdb a.out

e1:
	nasm -felf64 e1.asm
	ld -o e1 e1.o
	./e1

e2:
	nasm -felf64 e2.asm
	ld -o e2 e2.o
	./e2

ea:
	nasm -felf64 ea.asm
	ld -o ea ea.o
	./ea

try:
	nasm -felf64 try.asm
	ld -o try try.o
	./try

clean:
	rm -f *.o a.out
	ls | grep -v "\." | grep -v makefile | xargs rm
	