section .data
	hello: 	db	"Hello World!",0x0a
section .text
	global	_start
	
_start:
	nop
	mov	eax	,	4
	mov	ebx	,	0
	mov	ecx	,	hello
	mov	edx	,	12
	int 80h
	
	mov	eax	,	1 ; Ende jedes Programms
	mov	ebx	,	0
	int 80h
