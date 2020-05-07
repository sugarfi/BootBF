DEFAULT_GOAL: hello

binary:
	nasm -f bin -o bootbf.bin bootbf.asm
	dd if=/dev/zero of=bootbf.bin conv=notrunc seek=1 bs=512 count=4095

hello: binary
	dd if=hello.b of=bootbf.bin conv=notrunc seek=1

cat: binary
	dd if=cat.b of=bootbf.bin conv=notrunc seek=1

%.b: binary
	dd if=$@ of=bootbf.bin conv=notrunc seek=1
