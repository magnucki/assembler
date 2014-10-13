;;; system calls
%define		SYS_WRITE	4
%define		SYS_EXIT	1
;;; file ids
%define		STDOUT		1
;;start of bss section
section .bss
buffer:		resb	8
;;; start of data section
section .data
;;; a newline character
newline:
			db 0x0a
;;; start of code section
section .text
			;; this symbol has to be defined as entry point of the program
			global _start
;;;-----------------------------------------------------------------------------
;;; main programm
;;;-----------------------------------------------------------------------------

_start:
		nop

		call	eg_1
		call	add_numbers

		call	eg_2
		call	add_numbers

		call	eg_3
		call	add_numbers

		call	eg_4
		call	add_numbers

		call	eg_5
		call	add_numbers

 exit:
		mov		eax,	SYS_EXIT
		mov		ebx,	0
		int		80h

;;;-----------------------------------------------------------------------------
;;; subroutines
;;;-----------------------------------------------------------------------------

eg_1:
		mov		eax,	0x11111111
		mov		ebx,	0x22222222
		mov		ecx,	0x33333333
		mov		edx,	0x44444444
		ret

eg_2:
		mov		eax,	0x11111111
		mov		ebx,	0x22222222
		mov		ecx,	0x33333333
		mov		edx,	0xdddddddd
		ret

eg_3:
		mov		eax,	0x11111111
		mov		ebx,	0x22222222
		mov		ecx,	0x33333333
		mov		edx,	0xddddddde
		ret

eg_4:
		mov		eax,	0x11111111
		mov		ebx,	0x22222222
		mov		ecx,	0x33333333
		mov		edx,	0xeeeeeeee
		ret

eg_5:
		mov		eax,	0x11111111
		mov		ebx,	0x22222222
		mov		ecx,	0xeeeeeeee
		mov		edx,	0xeeeeeeee
		ret

add_numbers:
		add		ebx,	edx
		adc		eax,	ecx
		ret
